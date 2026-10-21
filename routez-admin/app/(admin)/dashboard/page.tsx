import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import {
  Route, MapPin, Bus, Link2, ListOrdered, DollarSign, ShieldCheck,
  Plus, ArrowRight, Sparkles, CheckCircle
} from 'lucide-react';

async function getStats() {
  const supabase = await createClient();
  const [routes, stages, saccos, saccoRoutes, routeStages, fares] = await Promise.all([
    supabase.from('routes').select('id', { count: 'exact', head: true }),
    supabase.from('stages').select('id', { count: 'exact', head: true }),
    supabase.from('saccos').select('id', { count: 'exact', head: true }),
    supabase.from('sacco_routes').select('id', { count: 'exact', head: true }),
    supabase.from('sacco_route_stages').select('id', { count: 'exact', head: true }),
    supabase.from('sacco_route_fares').select('id', { count: 'exact', head: true }),
  ]);
  return {
    totalRoutes: routes.count ?? 0,
    totalStages: stages.count ?? 0,
    totalSaccos: saccos.count ?? 0,
    totalSaccoRoutes: saccoRoutes.count ?? 0,
    totalRouteStages: routeStages.count ?? 0,
    totalFares: fares.count ?? 0,
  };
}

async function getRecentRoutes() {
  const supabase = await createClient();
  const { data } = await supabase
    .from('routes')
    .select('id, route_number, origin_name, destination_name, created_at')
    .order('created_at', { ascending: false })
    .limit(6);
  return data ?? [];
}

const STAT_CARDS = [
  { label: 'Routes', icon: Route, color: 'bg-blue-50 text-blue-600', href: '/routes' },
  { label: 'Stages', icon: MapPin, color: 'bg-emerald-50 text-emerald-600', href: '/stages' },
  { label: 'SACCOs', icon: Bus, color: 'bg-violet-50 text-violet-600', href: '/saccos' },
  { label: 'Route Operations', icon: Link2, color: 'bg-amber-50 text-amber-600', href: '/sacco-routes' },
  { label: 'Stage Sequences', icon: ListOrdered, color: 'bg-sky-50 text-sky-600', href: '/route-sequences' },
  { label: 'Fare Records', icon: DollarSign, color: 'bg-teal-50 text-teal-600', href: '/fares' },
  { label: 'Data Quality', icon: ShieldCheck, color: 'bg-indigo-50 text-indigo-600', href: '/data-quality' },
];

