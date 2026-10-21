'use client';

import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { saccoRouteSchema, type SaccoRouteFormValues } from '@/lib/validation/schemas';
import { createClient } from '@/lib/supabase/client';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import type { Sacco, Route, SaccoRoute } from '@/types/database';

const FLEET_OPTIONS = [
  'Matatu 14-seater',
  'Matatu 33-seater',
  'Bus 44-seater',
  'Bus 60-seater',
  'Mini-bus 25-seater',
];

export default function SaccoRouteForm({ existing }: { existing?: SaccoRoute }) {
  const router = useRouter();
  const supabase = createClient();
  const isEdit = !!existing;

  const [saccos, setSaccos] = useState<{ id: string; name: string }[]>([]);
  const [routes, setRoutes] = useState<{ id: string; route_number: string; origin_name: string; destination_name: string }[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      const [saccoRes, routeRes] = await Promise.all([
        supabase.from('saccos').select('id, name').order('name'),
        supabase.from('routes').select('id, route_number, origin_name, destination_name').order('route_number'),
      ]);
      setSaccos((saccoRes.data as any[]) ?? []);
      setRoutes((routeRes.data as any[]) ?? []);
      setLoading(false);
    }
    loadData();
  }, []);

  const { register, handleSubmit, watch, formState: { errors, isSubmitting } } = useForm<SaccoRouteFormValues>({
    resolver: zodResolver(saccoRouteSchema),
    defaultValues: existing
      ? {
          sacco_id: existing.sacco_id,
          route_id: existing.route_id,
          fare_offpeak: existing.fare_offpeak,
          fare_peak: existing.fare_peak,
          typical_duration_mins: existing.typical_duration_mins,
          fleet_type: existing.fleet_type,
          is_express: existing.is_express,
          is_active: existing.is_active,
        }
      : { fleet_type: 'Matatu 14-seater', is_express: false, is_active: true },
  });

  const selectedRouteId = watch('route_id');
  const selectedRoute = routes.find((r) => r.id === selectedRouteId);

  async function onSubmit(values: SaccoRouteFormValues) {
    const payload = {
      sacco_id: values.sacco_id,
      route_id: values.route_id,
      fare_offpeak: values.fare_offpeak,
      fare_peak: values.fare_peak,
      typical_duration_mins: values.typical_duration_mins,
      fleet_type: values.fleet_type,
      is_express: values.is_express,
      is_active: values.is_active,
    };

    const { error } = isEdit
      ? await supabase.from('sacco_routes').update(payload).eq('id', existing!.id)
      : await supabase.from('sacco_routes').insert(payload);

    if (error) {
      toast.error(`Failed to save: ${error.message}`);
    } else {
      toast.success(isEdit ? 'Operation updated' : 'Operation created');
      router.push('/sacco-routes');
      router.refresh();
    }
  }

  const fieldClass = `w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
    focus:ring-2 focus:ring-brand-500 focus:border-brand-500 bg-white`;

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in max-w-2xl">
      <div>
        <Link href="/sacco-routes" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700 mb-4">
          <ArrowLeft size={14} /> Back
        </Link>
        <h1 className="text-2xl font-bold text-slate-900">
          {isEdit ? 'Edit SACCO Route Operation' : 'Add SACCO Route Operation'}
        </h1>
        <p className="text-slate-500 mt-1 text-sm">
          Links a SACCO to a master route. The fares here are the full-route default fares (origin → destination).
        </p>
      </div>

      {loading ? (
        <div className="text-slate-400 text-sm">Loading SACCOs and routes…</div>
      ) : (
        <form onSubmit={handleSubmit(onSubmit)} className="bg-white rounded-xl border border-slate-200 p-6 space-y-5">
          {/* SACCO */}
          <div>
            <label htmlFor="sacco_id" className="block text-sm font-medium text-slate-700 mb-1.5">
              SACCO <span className="text-red-500">*</span>
            </label>
            {saccos.length === 0 ? (
              <p className="text-xs text-amber-600">No SACCOs found. <Link href="/saccos/new" className="underline">Add a SACCO first</Link>.</p>
            ) : (
              <select id="sacco_id" {...register('sacco_id')} className={fieldClass}>
                <option value="">Select a SACCO…</option>
                {saccos.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
              </select>
            )}
            {errors.sacco_id && <p className="text-xs text-red-600 mt-1">{errors.sacco_id.message}</p>}
          </div>

          {/* Route */}
          <div>
            <label htmlFor="route_id" className="block text-sm font-medium text-slate-700 mb-1.5">
              Route <span className="text-red-500">*</span>
            </label>
            {routes.length === 0 ? (
              <p className="text-xs text-amber-600">No routes found. <Link href="/routes/new" className="underline">Add a route first</Link>.</p>
            ) : (
              <select id="route_id" {...register('route_id')} className={fieldClass}>
                <option value="">Select a route…</option>
                {routes.map((r) => (
                  <option key={r.id} value={r.id}>
                    [{r.route_number}] {r.origin_name} → {r.destination_name}
                  </option>
                ))}
              </select>
            )}
            {selectedRoute && (
              <p className="text-xs text-slate-400 mt-1">
                Full route: {selectedRoute.origin_name} → {selectedRoute.destination_name}
              </p>
            )}
            {errors.route_id && <p className="text-xs text-red-600 mt-1">{errors.route_id.message}</p>}
          </div>

          {/* Fares */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="fare_offpeak" className="block text-sm font-medium text-slate-700 mb-1.5">
                Off-Peak Fare (KSh) <span className="text-red-500">*</span>
              </label>
              <input id="fare_offpeak" {...register('fare_offpeak')} type="number" min="0" placeholder="50"
                className={fieldClass} />
              {errors.fare_offpeak && <p className="text-xs text-red-600 mt-1">{errors.fare_offpeak.message}</p>}
            </div>
            <div>
              <label htmlFor="fare_peak" className="block text-sm font-medium text-slate-700 mb-1.5">
                Peak Fare (KSh) <span className="text-red-500">*</span>
              </label>
              <input id="fare_peak" {...register('fare_peak')} type="number" min="0" placeholder="80"
                className={fieldClass} />
              {errors.fare_peak && <p className="text-xs text-red-600 mt-1">{errors.fare_peak.message}</p>}
            </div>
          </div>

          {/* Duration & Fleet */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="typical_duration_mins" className="block text-sm font-medium text-slate-700 mb-1.5">
                Journey Duration (minutes) <span className="text-red-500">*</span>
              </label>
              <input id="typical_duration_mins" {...register('typical_duration_mins')} type="number" min="1" placeholder="45"
                className={fieldClass} />
              {errors.typical_duration_mins && <p className="text-xs text-red-600 mt-1">{errors.typical_duration_mins.message}</p>}
            </div>
            <div>
              <label htmlFor="fleet_type" className="block text-sm font-medium text-slate-700 mb-1.5">Fleet Type</label>
              <select id="fleet_type" {...register('fleet_type')} className={fieldClass}>
                {FLEET_OPTIONS.map((f) => <option key={f} value={f}>{f}</option>)}
              </select>
            </div>
          </div>

          {/* Booleans */}
          <div className="flex items-center gap-6">
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" {...register('is_express')} className="w-4 h-4 rounded accent-brand-600" />
              <span className="text-sm text-slate-700">Express service</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" {...register('is_active')} className="w-4 h-4 rounded accent-brand-600" />
              <span className="text-sm text-slate-700">Currently active</span>
            </label>
          </div>

          <div className="flex items-center gap-3 pt-2">
            <button type="submit" disabled={isSubmitting}
              className="px-5 py-2.5 bg-brand-600 hover:bg-brand-700 disabled:bg-brand-300
                         text-white text-sm font-medium rounded-lg transition-colors">
              {isSubmitting ? 'Saving…' : isEdit ? 'Save Changes' : 'Create Operation'}
            </button>
            <Link href="/sacco-routes"
              className="px-5 py-2.5 border border-slate-300 hover:bg-slate-50 text-slate-600
                         text-sm font-medium rounded-lg transition-colors">
              Cancel
            </Link>
          </div>
        </form>
      )}
    </div>
  );
}
