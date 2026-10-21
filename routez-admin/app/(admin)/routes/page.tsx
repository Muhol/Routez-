import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import { Plus, Pencil, Trash2, Route } from 'lucide-react';
import DeleteButton from './DeleteButton';

export const dynamic = 'force-dynamic';

export default async function RoutesPage() {
  const supabase = await createClient();
  const { data: routes, error } = await supabase
    .from('routes')
    .select('id, route_number, origin_name, destination_name, created_at')
    .order('route_number');

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Routes</h1>
          <p className="text-slate-500 mt-1 text-sm">
            Master list of matatu routes. Create routes with all SACCOs, stages, and fares in one flow.
          </p>
        </div>
        <Link
          href="/routes/new"
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-brand-600 hover:bg-brand-700
                     text-white text-sm font-bold rounded-xl shadow-sm transition-all"
        >
          <Plus size={16} /> + New Route Wizard
        </Link>
      </div>

      {error && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-700 text-sm">
          Failed to load routes: {error.message}
        </div>
      )}

      {!error && routes?.length === 0 && (
        <div className="text-center py-20 bg-white rounded-xl border border-slate-200">
          <Route size={36} className="mx-auto text-slate-300 mb-3" />
          <p className="text-slate-500 text-sm">No routes yet.</p>
          <Link href="/routes/new" className="mt-3 inline-block text-brand-600 hover:underline text-sm font-medium">
            Add your first route →
          </Link>
        </div>
      )}

      {routes && routes.length > 0 && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <table className="w-full text-sm data-table">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-5 py-3 font-medium text-slate-600 w-24">Number</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600">Origin</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600">Destination</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden md:table-cell">Added</th>
                <th className="text-right px-5 py-3 font-medium text-slate-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {routes.map((r) => (
                <tr key={r.id}>
                  <td className="px-5 py-3">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded bg-brand-50 text-brand-700 font-bold text-xs">
                      {r.route_number}
                    </span>
                  </td>
                  <td className="px-5 py-3 text-slate-700">{r.origin_name}</td>
                  <td className="px-5 py-3 text-slate-700">{r.destination_name}</td>
                  <td className="px-5 py-3 text-slate-400 hidden md:table-cell">
                    {new Date(r.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-5 py-3">
                    <div className="flex items-center justify-end gap-2">
                      <Link
                        href={`/routes/${r.id}/edit`}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-500 hover:text-slate-700 transition-colors"
                        title="Edit"
                      >
                        <Pencil size={14} />
                      </Link>
                      <DeleteButton id={r.id} label={`Route ${r.route_number}`} table="routes" />
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
