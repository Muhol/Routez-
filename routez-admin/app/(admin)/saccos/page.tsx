import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import { Plus, Bus, Star } from 'lucide-react';
import DeleteButton from '../routes/DeleteButton';

export const dynamic = 'force-dynamic';

export default async function SaccosPage() {
  const supabase = await createClient();
  const { data: saccos, error } = await supabase
    .from('saccos')
    .select('id, name, contact_phone, rating, logo_url, created_at')
    .order('name');

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">SACCOs</h1>
          <p className="text-slate-500 mt-1 text-sm">
            Matatu savings and credit co-operatives that operate routes.
          </p>
        </div>
        <Link href="/saccos/new"
          className="inline-flex items-center gap-2 px-4 py-2 bg-brand-600 hover:bg-brand-700
                     text-white text-sm font-medium rounded-lg transition-colors">
          <Plus size={15} /> Add SACCO
        </Link>
      </div>

      {error && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-700 text-sm">
          Failed to load SACCOs: {error.message}
        </div>
      )}

      {!error && saccos?.length === 0 && (
        <div className="text-center py-20 bg-white rounded-xl border border-slate-200">
          <Bus size={36} className="mx-auto text-slate-300 mb-3" />
          <p className="text-slate-500 text-sm">No SACCOs yet.</p>
          <Link href="/saccos/new" className="mt-3 inline-block text-brand-600 hover:underline text-sm font-medium">
            Add your first SACCO →
          </Link>
        </div>
      )}

      {saccos && saccos.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {saccos.map((s) => (
            <div key={s.id} className="bg-white rounded-xl border border-slate-200 p-5 hover:border-brand-300 hover:shadow-sm transition-all">
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  {s.logo_url ? (
                    <img src={s.logo_url} alt={s.name} className="w-10 h-10 rounded-full object-cover border border-slate-200" />
                  ) : (
                    <div className="w-10 h-10 rounded-full bg-brand-100 flex items-center justify-center text-brand-700 font-bold text-sm">
                      {s.name.charAt(0).toUpperCase()}
                    </div>
                  )}
                  <div>
                    <div className="font-semibold text-slate-900 text-sm">{s.name}</div>
                    {s.contact_phone && (
                      <div className="text-xs text-slate-400">{s.contact_phone}</div>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-1 text-amber-500 text-xs font-medium">
                  <Star size={12} fill="currentColor" />
                  {s.rating}
                </div>
              </div>
              <div className="flex items-center justify-end gap-2">
                <Link href={`/saccos/${s.id}/edit`}
                  className="text-xs px-3 py-1.5 border border-slate-300 hover:bg-slate-50
                             text-slate-600 rounded-lg transition-colors">
                  Edit
                </Link>
                <DeleteButton id={s.id} label={s.name} table="saccos" />
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