export default async function DashboardPage() {
  const [stats, recentRoutes] = await Promise.all([
    getStats(),
    getRecentRoutes(),
  ]);

  const statValues = [
    stats.totalRoutes, stats.totalStages, stats.totalSaccos,
    stats.totalSaccoRoutes, stats.totalRouteStages, stats.totalFares, stats.totalRoutes > 0 ? '100%' : '0%',
  ];

  return (
    <div className="p-6 lg:p-8 space-y-8 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Dashboard</h1>
        <p className="text-slate-500 mt-1 text-sm">Overview of your Routez database</p>
      </div>

      {/* Quick Actions */}
      <div className="flex flex-wrap gap-3">
        <Link href="/routes/new"
          className="inline-flex items-center gap-2 px-4 py-2 bg-brand-600 hover:bg-brand-700
                     text-white text-sm font-medium rounded-lg transition-colors shadow-sm">
          <Sparkles size={15} /> Route Studio (Wizard)
        </Link>
        <Link href="/stages/new"
          className="inline-flex items-center gap-2 px-4 py-2 bg-white border border-slate-300
                     hover:bg-slate-50 text-slate-700 text-sm font-medium rounded-lg transition-colors">
          <Plus size={15} /> Add Stage
        </Link>
        <Link href="/saccos/new"
          className="inline-flex items-center gap-2 px-4 py-2 bg-white border border-slate-300
                     hover:bg-slate-50 text-slate-700 text-sm font-medium rounded-lg transition-colors">
          <Plus size={15} /> Add SACCO
        </Link>
        <Link href="/fares"
          className="inline-flex items-center gap-2 px-4 py-2 bg-white border border-slate-300
                     hover:bg-slate-50 text-slate-700 text-sm font-medium rounded-lg transition-colors">
          <DollarSign size={15} /> Segment Fares
        </Link>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-7 gap-4">
        {STAT_CARDS.map(({ label, icon: Icon, color, href }, i) => (
          <Link key={href} href={href}
            className="bg-white rounded-xl border border-slate-200 p-4 hover:border-brand-300
                       hover:shadow-sm transition-all group">
            <div className={`w-9 h-9 rounded-lg ${color} flex items-center justify-center mb-3`}>
              <Icon size={18} />
            </div>
            <div className="text-2xl font-bold text-slate-900">{statValues[i]}</div>
            <div className="text-xs text-slate-500 mt-0.5 group-hover:text-brand-600 transition-colors">
              {label}
            </div>
          </Link>
        ))}
      </div>

      {/* Lower section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Routes */}
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <div className="flex items-center justify-between px-5 py-4 border-b border-slate-100">
            <h2 className="font-semibold text-slate-800 text-sm">Recent Routes</h2>
            <Link href="/routes" className="text-xs text-brand-600 hover:underline flex items-center gap-1">
              View all <ArrowRight size={12} />
            </Link>
          </div>
          {recentRoutes.length === 0 ? (
            <div className="px-5 py-10 text-center text-slate-400 text-sm">
              No routes yet.{' '}
              <Link href="/routes/new" className="text-brand-600 hover:underline">Add your first route →</Link>
            </div>
          ) : (
            <ul className="divide-y divide-slate-100">
              {recentRoutes.map((r) => (
                <li key={r.id}>
                  <Link href={`/routes/${r.id}`}
                    className="flex items-center gap-3 px-5 py-3 hover:bg-slate-50 transition-colors">
                    <span className="inline-flex items-center justify-center w-9 h-7 rounded bg-brand-50 text-brand-700 text-xs font-bold shrink-0">
                      {r.route_number}
                    </span>
                    <span className="text-sm text-slate-700 flex-1 truncate">
                      {r.origin_name} → {r.destination_name}
                    </span>
                    <span className="text-xs text-slate-400">
                      {new Date(r.created_at).toLocaleDateString()}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Quick Management Links */}
        <div className="bg-white rounded-xl border border-slate-200 overflow-hidden">
          <div className="flex items-center justify-between px-5 py-4 border-b border-slate-100">
            <h2 className="font-semibold text-slate-800 text-sm">Database Operations</h2>
            <Link href="/data-quality" className="text-xs text-brand-600 hover:underline flex items-center gap-1">
              Audit data <ArrowRight size={12} />
            </Link>
          </div>
          <div className="p-5 space-y-3">
            <div className="flex items-center justify-between p-3 rounded-lg bg-slate-50 border border-slate-100">
              <div className="flex items-center gap-3">
                <Sparkles size={18} className="text-brand-600" />
                <div>
                  <div className="text-xs font-bold text-slate-800">Route Studio Wizard</div>
                  <div className="text-[11px] text-slate-500">Create routes with SACCO operations, stages and fares in 1 atomic flow.</div>
                </div>
              </div>
              <Link href="/routes/new" className="text-xs font-semibold text-brand-600 hover:text-brand-700">Open →</Link>
            </div>

            <div className="flex items-center justify-between p-3 rounded-lg bg-slate-50 border border-slate-100">
              <div className="flex items-center gap-3">
                <ListOrdered size={18} className="text-sky-600" />
                <div>
                  <div className="text-xs font-bold text-slate-800">Route Stage Sequences</div>
                  <div className="text-[11px] text-slate-500">Re-order stops, update distances and arrival ETAs.</div>
                </div>
              </div>
              <Link href="/route-sequences" className="text-xs font-semibold text-brand-600 hover:text-brand-700">Manage →</Link>
            </div>

            <div className="flex items-center justify-between p-3 rounded-lg bg-slate-50 border border-slate-100">
              <div className="flex items-center gap-3">
                <DollarSign size={18} className="text-teal-600" />
                <div>
                  <div className="text-xs font-bold text-slate-800">Stage-to-Stage Fares</div>
                  <div className="text-[11px] text-slate-500">Configure peak and off-peak segment fares per SACCO.</div>
                </div>
              </div>
              <Link href="/fares" className="text-xs font-semibold text-brand-600 hover:text-brand-700">Configure →</Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
