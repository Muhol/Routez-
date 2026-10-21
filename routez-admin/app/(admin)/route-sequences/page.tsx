'use client';

import { useEffect, useState, useCallback } from 'react';
import { createClient } from '@/lib/supabase/client';
import { toast } from 'sonner';
import { GripVertical, Plus, Trash2, ArrowUp, ArrowDown, Save } from 'lucide-react';
import { DndContext, closestCenter, KeyboardSensor, PointerSensor, useSensor, useSensors, DragEndEvent } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy, useSortable, arrayMove } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import type { Stage, SaccoRoute, SaccoRouteStage } from '@/types/database';

interface SequenceRow extends SaccoRouteStage {
  stage_name: string;
  stage_area: string;
}

function SortableRow({
  row, index, total, stages, allRows,
  onUpdate, onRemove, onMove,
}: {
  row: SequenceRow; index: number; total: number; stages: Stage[]; allRows: SequenceRow[];
  onUpdate: (id: string, field: keyof SequenceRow, value: number) => void;
  onRemove: (id: string) => void;
  onMove: (index: number, dir: 1 | -1) => void;
}) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: row.id });
  const style = { transform: CSS.Transform.toString(transform), transition, opacity: isDragging ? 0.5 : 1 };

  return (
    <tr ref={setNodeRef} style={style} className="group">
      <td className="px-3 py-2 text-slate-400 w-8">
        <button {...attributes} {...listeners} className="cursor-grab active:cursor-grabbing p-1">
          <GripVertical size={14} />
        </button>
      </td>
      <td className="px-3 py-2 text-slate-500 text-center text-xs font-mono w-12">{index + 1}</td>
      <td className="px-3 py-2">
        <div className="text-sm font-medium text-slate-800">{row.stage_name}</div>
        <div className="text-xs text-slate-400">{row.stage_area}</div>
      </td>
      <td className="px-3 py-2 hidden md:table-cell">
        <input
          type="number" min="0" step="0.1" value={row.distance_from_start_km}
          onChange={(e) => onUpdate(row.id, 'distance_from_start_km', parseFloat(e.target.value) || 0)}
          className="w-20 px-2 py-1 rounded border border-slate-300 text-xs focus:outline-none focus:ring-1 focus:ring-brand-500"
        />
      </td>
      <td className="px-3 py-2 hidden md:table-cell">
        <input
          type="number" min="0" step="1" value={row.eta_from_start_mins}
          onChange={(e) => onUpdate(row.id, 'eta_from_start_mins', parseInt(e.target.value) || 0)}
          className="w-16 px-2 py-1 rounded border border-slate-300 text-xs focus:outline-none focus:ring-1 focus:ring-brand-500"
        />
      </td>
      <td className="px-3 py-2">
        <div className="flex items-center gap-1">
          <button onClick={() => onMove(index, -1)} disabled={index === 0}
            className="p-1 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-700 disabled:opacity-20 transition-colors">
            <ArrowUp size={12} />
          </button>
          <button onClick={() => onMove(index, 1)} disabled={index === total - 1}
            className="p-1 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-700 disabled:opacity-20 transition-colors">
            <ArrowDown size={12} />
          </button>
          <button onClick={() => onRemove(row.id)}
            className="p-1 rounded hover:bg-red-50 text-slate-400 hover:text-red-600 transition-colors">
            <Trash2 size={12} />
          </button>
        </div>
      </td>
    </tr>
  );
}

