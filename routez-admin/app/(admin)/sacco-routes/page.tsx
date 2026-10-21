import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import { Plus, Link2, CheckCircle2, XCircle } from 'lucide-react';
import DeleteButton from '../routes/DeleteButton';

export const dynamic = 'force-dynamic';

export default async function SaccoRoutesPage() {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('sacco_routes')
    .select('id, fare_offpeak, fare_peak, typical_duration_mins, fleet_type, is_express, is_active, saccos(name), routes(route_number, origin_name, destination_name)')
    .order('created_at', { ascending: false });

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">SACCO Route Operations</h1>
          <p className="text-slate-500 mt-1 text-sm">
            Each record links a SACCO to a master route with specific fares and fleet details.
          </p>
        </div>
        <Link href="/sacco-routes/new"
          className="inline-flex items-center gap-2 px-4 py-2 bg-brand-600 hover:bg-brand-700
                     text-white text-sm font-medium rounded-lg transition-colors">
          <Plus size={15} /> Add Operation
        </Link>
      </div>

      {error && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-700 text-sm">
          {error.message}
        </div>
      )}

      {!error && (!data || data.length === 0) && (
        <div className="text-center py-20 bg-white rounded-xl border border-slate-200">
          <Link2 size={36} className="mx-auto text-slate-300 mb-3" />
          <p className="text-slate-500 text-sm">No SACCO route operations yet.</p>
          <Link href="/sacco-routes/new" className="mt-3 inline-block text-brand-600 hover:underline text-sm font-medium">
            Link a SACCO to a route →
          </Link>
        </div>
      )}

      {data && data.length > 0 && (
        <div className="bg-white rounded-xl border border-slate-200 overflow-x-auto">
          <table className="w-full text-sm data-table">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-5 py-3 font-medium text-slate-600">SACCO</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600">Route</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden md:table-cell">Off-Peak Fare</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden md:table-cell">Peak Fare</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden lg:table-cell">Duration</th>
                <th className="text-left px-5 py-3 font-medium text-slate-600 hidden lg:table-cell">Fleet</th>
                <th className="text-center px-5 py-3 font-medium text-slate-600">Active</th>
                <th className="text-right px-5 py-3 font-medium text-slate-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.map((sr: any) => (
                <tr key={sr.id}>
                  <td className="px-5 py-3 font-medium text-slate-800">{sr.saccos?.name ?? '—'}</td>
                  <td className="px-5 py-3 text-slate-600">
                    <span className="inline-flex items-center px-2 py-0.5 rounded bg-brand-50 text-brand-700 font-bold text-xs mr-2">
                      {sr.routes?.route_number}
                    </span>
                    <span className="text-xs text-slate-500">{sr.routes?.origin_name} → {sr.routes?.destination_name}</span>
                  </td>
                  <td className="px-5 py-3 text-slate-600 hidden md:table-cell">KSh {sr.fare_offpeak}</td>
                  <td className="px-5 py-3 text-slate-600 hidden md:table-cell">KSh {sr.fare_peak}</td>
                  <td className="px-5 py-3 text-slate-500 hidden lg:table-cell">{sr.typical_duration_mins} min</td>
                  <td className="px-5 py-3 text-slate-500 hidden lg:table-cell text-xs">{sr.fleet_type}</td>
                  <td className="px-5 py-3 text-center">
                    {sr.is_active
                      ? <CheckCircle2 size={16} className="text-emerald-500 mx-auto" />
                      : <XCircle size={16} className="text-slate-300 mx-auto" />
                    }
                  </td>
                  <td className="px-5 py-3">
                    <div className="flex items-center justify-end gap-2">
                      <Link href={`/sacco-routes/${sr.id}/edit`}
                        className="p-1.5 rounded hover:bg-slate-100 text-slate-500 hover:text-slate-700 transition-colors text-xs">
                        ✏️
                      </Link>
                      <DeleteButton id={sr.id} label="this operation" table="sacco_routes" />
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
