import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import { Plus, MapPin } from 'lucide-react';
import DeleteButton from '../routes/DeleteButton';

export const dynamic = 'force-dynamic';

export default async function StagesPage() {
  const supabase = await createClient();
  const { data: stages, error } = await supabase
    .from('stages')
    .select('id, name, area, latitude, longitude, created_at')
    .order('name');

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Stages & Stops</h1>
          <p className="text-slate-500 mt-1 text-sm">
            Physical bus stops. Each stage requires a name, area, and valid GPS coordinates.
          </p>
        </div>
        <Link
          href="/stages/new"
          className="inline-flex items-center gap-2 px-4 py-2 bg-brand-600 hover:bg-brand-700
                     text-white text-sm font-medium rounded-lg transition-colors"
        >
          <Plus size={15} /> Add Stage
        </Link>
      </div>

      {error && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-700 text-sm">
          Failed to load stages: {error.message}
        </div>
      )}

      {!error && stages?.length === 0 && (
        <div className="text-center py-20 bg-white rounded-xl border border-slate-200">
          <MapPin size={36} className="mx-auto text-slate-300 mb-3" />
          <p className="text-slate-500 text-sm">No stages yet.</p>
          <Link href="/stages/new" className="mt-3 inline-block text-brand-600 hover:underline text-sm font-medium">
            Add your first stage →
          </Link>
        </div>
      )}

      {stages && stages.length > 0 && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="w-full text-sm data-table">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-5 py-3 font-medium text-slate-600">Stage Name</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden sm:table-cell">Area</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden lg:table-cell">Latitude</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden lg:table-cell">Longitude</th>
                <th className="text-right px-5 py-3 font-medium text-slate-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {stages.map((s) => (
                <tr key={s.id}>
                  <td className="px-5 py-3 font-medium text-slate-800">{s.name}</td>
                  <td className="px-5 py-3 text-slate-500 hidden sm:table-cell">{s.area}</td>
                  <td className="px-5 py-3 text-slate-500 font-mono text-xs hidden lg:table-cell">
                    {s.latitude.toFixed(7)}
                  </td>
                  <td className="px-5 py-3 text-slate-500 font-mono text-xs hidden lg:table-cell">
                    {s.longitude.toFixed(7)}
                  </td>
                  <td className="px-5 py-3">
                    <div className="flex items-center justify-end gap-2">
                      <Link
                        href={`/stages/${s.id}/edit`}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-500 hover:text-slate-700 transition-colors"
                        title="Edit"
                      >
                        ✏️
                      </Link>
                      <DeleteButton id={s.id} label={s.name} table="stages" />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
