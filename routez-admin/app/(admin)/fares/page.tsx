'use client';

import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { saccoRouteFareSchema, type SaccoRouteFareFormValues } from '@/lib/validation/schemas';
import { createClient } from '@/lib/supabase/client';
import { toast } from 'sonner';
import { Plus, Trash2 } from 'lucide-react';
import type { SaccoRoute, SaccoRouteFare } from '@/types/database';

export default function FaresPage() {
  const supabase = createClient();

  const [saccoRoutes, setSaccoRoutes] = useState<any[]>([]);
  const [selectedSaccoRoute, setSelectedSaccoRoute] = useState('');
  const [routeStages, setRouteStages] = useState<any[]>([]);
  const [fares, setFares] = useState<SaccoRouteFare[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from('sacco_routes')
      .select('id, saccos(name), routes(route_number, origin_name, destination_name)')
      .order('created_at', { ascending: false })
      .then(({ data }) => { setSaccoRoutes(data ?? []); setLoading(false); });
  }, []);

  useEffect(() => {
    if (!selectedSaccoRoute) { setRouteStages([]); setFares([]); return; }
    async function loadData() {
      const [stagesRes, faresRes] = await Promise.all([
        supabase.from('sacco_route_stages')
          .select('stop_order, stages(id, name, area)')
          .eq('sacco_route_id', selectedSaccoRoute)
          .order('stop_order'),
        supabase.from('sacco_route_fares')
          .select('*, from_stage:from_stage_id(name), to_stage:to_stage_id(name)')
          .eq('sacco_route_id', selectedSaccoRoute),
      ]);
      setRouteStages((stagesRes.data ?? []).map((r: any) => ({ ...r.stages, stop_order: r.stop_order })));
      setFares((faresRes.data as any) ?? []);
    }
    loadData();
  }, [selectedSaccoRoute]);

  const { register, handleSubmit, reset, setValue, formState: { errors, isSubmitting } } = useForm<SaccoRouteFareFormValues>({
    resolver: zodResolver(saccoRouteFareSchema),
    defaultValues: { sacco_route_id: '', from_stage_id: '', to_stage_id: '', fare_offpeak: 0, fare_peak: 0 },
  });

  useEffect(() => {
    if (selectedSaccoRoute) {
      setValue('sacco_route_id', selectedSaccoRoute, { shouldValidate: true });
    }
  }, [selectedSaccoRoute, setValue]);

  async function onSubmit(values: SaccoRouteFareFormValues) {
    // Check duplicate
    const existing = fares.find(
      (f) => f.from_stage_id === values.from_stage_id && f.to_stage_id === values.to_stage_id
    );
    if (existing) {
      toast.error('A fare for this stage pair already exists. Delete it first to replace it.');
      return;
    }

    const { error } = await supabase.from('sacco_route_fares').insert({
      sacco_route_id: selectedSaccoRoute,
      from_stage_id: values.from_stage_id,
      to_stage_id: values.to_stage_id,
      fare_offpeak: values.fare_offpeak,
      fare_peak: values.fare_peak,
    });

    if (error) {
      toast.error(`Failed: ${error.message}`);
    } else {
      toast.success('Fare record added');
      reset({ sacco_route_id: selectedSaccoRoute, from_stage_id: '', to_stage_id: '', fare_offpeak: 0, fare_peak: 0 });
      // Reload fares
      const { data } = await supabase.from('sacco_route_fares')
        .select('*, from_stage:from_stage_id(name), to_stage:to_stage_id(name)')
        .eq('sacco_route_id', selectedSaccoRoute);
      setFares((data as any) ?? []);
    }
  }

  async function deleteFare(id: string) {
    const { error } = await supabase.from('sacco_route_fares').delete().eq('id', id);
    if (error) { toast.error(error.message); } else {
      toast.success('Fare deleted');
      setFares((prev) => prev.filter((f) => f.id !== id));
    }
  }

  const fieldClass = 'w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-brand-500 bg-white';

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Stage-to-Stage Fares</h1>
        <p className="text-slate-500 mt-1 text-sm">
          Manage per-segment fares for a SACCO route. Only stages in the route sequence are selectable.
          Reverse-direction fares must be added separately.
        </p>
      </div>

      {/* SACCO Route selector */}
      <div className="bg-white rounded-xl border border-slate-200 p-5">
        <label className="block text-sm font-medium text-slate-700 mb-2">Select SACCO Route</label>
        {loading ? <p className="text-sm text-slate-400">Loading…</p> : (
          <select value={selectedSaccoRoute} onChange={(e) => setSelectedSaccoRoute(e.target.value)}
            className="w-full max-w-lg px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-brand-500">
            <option value="">Choose a SACCO route…</option>
            {saccoRoutes.map((sr: any) => (
              <option key={sr.id} value={sr.id}>
                {sr.saccos?.name} — [{sr.routes?.route_number}] {sr.routes?.origin_name} → {sr.routes?.destination_name}
              </option>
            ))}
          </select>
        )}
      </div>

      {selectedSaccoRoute && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Add fare form */}
          <div className="bg-white rounded-xl border border-slate-200 p-5">
            <h2 className="font-semibold text-slate-800 text-sm mb-4">Add Fare Record</h2>
            {routeStages.length < 2 ? (
              <div className="text-amber-600 text-xs">
                This route needs at least 2 stages in its sequence before you can add fares.
                <br />Go to <strong>Route Stage Sequences</strong> first.
              </div>
            ) : (
              <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                <input type="hidden" {...register('sacco_route_id')} />
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">From Stage <span className="text-red-500">*</span></label>
                  <select {...register('from_stage_id')} className={fieldClass}>
                    <option value="">Select origin stage…</option>
                    {routeStages.map((s: any) => (
                      <option key={s.id} value={s.id}>[{s.stop_order}] {s.name} — {s.area}</option>
                    ))}
                  </select>
                  {errors.from_stage_id && <p className="text-xs text-red-600 mt-1">{errors.from_stage_id.message}</p>}
                </div>
                <div>
                  <label className="block text-xs font-medium text-slate-600 mb-1">To Stage <span className="text-red-500">*</span></label>
                  <select {...register('to_stage_id')} className={fieldClass}>
                    <option value="">Select destination stage…</option>
                    {routeStages.map((s: any) => (
                      <option key={s.id} value={s.id}>[{s.stop_order}] {s.name} — {s.area}</option>
                    ))}
                  </select>
                  {errors.to_stage_id && <p className="text-xs text-red-600 mt-1">{errors.to_stage_id.message}</p>}
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-medium text-slate-600 mb-1">Off-Peak (KSh)</label>
                    <input type="number" min="0" {...register('fare_offpeak')} className={fieldClass} placeholder="30" />
                    {errors.fare_offpeak && <p className="text-xs text-red-600 mt-1">{errors.fare_offpeak.message}</p>}
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-slate-600 mb-1">Peak (KSh)</label>
                    <input type="number" min="0" {...register('fare_peak')} className={fieldClass} placeholder="50" />
                    {errors.fare_peak && <p className="text-xs text-red-600 mt-1">{errors.fare_peak.message}</p>}
                  </div>
                </div>
                <button type="submit" disabled={isSubmitting}
                  className="w-full inline-flex items-center justify-center gap-2 py-2.5 bg-brand-600
                             hover:bg-brand-700 text-white text-sm font-medium rounded-lg transition-colors">
                  <Plus size={14} /> Add Fare
                </button>
              </form>
            )}
          </div>

          {/* Existing fares */}
          <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
            <div className="px-5 py-4 border-b border-slate-100">
              <h2 className="font-semibold text-slate-800 text-sm">Existing Fares ({fares.length})</h2>
            </div>
            {fares.length === 0 ? (
              <div className="px-5 py-10 text-center text-slate-400 text-sm">No fares yet for this route.</div>
            ) : (
              <ul className="divide-y divide-slate-100">
                {fares.map((f: any) => (
                  <li key={f.id} className="flex items-center gap-3 px-5 py-3">
                    <div className="flex-1 text-sm">
                      <span className="font-medium text-slate-800">{f.from_stage?.name}</span>
                      <span className="text-slate-400 mx-2">→</span>
                      <span className="font-medium text-slate-800">{f.to_stage?.name}</span>
                    </div>
                    <div className="text-xs text-slate-500 text-right">
                      <div>Off-peak: KSh {f.fare_offpeak}</div>
                      <div>Peak: KSh {f.fare_peak}</div>
                    </div>
                    <button onClick={() => deleteFare(f.id)}
                      className="p-1.5 rounded hover:bg-red-50 text-slate-400 hover:text-red-600 transition-colors ml-2">
                      <Trash2 size={13} />
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
