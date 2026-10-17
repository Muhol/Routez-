-- ======================================================
-- ROUTEZ SUPABASE DATABASE SCHEMA (MATATU SACCO ARCHITECTURE)
-- ======================================================

-- Enable PostGIS for geospatial coordinates
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Saccos Table
CREATE TABLE IF NOT EXISTS saccos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    logo_url TEXT,
    contact_phone TEXT,
    rating NUMERIC(2,1) DEFAULT 4.5,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Master Routes Table
CREATE TABLE IF NOT EXISTS routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_number TEXT NOT NULL,
    origin_name TEXT NOT NULL,
    destination_name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Stages / Bus Stops Table
CREATE TABLE IF NOT EXISTS stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    area TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    location GEOMETRY(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)) STORED,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS stages_location_idx ON stages USING GIST (location);

-- 4. Sacco Route Offerings (Connects Sacco to Route with custom pricing & fleet)
-- Note: fare_offpeak and fare_peak represent the DEFAULT full-route fare (origin stage to destination stage).
CREATE TABLE IF NOT EXISTS sacco_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sacco_id UUID REFERENCES saccos(id) ON DELETE CASCADE,
    route_id UUID REFERENCES routes(id) ON DELETE CASCADE,
    fare_offpeak INTEGER NOT NULL,
    fare_peak INTEGER NOT NULL,
    typical_duration_mins INTEGER NOT NULL,
    fleet_type TEXT DEFAULT 'Matatu 14-seater',
    is_express BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    path GEOMETRY(LineString, 4326),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS sacco_routes_path_idx ON sacco_routes USING GIST (path);

-- 5. Sacco Route Stage Sequence (Handles slightly different paths/stops per Sacco!)
CREATE TABLE IF NOT EXISTS sacco_route_stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sacco_route_id UUID REFERENCES sacco_routes(id) ON DELETE CASCADE,
    stage_id UUID REFERENCES stages(id) ON DELETE CASCADE,
    stop_order INTEGER NOT NULL,
    distance_from_start_km NUMERIC NOT NULL DEFAULT 0.0,
    eta_from_start_mins INTEGER NOT NULL DEFAULT 0,
    UNIQUE (sacco_route_id, stage_id),
    UNIQUE (sacco_route_id, stop_order)
);

-- 6. Service Alerts Table (Disruptions, strikes, weather detours)
CREATE TABLE IF NOT EXISTS service_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sacco_route_id UUID REFERENCES sacco_routes(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Stage-to-Stage Segment Fares Table (Stage-specific fare pricing)
CREATE TABLE IF NOT EXISTS sacco_route_fares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sacco_route_id UUID NOT NULL REFERENCES sacco_routes(id) ON DELETE CASCADE,
    from_stage_id UUID NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
    to_stage_id UUID NOT NULL REFERENCES stages(id) ON DELETE CASCADE,
    fare_offpeak INTEGER NOT NULL,
    fare_peak INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (sacco_route_id, from_stage_id, to_stage_id),
    CHECK (from_stage_id <> to_stage_id)
);

CREATE INDEX IF NOT EXISTS sacco_route_fares_lookup_idx ON sacco_route_fares (sacco_route_id, from_stage_id, to_stage_id);

-- ======================================================
-- SEED DATA (NAIROBI MATATU SACCOS, ROUTES, STAGES, & FARES)
-- ======================================================

