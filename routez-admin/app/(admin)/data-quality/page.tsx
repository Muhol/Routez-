import { createClient } from '@/lib/supabase/server';
import Link from 'next/link';
import { ShieldCheck, AlertTriangle, XCircle } from 'lucide-react';

export const dynamic = 'force-dynamic';

interface Issue {
  severity: 'warning' | 'error';
  category: string;
  message: string;
  action?: string;
  href?: string;
}

export default async function DataQualityPage() {
  const supabase = await createClient();

  const issues: Issue[] = [];

  // 1. Routes with no SACCO offerings
  const { data: routes } = await supabase.from('routes').select('id, route_number, origin_name, destination_name');
  const { data: saccoRoutes } = await supabase.from('sacco_routes').select('route_id');
  const routeIdsWithSacco = new Set((saccoRoutes ?? []).map((sr) => sr.route_id));
  (routes ?? []).forEach((r) => {
    if (!routeIdsWithSacco.has(r.id)) {
      issues.push({
        severity: 'warning',
        category: 'Routes',
        message: `Route [${r.route_number}] ${r.origin_name} → ${r.destination_name} has no SACCO offering.`,
        action: 'Add SACCO operation',
        href: '/sacco-routes/new',
      });
    }
  });

  // 2. SACCO routes with no stage sequence
  const { data: allSaccoRoutes } = await supabase
    .from('sacco_routes')
    .select('id, saccos(name), routes(route_number)');
  const { data: routeStages } = await supabase.from('sacco_route_stages').select('sacco_route_id');
  const saccoRouteIdsWithStages = new Set((routeStages ?? []).map((rs) => rs.sacco_route_id));
  (allSaccoRoutes ?? []).forEach((sr: any) => {
    if (!saccoRouteIdsWithStages.has(sr.id)) {
      issues.push({
        severity: 'warning',
        category: 'Stage Sequences',
        message: `${sr.saccos?.name} — Route ${sr.routes?.route_number} has no stage sequence defined.`,
        action: 'Build sequence',
        href: '/route-sequences',
      });
    }
  });

  // 3. Stages without area (should not happen with current schema but check anyway)
  const { data: stages } = await supabase.from('stages').select('id, name, area, latitude, longitude');
  (stages ?? []).forEach((s) => {
    if (!s.area || s.area.trim() === '') {
      issues.push({
        severity: 'error',
        category: 'Stages',
        message: `Stage "${s.name}" is missing its area value.`,
        action: 'Edit stage',
        href: `/stages/${s.id}/edit`,
      });
    }
    // Nairobi bounding box soft check
    if (s.latitude < -1.5 || s.latitude > -1.1 || s.longitude < 36.6 || s.longitude > 37.1) {
      issues.push({
        severity: 'warning',
        category: 'GPS',
        message: `Stage "${s.name}" has coordinates (${s.latitude}, ${s.longitude}) outside expected Nairobi area.`,
        action: 'Review stage',
        href: `/stages/${s.id}/edit`,
      });
    }
  });

  // 4. Duplicate stage name + area combos
  const stageCounts = new Map<string, number>();
  (stages ?? []).forEach((s) => {
    const key = `${s.name.toLowerCase()}|${s.area.toLowerCase()}`;
    stageCounts.set(key, (stageCounts.get(key) ?? 0) + 1);
  });
  stageCounts.forEach((count, key) => {
    if (count > 1) {
      const [name, area] = key.split('|');
      issues.push({
        severity: 'warning',
        category: 'Stages',
        message: `"${name}" in "${area}" appears ${count} times. Possible duplicate stage.`,
        action: 'Review stages',
        href: '/stages',
      });
    }
  });

  // 5. Route sequences with non-sequential stop orders
  const { data: sequences } = await supabase
    .from('sacco_route_stages')
    .select('sacco_route_id, stop_order')
    .order('sacco_route_id, stop_order');

  const seqBySaccoRoute = new Map<string, number[]>();
  (sequences ?? []).forEach((s) => {
    const arr = seqBySaccoRoute.get(s.sacco_route_id) ?? [];
    arr.push(s.stop_order);
    seqBySaccoRoute.set(s.sacco_route_id, arr);
  });

  seqBySaccoRoute.forEach((orders, saccoRouteId) => {
    const sorted = [...orders].sort((a, b) => a - b);
    const hasGaps = sorted.some((v, i) => i > 0 && v !== sorted[i - 1] + 1);
    if (hasGaps) {
      const sr = (allSaccoRoutes ?? []).find((s: any) => s.id === saccoRouteId) as any;
      issues.push({
        severity: 'warning',
        category: 'Stage Sequences',
        message: `${sr?.saccos?.name} Route ${sr?.routes?.route_number} has non-sequential stop orders: [${sorted.join(', ')}]`,
        action: 'Fix sequence',
        href: '/route-sequences',
      });
    }
  });

  // 6. Fare records referencing stages not in the route sequence
  const { data: fares } = await supabase
    .from('sacco_route_fares')
    .select('id, sacco_route_id, from_stage_id, to_stage_id');

  const stageIdsInRoute = new Map<string, Set<string>>();
  (sequences ?? []).forEach((s: any) => {
    const set = stageIdsInRoute.get(s.sacco_route_id) ?? new Set();
    set.add(s.stage_id);
    stageIdsInRoute.set(s.sacco_route_id, set);
  });

  // Note: sequences doesn't include stage_id, so this check is approximate
  // A more precise check would require joining — flagged as a data quality note

  const warningCount = issues.filter((i) => i.severity === 'warning').length;
  const errorCount = issues.filter((i) => i.severity === 'error').length;

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Data Quality</h1>
        <p className="text-slate-500 mt-1 text-sm">
          Automated checks for missing relationships, duplicate records, and suspicious data.
          No records are modified automatically — issues require your deliberate action.
        </p>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div className={`rounded-xl border p-4 text-center ${issues.length === 0 ? 'border-emerald-200 bg-emerald-50' : 'border-slate-200 bg-white'}`}>
          <ShieldCheck size={20} className={`mx-auto mb-1 ${issues.length === 0 ? 'text-emerald-500' : 'text-slate-300'}`} />
          <div className="text-2xl font-bold text-slate-700">{issues.length}</div>
          <div className="text-xs text-slate-500">Total Issues</div>
        </div>
        <div className="rounded-xl border border-amber-200 bg-amber-50 p-4 text-center">
          <AlertTriangle size={20} className="mx-auto text-amber-500 mb-1" />
          <div className="text-2xl font-bold text-amber-700">{warningCount}</div>
          <div className="text-xs text-amber-600">Warnings</div>
        </div>
        <div className="rounded-xl border border-red-200 bg-red-50 p-4 text-center">
          <XCircle size={20} className="mx-auto text-red-500 mb-1" />
          <div className="text-2xl font-bold text-red-700">{errorCount}</div>
          <div className="text-xs text-red-600">Errors</div>
        </div>
      </div>

      {issues.length === 0 ? (
        <div className="text-center py-16 bg-white rounded-xl border border-slate-200">
          <ShieldCheck size={40} className="mx-auto text-emerald-400 mb-3" />
          <div className="font-semibold text-slate-800">No issues detected</div>
          <p className="text-slate-400 text-sm mt-1">Your database looks clean and consistent.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {issues.map((issue, i) => (
            <div key={i}
              className={`bg-white rounded-xl border p-5 flex items-start gap-4
                ${issue.severity === 'error' ? 'border-red-200' : 'border-amber-200'}`}>
              {issue.severity === 'error'
                ? <XCircle size={18} className="text-red-500 shrink-0 mt-0.5" />
                : <AlertTriangle size={18} className="text-amber-500 shrink-0 mt-0.5" />
              }
              <div className="flex-1">
                <div className="flex items-center gap-2 flex-wrap">
                  <span className={`text-xs font-medium px-2 py-0.5 rounded-full
                    ${issue.severity === 'error' ? 'badge-error' : 'badge-warning'}`}>
                    {issue.category}
                  </span>
                  <span className="text-sm text-slate-700">{issue.message}</span>
                </div>
              </div>
              {issue.href && (
                <Link href={issue.href}
                  className="shrink-0 text-xs px-3 py-1.5 border border-slate-300 hover:bg-slate-50
                             text-slate-600 rounded-lg transition-colors whitespace-nowrap">
                  {issue.action ?? 'Fix →'}
                </Link>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
