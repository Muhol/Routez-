import { z, ZodError } from 'zod';

// Compatibility patch for @hookform/resolvers/zod with Zod 4 (where error.errors was replaced by error.issues)
if (typeof ZodError !== 'undefined' && ZodError.prototype && !('errors' in ZodError.prototype)) {
  Object.defineProperty(ZodError.prototype, 'errors', {
    get() {
      return this.issues;
    },
    configurable: true,
  });
}

// ─── Sacco ────────────────────────────────────────────────────────────────────

export const saccoSchema = z.object({
  name: z.string().min(1, 'SACCO name is required').max(200),
  logo_url: z.string().url('Must be a valid URL').or(z.literal('')).optional().nullable(),
  contact_phone: z.string().max(30).optional().nullable(),
  rating: z.coerce.number().min(0).max(5).default(4.5),
});

export type SaccoFormValues = z.infer<typeof saccoSchema>;

// ─── Route ────────────────────────────────────────────────────────────────────

export const routeSchema = z.object({
  route_number: z.string().min(1, 'Route number is required').max(20),
  origin_name: z.string().min(1, 'Origin is required').max(200),
  destination_name: z.string().min(1, 'Destination is required').max(200),
});

export type RouteFormValues = z.infer<typeof routeSchema>;

// ─── Stage ────────────────────────────────────────────────────────────────────

export const stageSchema = z.object({
  name: z.string().min(1, 'Stage name is required').max(200),
  area: z.string().min(1, 'Area is required').max(200),
  latitude: z.coerce
    .number()
    .min(-90, 'Latitude must be ≥ -90')
    .max(90, 'Latitude must be ≤ 90'),
  longitude: z.coerce
    .number()
    .min(-180, 'Longitude must be ≥ -180')
    .max(180, 'Longitude must be ≤ 180'),
});

export type StageFormValues = z.infer<typeof stageSchema>;

// ─── Sacco Route ──────────────────────────────────────────────────────────────

export const saccoRouteSchema = z.object({
  sacco_id: z.string().uuid('Select a valid SACCO'),
  route_id: z.string().uuid('Select a valid route'),
  fare_offpeak: z.coerce.number().int().min(0, 'Off-peak fare must be ≥ 0'),
  fare_peak: z.coerce.number().int().min(0, 'Peak fare must be ≥ 0'),
  typical_duration_mins: z.coerce.number().int().min(1, 'Duration must be at least 1 minute'),
  fleet_type: z.string().min(1, 'Fleet type is required').default('Matatu 14-seater'),
  is_express: z.boolean().default(false),
  is_active: z.boolean().default(true),
});

export type SaccoRouteFormValues = z.infer<typeof saccoRouteSchema>;

// ─── Sacco Route Stage ────────────────────────────────────────────────────────

export const saccoRouteStageSchema = z.object({
  sacco_route_id: z.string().uuid(),
  stage_id: z.string().uuid('Select a valid stage'),
  stop_order: z.coerce.number().int().min(1, 'Stop order must be ≥ 1'),
  distance_from_start_km: z.coerce.number().min(0).default(0),
  eta_from_start_mins: z.coerce.number().int().min(0).default(0),
});

export type SaccoRouteStageFormValues = z.infer<typeof saccoRouteStageSchema>;

// ─── Service Alert ────────────────────────────────────────────────────────────

export const serviceAlertSchema = z
  .object({
    sacco_route_id: z.string().uuid('Select a valid SACCO route'),
    title: z.string().min(1, 'Title is required').max(200),
    message: z.string().min(1, 'Message is required'),
    severity: z.enum(['info', 'warning', 'critical']),
    starts_at: z.string().min(1, 'Start time is required'),
    ends_at: z.string().optional().nullable(),
  })
  .refine(
    (data) => {
      if (!data.ends_at) return true;
      return new Date(data.ends_at) > new Date(data.starts_at);
    },
    { message: 'End time must be after start time', path: ['ends_at'] }
  );

export type ServiceAlertFormValues = z.infer<typeof serviceAlertSchema>;

// ─── Stage-to-Stage Fare ──────────────────────────────────────────────────────

export const saccoRouteFareSchema = z
  .object({
    sacco_route_id: z.string().min(1, 'Select a valid SACCO route'),
    from_stage_id: z.string().min(1, 'Select the origin stage'),
    to_stage_id: z.string().min(1, 'Select the destination stage'),
    fare_offpeak: z.coerce.number().int().min(0, 'Off-peak fare must be ≥ 0'),
    fare_peak: z.coerce.number().int().min(0, 'Peak fare must be ≥ 0'),
  })
  .refine((data) => data.from_stage_id !== data.to_stage_id, {
    message: 'Origin and destination stages must differ',
    path: ['to_stage_id'],
  });

export type SaccoRouteFareFormValues = z.infer<typeof saccoRouteFareSchema>;

// ─── GPS coordinate parsing helper ────────────────────────────────────────────

export function parseLatLng(raw: string): { latitude: number; longitude: number } | null {
  const trimmed = raw.trim();
  // "lat, lng" or "lat lng"
  const parts = trimmed.split(/[\s,]+/);
  if (parts.length === 2) {
    const lat = parseFloat(parts[0]);
    const lng = parseFloat(parts[1]);
    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      return { latitude: lat, longitude: lng };
    }
  }
  return null;
}