INSERT INTO saccos (id, name, contact_phone, rating) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Super Metro', '+254 700 111 222', 4.9),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Embassava Sacco', '+254 722 333 444', 4.2),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'Citi Hoppa', '+254 733 555 666', 4.4),
('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'Double M', '+254 711 777 888', 4.6)
ON CONFLICT DO NOTHING;

INSERT INTO routes (id, route_number, origin_name, destination_name) VALUES
('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', '33', 'Embakasi / Pipeline', 'CBD'),
('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a56', '23', 'CBD', 'Westlands')
ON CONFLICT DO NOTHING;

INSERT INTO stages (id, name, area, latitude, longitude) VALUES
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380101', 'Pipeline Stage', 'Outering Road / Embakasi', -1.3175, 36.8962),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380102', 'Taj Mall Stage', 'Fedha / Embakasi', -1.3210, 36.8920),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380103', 'Kencom Stage, CBD', 'City Center', -1.2864, 36.8239),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380104', 'Ambassadeur Stage, CBD', 'City Center', -1.2858, 36.8248),
('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380105', 'Westlands Stage', 'Waiyaki Way / Westlands', -1.2673, 36.8062)
ON CONFLICT DO NOTHING;

INSERT INTO sacco_routes (id, sacco_id, route_id, fare_offpeak, fare_peak, typical_duration_mins, fleet_type, is_express, is_active) VALUES
('11111111-1111-4111-a111-111111111111', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 70, 100, 45, '33-seater Bus', true, true),
('22222222-2222-4222-a222-222222222222', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 50, 80, 55, '14-seater Matatu', false, true)
ON CONFLICT DO NOTHING;

INSERT INTO sacco_route_stages (id, sacco_route_id, stage_id, stop_order, distance_from_start_km, eta_from_start_mins) VALUES
-- Super Metro Route 33 stops
('33333333-3333-4333-a333-333333333301', '11111111-1111-4111-a111-111111111111', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380101', 1, 0.0, 0),
('33333333-3333-4333-a333-333333333302', '11111111-1111-4111-a111-111111111111', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380102', 2, 1.2, 5),
('33333333-3333-4333-a333-333333333303', '11111111-1111-4111-a111-111111111111', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380103', 3, 14.5, 45),
-- Embassava Route 33 stops
('33333333-3333-4333-a333-333333333304', '22222222-2222-4222-a222-222222222222', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380101', 1, 0.0, 0),
('33333333-3333-4333-a333-333333333305', '22222222-2222-4222-a222-222222222222', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380102', 2, 1.2, 8),
('33333333-3333-4333-a333-333333333306', '22222222-2222-4222-a222-222222222222', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380104', 3, 14.8, 55)
ON CONFLICT DO NOTHING;

INSERT INTO sacco_route_fares (id, sacco_route_id, from_stage_id, to_stage_id, fare_offpeak, fare_peak) VALUES
-- Short-hop fare example: Pipeline Stage -> Taj Mall Stage on Super Metro
('44444444-4444-4444-a444-444444444401', '11111111-1111-4111-a111-111111111111', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380101', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380102', 30, 50),
-- Short-hop fare example: Pipeline Stage -> Taj Mall Stage on Embassava
('44444444-4444-4444-a444-444444444402', '22222222-2222-4222-a222-222222222222', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380101', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380102', 20, 30)
ON CONFLICT DO NOTHING;

INSERT INTO service_alerts (id, sacco_route_id, title, message, severity, starts_at) VALUES
('55555555-5555-4555-a555-555555555501', '11111111-1111-4111-a111-111111111111', 'Heavy Rain Detour on Outering Rd', 'Super Metro buses using Southern Bypass due to flooding at Taj Mall underpass.', 'warning', NOW())
ON CONFLICT DO NOTHING;

-- ======================================================
-- ROW LEVEL SECURITY POLICIES (Allow anonymous public reads)
-- ======================================================
CREATE POLICY "Public read routes" ON routes FOR SELECT USING (true);
CREATE POLICY "Public read saccos" ON saccos FOR SELECT USING (true);
CREATE POLICY "Public read stages" ON stages FOR SELECT USING (true);
CREATE POLICY "Public read sacco_routes" ON sacco_routes FOR SELECT USING (true);
CREATE POLICY "Public read sacco_route_stages" ON sacco_route_stages FOR SELECT USING (true);
CREATE POLICY "Public read sacco_route_fares" ON sacco_route_fares FOR SELECT USING (true);
CREATE POLICY "Public read service_alerts" ON service_alerts FOR SELECT USING (true);

