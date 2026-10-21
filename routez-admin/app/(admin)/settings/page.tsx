import { createClient } from '@/lib/supabase/server';
import { redirect } from 'next/navigation';
import { Settings } from 'lucide-react';

export const dynamic = 'force-dynamic';

export default async function SettingsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in max-w-xl">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Settings</h1>
        <p className="text-slate-500 mt-1 text-sm">Account and application settings.</p>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
        <h2 className="font-semibold text-slate-800 text-sm">Signed-in account</h2>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-brand-100 flex items-center justify-center text-brand-700 font-bold text-sm">
            {user.email?.charAt(0).toUpperCase()}
          </div>
          <div>
            <div className="text-sm font-medium text-slate-800">{user.email}</div>
            <div className="text-xs text-slate-400">User ID: {user.id.slice(0, 8)}…</div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 p-6 space-y-4">
        <h2 className="font-semibold text-slate-800 text-sm">Database</h2>
        <div className="text-sm text-slate-600">
          Connected to:{' '}
          <code className="bg-slate-100 px-1.5 py-0.5 rounded text-xs">
            {process.env.NEXT_PUBLIC_SUPABASE_URL}
          </code>
        </div>
      </div>

      <div className="bg-amber-50 border border-amber-200 rounded-xl px-5 py-4 text-sm text-amber-800">
        <strong>Role-based access control</strong> is not yet enabled. All authenticated users currently
        have the same level of access. To add role separation (e.g. admin vs. data-entry),
        extend the <code className="bg-amber-100 px-1 rounded">auth.users</code> metadata or create
        a <code className="bg-amber-100 px-1 rounded">user_roles</code> table and update RLS policies accordingly.
      </div>
    </div>
  );
}