export default function RouteSequenceBuilder() {
  const supabase = createClient();

  const [saccoRoutes, setSaccoRoutes] = useState<any[]>([]);
  const [stages, setStages] = useState<any[]>([]);
  const [selectedSaccoRoute, setSelectedSaccoRoute] = useState('');
  const [rows, setRows] = useState<SequenceRow[]>([]);
  const [addStageId, setAddStageId] = useState('');
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(true);

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor)
  );

  useEffect(() => {
    async function load() {
      const [srRes, sRes] = await Promise.all([
        supabase.from('sacco_routes').select('id, sacco_id, route_id, saccos(name), routes(route_number, origin_name, destination_name)').order('created_at', { ascending: false }),
        supabase.from('stages').select('id, name, area, latitude, longitude').order('name'),
      ]);
      setSaccoRoutes((srRes.data as any[]) ?? []);
      setStages((sRes.data as any[]) ?? []);
      setLoading(false);
    }
    load();
  }, []);

  useEffect(() => {
    if (!selectedSaccoRoute) { setRows([]); return; }
    async function loadSequence() {
      const { data } = await supabase
        .from('sacco_route_stages')
        .select('id, sacco_route_id, stage_id, stop_order, distance_from_start_km, eta_from_start_mins, stages(name, area)')
        .eq('sacco_route_id', selectedSaccoRoute)
        .order('stop_order');
      setRows(
        (data ?? []).map((r: any) => ({
          ...r,
          distance_from_start_km: Number(r.distance_from_start_km),
          stage_name: r.stages?.name ?? '?',
          stage_area: r.stages?.area ?? '',
        }))
      );
    }
    loadSequence();
  }, [selectedSaccoRoute]);

  function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    if (active.id !== over?.id) {
      setRows((prev) => {
        const oldIdx = prev.findIndex((r) => r.id === active.id);
        const newIdx = prev.findIndex((r) => r.id === over!.id);
        return arrayMove(prev, oldIdx, newIdx);
      });
    }
  }

  function handleUpdate(id: string, field: keyof SequenceRow, value: number) {
    setRows((prev) => prev.map((r) => r.id === id ? { ...r, [field]: value } : r));
  }

  function handleRemove(id: string) {
    setRows((prev) => prev.filter((r) => r.id !== id));
  }

  function handleMove(index: number, dir: 1 | -1) {
    setRows((prev) => arrayMove(prev, index, index + dir));
  }

  function handleAddStage() {
    if (!addStageId) return;
    const stage = stages.find((s) => s.id === addStageId);
    if (!stage) return;
    if (rows.some((r) => r.stage_id === addStageId)) {
      toast.error(`"${stage.name}" is already in this sequence.`);
      return;
    }
    const tempId = `new-${Date.now()}`;
    setRows((prev) => [
      ...prev,
      {
        id: tempId, sacco_route_id: selectedSaccoRoute, stage_id: stage.id,
        stop_order: prev.length + 1, distance_from_start_km: 0, eta_from_start_mins: 0,
        stage_name: stage.name, stage_area: stage.area,
      },
    ]);
    setAddStageId('');
  }

  async function handleSave() {
    if (!selectedSaccoRoute) return;
    setSaving(true);

    // Delete existing, then insert new sequence
    const { error: delErr } = await supabase
      .from('sacco_route_stages')
      .delete()
      .eq('sacco_route_id', selectedSaccoRoute);

    if (delErr) {
      toast.error(`Failed to clear sequence: ${delErr.message}`);
      setSaving(false);
      return;
    }

    const payload = rows.map((r, i) => ({
      sacco_route_id: selectedSaccoRoute,
      stage_id: r.stage_id,
      stop_order: i + 1,
      distance_from_start_km: r.distance_from_start_km,
      eta_from_start_mins: r.eta_from_start_mins,
    }));

    const { error: insErr } = await supabase.from('sacco_route_stages').insert(payload);

    if (insErr) {
      toast.error(`Failed to save sequence: ${insErr.message}`);
    } else {
      toast.success('Stage sequence saved');
      // Reload to get real IDs
      const { data } = await supabase
        .from('sacco_route_stages')
        .select('id, sacco_route_id, stage_id, stop_order, distance_from_start_km, eta_from_start_mins, stages(name, area)')
        .eq('sacco_route_id', selectedSaccoRoute)
        .order('stop_order');
      setRows((data ?? []).map((r: any) => ({
        ...r, distance_from_start_km: Number(r.distance_from_start_km),
        stage_name: r.stages?.name ?? '?', stage_area: r.stages?.area ?? '',
      })));
    }
    setSaving(false);
  }

  const availableStages = stages.filter((s) => !rows.some((r) => r.stage_id === s.id));

  if (loading) return <div className="p-8 text-slate-400 text-sm">Loading…</div>;

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Route Stage Sequences</h1>
        <p className="text-slate-500 mt-1 text-sm">
          Build the ordered stop sequence for a SACCO route. Drag to reorder. Each stage can only appear once.
        </p>
      </div>

      {/* SACCO Route selector */}
      <div className="bg-white rounded-xl border border-slate-200 p-5">
        <label htmlFor="sacco_route_select" className="block text-sm font-medium text-slate-700 mb-2">
          Select SACCO Route
        </label>
        {saccoRoutes.length === 0 ? (
          <p className="text-xs text-amber-600">No SACCO route operations found. Create one first in SACCO Route Operations.</p>
        ) : (
          <select id="sacco_route_select" value={selectedSaccoRoute}
            onChange={(e) => setSelectedSaccoRoute(e.target.value)}
            className="w-full max-w-lg px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm bg-white
                       focus:outline-none focus:ring-2 focus:ring-brand-500">
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
        <>
          {/* Sequence table */}
          <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
            <div className="flex items-center justify-between px-5 py-4 border-b border-slate-100">
              <h2 className="font-semibold text-slate-800 text-sm">
                Stage Sequence ({rows.length} stops)
              </h2>
              <button onClick={handleSave} disabled={saving}
                className="inline-flex items-center gap-2 px-4 py-2 bg-brand-600 hover:bg-brand-700
                           disabled:bg-brand-300 text-white text-xs font-medium rounded-lg transition-colors">
                <Save size={13} /> {saving ? 'Saving…' : 'Save Sequence'}
              </button>
            </div>

            {rows.length === 0 ? (
              <div className="px-5 py-10 text-center text-slate-400 text-sm">
                No stages yet. Add stages below.
              </div>
            ) : (
              <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
                <SortableContext items={rows.map((r) => r.id)} strategy={verticalListSortingStrategy}>
                  <table className="w-full text-sm">
                    <thead className="bg-slate-50 border-b border-slate-200">
                      <tr>
                        <th className="px-3 py-2 w-8"></th>
                        <th className="px-3 py-2 text-xs font-medium text-slate-500 text-center">#</th>
                        <th className="px-3 py-2 text-left text-xs font-medium text-slate-500">Stage</th>
                        <th className="px-3 py-2 text-left text-xs font-medium text-slate-500 hidden md:table-cell">Distance (km)</th>
                        <th className="px-3 py-2 text-left text-xs font-medium text-slate-500 hidden md:table-cell">ETA (min)</th>
                        <th className="px-3 py-2 text-left text-xs font-medium text-slate-500">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {rows.map((row, i) => (
                        <SortableRow
                          key={row.id} row={row} index={i} total={rows.length}
                          stages={stages} allRows={rows}
                          onUpdate={handleUpdate} onRemove={handleRemove} onMove={handleMove}
                        />
                      ))}
                    </tbody>
                  </table>
                </SortableContext>
              </DndContext>
            )}

            {/* Add stage */}
            <div className="flex items-center gap-3 px-5 py-4 border-t border-slate-100 bg-slate-50">
              <select value={addStageId} onChange={(e) => setAddStageId(e.target.value)}
                className="flex-1 max-w-sm px-3 py-2 rounded-lg border border-slate-300 text-sm bg-white
                           focus:outline-none focus:ring-2 focus:ring-brand-500">
                <option value="">Add a stage to this route…</option>
                {availableStages.map((s) => (
                  <option key={s.id} value={s.id}>{s.name} — {s.area}</option>
                ))}
              </select>
              <button onClick={handleAddStage} disabled={!addStageId}
                className="inline-flex items-center gap-2 px-4 py-2 border border-slate-300 hover:bg-white
                           text-slate-700 text-sm font-medium rounded-lg transition-colors disabled:opacity-40">
                <Plus size={14} /> Add
              </button>
            </div>
          </div>

          <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-amber-700 text-xs">
            <strong>Note:</strong> Saving replaces the entire sequence for this SACCO route. Distance and ETA values are optional — enter 0 if unknown. Do not invent values.
          </div>
        </>
      )}
    </div>
  );
}
