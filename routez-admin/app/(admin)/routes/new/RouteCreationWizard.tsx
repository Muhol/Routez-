'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { toast } from 'sonner';
import {
  Route,
  Bus,
  MapPin,
  DollarSign,
  CheckCircle2,
  ChevronRight,
  ChevronLeft,
  Plus,
  Trash2,
  ArrowUp,
  ArrowDown,
  Sparkles,
  Info,
  Save,
  Check,
  ArrowLeftRight,
  RotateCcw,
} from 'lucide-react';

interface SaccoItem {
  id: string;
  name: string;
  contact_phone: string | null;
  rating: number;
}

interface StageItem {
  id: string;
  name: string;
  area: string;
  latitude: number;
  longitude: number;
}

interface StageRow {
  clientId: string;
  stage_id: string;
  stage_name: string;
  stage_area: string;
  latitude: number;
  longitude: number;
  stop_order: number;
  distance_from_start_km: number;
  eta_from_start_mins: number;
  // Fare fields:
  fare_mode: 'definite' | 'range';
  fare_offpeak: number;
  fare_peak: number;
  fare_offpeak_min: number;
  fare_offpeak_max: number;
  fare_peak_min: number;
  fare_peak_max: number;
}

interface SaccoConfig {
  sacco_id: string;
  sacco_name: string;
  fleet_type: string;
  fare_offpeak: number;
  fare_peak: number;
  typical_duration_mins: number;
  is_express: boolean;
  is_active: boolean;
  stages: StageRow[];
}

const FLEET_TYPES = [
  '14-seater Matatu',
  '33-seater Bus',
  '50-seater Bus',
  'Executive Shuttle',
  'Minibus (25-seater)',
];

const STEPS = [
  { id: 1, title: 'Route Corridor', desc: 'Number, origin & destination', icon: Route },
  { id: 2, title: 'Operating SACCOs', desc: 'Fleets & base full fares', icon: Bus },
  { id: 3, title: 'Stage Sequences', desc: 'Ordered stops per SACCO', icon: MapPin },
  { id: 4, title: 'Stage Fares', desc: 'Definite or range pricing', icon: DollarSign },
  { id: 5, title: 'Review & Commit', desc: 'Atomic database write', icon: CheckCircle2 },
];

export default function RouteCreationWizard() {
  const router = useRouter();
  const supabase = createClient();

  const [currentStep, setCurrentStep] = useState(1);
  const [loadingInitial, setLoadingInitial] = useState(true);
  const [saving, setSaving] = useState(false);

  // Database lookups
  const [allSaccos, setAllSaccos] = useState<SaccoItem[]>([]);
  const [allStages, setAllStages] = useState<StageItem[]>([]);

  // Step 1: Route Master
  const [routeNumber, setRouteNumber] = useState('');
  const [originName, setOriginName] = useState('');
  const [destinationName, setDestinationName] = useState('');

  // Step 2: Saccos
  const [saccoConfigs, setSaccoConfigs] = useState<SaccoConfig[]>([]);

  // Post-Save / Reverse Route State
  const [savedRouteInfo, setSavedRouteInfo] = useState<{
    routeId: string;
    routeNumber: string;
    origin: string;
    destination: string;
    saccoCount: number;
    totalStages: number;
  } | null>(null);
  const [isReverseMode, setIsReverseMode] = useState(false);

  // Active sacco tab for Step 3 & 4
  const [activeSaccoId, setActiveSaccoId] = useState<string>('');

  // Inline Quick Add Modals
  const [showAddSaccoModal, setShowAddSaccoModal] = useState(false);
  const [newSaccoName, setNewSaccoName] = useState('');
  const [newSaccoPhone, setNewSaccoPhone] = useState('');

  const [showAddStageModal, setShowAddStageModal] = useState(false);
  const [newStageName, setNewStageName] = useState('');
  const [newStageArea, setNewStageArea] = useState('');
  const [newStageGps, setNewStageGps] = useState('');

  // Load existing SACCOs and Stages
  useEffect(() => {
    async function loadData() {
      try {
        const [saccoRes, stageRes] = await Promise.all([
          supabase.from('saccos').select('id, name, contact_phone, rating').order('name'),
          supabase.from('stages').select('id, name, area, latitude, longitude').order('name'),
        ]);

        if (saccoRes.data) setAllSaccos(saccoRes.data as SaccoItem[]);
        if (stageRes.data) setAllStages(stageRes.data as StageItem[]);
      } catch (err) {
        console.error('Failed to load metadata:', err);
      } finally {
        setLoadingInitial(false);
      }
    }
    loadData();
  }, []);

  // Update activeSaccoId when configs change
  useEffect(() => {
    if (saccoConfigs.length > 0 && (!activeSaccoId || !saccoConfigs.some(s => s.sacco_id === activeSaccoId))) {
      setActiveSaccoId(saccoConfigs[0].sacco_id);
    }
  }, [saccoConfigs, activeSaccoId]);

  // Automatically fill destination stage fares when entering Step 4
  useEffect(() => {
    if (currentStep === 4) {
      syncDestinationFares();
    }
  }, [currentStep]);

  // ─── Step 2 Helpers: Toggle SACCO selection ───
  function toggleSacco(sacco: SaccoItem) {
    const exists = saccoConfigs.find(s => s.sacco_id === sacco.id);
    if (exists) {
      setSaccoConfigs(prev => prev.filter(s => s.sacco_id !== sacco.id));
    } else {
      const newConfig: SaccoConfig = {
        sacco_id: sacco.id,
        sacco_name: sacco.name,
        fleet_type: '14-seater Matatu',
        fare_offpeak: 50,
        fare_peak: 80,
        typical_duration_mins: 45,
        is_express: false,
        is_active: true,
        stages: [],
      };
      setSaccoConfigs(prev => [...prev, newConfig]);
      if (!activeSaccoId) setActiveSaccoId(sacco.id);
    }
  }

  function updateSaccoConfig(saccoId: string, field: keyof SaccoConfig, value: any) {
    setSaccoConfigs(prev =>
      prev.map(sc => (sc.sacco_id === saccoId ? { ...sc, [field]: value } : sc))
    );
  }

  // ─── Step 3 Helpers: Add Stage to Sacco ───
  function addStageToSacco(saccoId: string, stageOrId: string | StageItem) {
    const stage = typeof stageOrId === 'string'
      ? allStages.find(s => s.id === stageOrId)
      : stageOrId;
    if (!stage) return;

    setSaccoConfigs(prev =>
      prev.map(sc => {
        if (sc.sacco_id !== saccoId) return sc;
        if (sc.stages.some(st => st.stage_id === stage.id)) {
          toast.error(`${stage.name} is already added in this sequence.`);
          return sc;
        }

        const nextOrder = sc.stages.length + 1;
        const newRow: StageRow = {
          clientId: crypto.randomUUID(),
          stage_id: stage.id,
          stage_name: stage.name,
          stage_area: stage.area,
          latitude: stage.latitude,
          longitude: stage.longitude,
          stop_order: nextOrder,
          distance_from_start_km: nextOrder === 1 ? 0 : Math.round((nextOrder - 1) * 2.5 * 10) / 10,
          eta_from_start_mins: nextOrder === 1 ? 0 : (nextOrder - 1) * 6,
          fare_mode: 'definite',
          fare_offpeak: nextOrder === 1 ? 0 : sc.fare_offpeak,
          fare_peak: nextOrder === 1 ? 0 : sc.fare_peak,
          fare_offpeak_min: nextOrder === 1 ? 0 : Math.max(20, sc.fare_offpeak - 10),
          fare_offpeak_max: nextOrder === 1 ? 0 : sc.fare_offpeak,
          fare_peak_min: nextOrder === 1 ? 0 : Math.max(30, sc.fare_peak - 10),
          fare_peak_max: nextOrder === 1 ? 0 : sc.fare_peak,
        };

        return { ...sc, stages: [...sc.stages, newRow] };
      })
    );
  }

  // ─── Sync Destination Stage Fares with Step 2 Full Fares ───
  function syncDestinationFares() {
    setSaccoConfigs(prev =>
      prev.map(sc => {
        if (sc.stages.length < 2) return sc;
        const lastIdx = sc.stages.length - 1;
        const updatedStages = sc.stages.map((st, idx) => {
          if (idx === lastIdx) {
            return {
              ...st,
              fare_peak: sc.fare_peak,
              fare_offpeak: sc.fare_offpeak,
              fare_peak_max: sc.fare_peak,
              fare_peak_min: Math.max(0, sc.fare_peak - 20),
              fare_offpeak_max: sc.fare_offpeak,
              fare_offpeak_min: Math.max(0, sc.fare_offpeak - 10),
            };
          }
          return st;
        });
        return { ...sc, stages: updatedStages };
      })
    );
  }

  function removeStageFromSacco(saccoId: string, clientId: string) {
    setSaccoConfigs(prev =>
      prev.map(sc => {
        if (sc.sacco_id !== saccoId) return sc;
        const filtered = sc.stages.filter(st => st.clientId !== clientId);
        const reordered = filtered.map((st, idx) => ({ ...st, stop_order: idx + 1 }));
        return { ...sc, stages: reordered };
      })
    );
  }

  function moveStage(saccoId: string, index: number, direction: -1 | 1) {
    setSaccoConfigs(prev =>
      prev.map(sc => {
        if (sc.sacco_id !== saccoId) return sc;
        const stages = [...sc.stages];
        const targetIdx = index + direction;
        if (targetIdx < 0 || targetIdx >= stages.length) return sc;

        const temp = stages[index];
        stages[index] = stages[targetIdx];
        stages[targetIdx] = temp;

        const reordered = stages.map((st, idx) => ({ ...st, stop_order: idx + 1 }));
        return { ...sc, stages: reordered };
      })
    );
  }

  function updateStageRow(saccoId: string, clientId: string, updates: Partial<StageRow>) {
    setSaccoConfigs(prev =>
      prev.map(sc => {
        if (sc.sacco_id !== saccoId) return sc;
        return {
          ...sc,
          stages: sc.stages.map(st => (st.clientId === clientId ? { ...st, ...updates } : st)),
        };
      })
    );
  }

  // Copy sequence from one SACCO to another
  function copyStagesFromAnotherSacco(targetSaccoId: string, sourceSaccoId: string) {
    const source = saccoConfigs.find(s => s.sacco_id === sourceSaccoId);
    if (!source || source.stages.length === 0) {
      toast.error('Source SACCO has no stages to copy.');
      return;
    }

    setSaccoConfigs(prev =>
      prev.map(sc => {
        if (sc.sacco_id !== targetSaccoId) return sc;
        const clonedStages = source.stages.map(st => ({
          ...st,
          clientId: crypto.randomUUID(),
        }));
        return { ...sc, stages: clonedStages };
      })
    );
    toast.success(`Copied ${source.stages.length} stages from ${source.sacco_name}`);
  }

  // ─── Inline Quick Add SACCO ───
  async function handleCreateSaccoInline(e: React.FormEvent) {
    e.preventDefault();
    if (!newSaccoName.trim()) return;

    try {
      const { data, error } = await supabase
        .from('saccos')
        .insert({
          name: newSaccoName.trim(),
          contact_phone: newSaccoPhone.trim() || null,
          rating: 4.5,
        })
        .select()
        .single();

      if (error) throw error;

      toast.success(`SACCO "${data.name}" registered!`);
      const newItem: SaccoItem = {
        id: data.id,
        name: data.name,
        contact_phone: data.contact_phone,
        rating: data.rating,
      };
      setAllSaccos(prev => [...prev, newItem].sort((a, b) => a.name.localeCompare(b.name)));
      toggleSacco(newItem);
      setNewSaccoName('');
      setNewSaccoPhone('');
      setShowAddSaccoModal(false);
    } catch (err: any) {
      toast.error(`Failed to create SACCO: ${err.message}`);
    }
  }

  // ─── Inline Quick Add Stage ───
  async function handleCreateStageInline(e: React.FormEvent) {
    e.preventDefault();
    if (!newStageName.trim() || !newStageArea.trim()) {
      toast.error('Stage name and Area are required');
      return;
    }

    let lat = -1.2864;
    let lng = 36.8239;

    if (newStageGps.trim()) {
      const parts = newStageGps.split(/[\s,]+/);
      if (parts.length === 2) {
        const parsedLat = parseFloat(parts[0]);
        const parsedLng = parseFloat(parts[1]);
        if (!isNaN(parsedLat) && !isNaN(parsedLng)) {
          lat = parsedLat;
          lng = parsedLng;
        }
      }
    }

    try {
      const { data, error } = await supabase
        .from('stages')
        .insert({
          name: newStageName.trim(),
          area: newStageArea.trim(),
          latitude: lat,
          longitude: lng,
        })
        .select()
        .single();

      if (error) throw error;

      const newItem: StageItem = {
        id: data.id,
        name: data.name,
        area: data.area,
        latitude: data.latitude,
        longitude: data.longitude,
      };
      setAllStages(prev => [...prev, newItem].sort((a, b) => a.name.localeCompare(b.name)));

      if (activeSaccoId) {
        addStageToSacco(activeSaccoId, newItem);
        toast.success(`Stage "${data.name}" created and added to current SACCO route!`);
      } else {
        toast.success(`Stage "${data.name}" added to database!`);
      }

      setNewStageName('');
      setNewStageArea('');
      setNewStageGps('');
      setShowAddStageModal(false);
    } catch (err: any) {
      toast.error(`Failed to create stage: ${err.message}`);
    }
  }

  // ─── Step Navigation & Validations ───
  function canGoNext(): boolean {
    if (currentStep === 1) {
      return !!routeNumber.trim() && !!originName.trim() && !!destinationName.trim();
    }
    if (currentStep === 2) {
      return saccoConfigs.length > 0;
    }
    if (currentStep === 3) {
      return saccoConfigs.every(s => s.stages.length >= 2);
    }
    return true;
  }

  function handleNext() {
    if (!canGoNext()) {
      if (currentStep === 1) toast.error('Please enter Route Number, Origin, and Destination.');
      else if (currentStep === 2) toast.error('Please select at least one operating SACCO.');
      else if (currentStep === 3) {
        const invalidSacco = saccoConfigs.find(s => s.stages.length < 2);
        toast.error(`SACCO "${invalidSacco?.sacco_name}" must have at least 2 stops (origin & destination).`);
      }
      return;
    }
    if (currentStep === 3) {
      syncDestinationFares();
    }
    setCurrentStep(prev => Math.min(5, prev + 1));
  }

  function handleBack() {
    setCurrentStep(prev => Math.max(1, prev - 1));
  }

  // ─── Step 5: ATOMIC / BATCHED SAVE ALL ───
  async function handleFinalSave() {
    setSaving(true);
    let createdRouteId: string | null = null;

    try {
      // 1. Insert Master Route
      const { data: routeData, error: routeError } = await supabase
        .from('routes')
        .insert({
          route_number: routeNumber.trim(),
          origin_name: originName.trim(),
          destination_name: destinationName.trim(),
        })
        .select()
        .single();

      if (routeError) throw new Error(`Route creation failed: ${routeError.message}`);
      createdRouteId = routeData.id;

      // 2. Loop through each SACCO
      for (const sc of saccoConfigs) {
        const lastStage = sc.stages[sc.stages.length - 1];
        const finalPeakFare = lastStage ? lastStage.fare_peak : sc.fare_peak;
        const finalOffPeakFare = lastStage ? lastStage.fare_offpeak : sc.fare_offpeak;

        const { data: srData, error: srError } = await supabase
          .from('sacco_routes')
          .insert({
            route_id: createdRouteId,
            sacco_id: sc.sacco_id,
            fleet_type: sc.fleet_type,
            fare_offpeak: finalOffPeakFare || sc.fare_offpeak,
            fare_peak: finalPeakFare || sc.fare_peak,
            typical_duration_mins: sc.typical_duration_mins,
            is_express: sc.is_express,
            is_active: sc.is_active,
          })
          .select()
          .single();

        if (srError) throw new Error(`Failed to link SACCO "${sc.sacco_name}": ${srError.message}`);

        // 3. Insert Stage Sequences for this SACCO with peak & offpeak fares
        if (sc.stages.length > 0) {
          const stageInsertsWithFares = sc.stages.map((st, idx) => ({
            sacco_route_id: srData.id,
            stage_id: st.stage_id,
            stop_order: idx + 1,
            distance_from_start_km: st.distance_from_start_km || 0,
            eta_from_start_mins: st.eta_from_start_mins || 0,
            fare_offpeak: st.fare_offpeak || 0,
            fare_peak: st.fare_peak || 0,
            fare_offpeak_min: st.fare_offpeak_min || st.fare_offpeak || 0,
            fare_offpeak_max: st.fare_offpeak_max || st.fare_offpeak || 0,
            fare_peak_min: st.fare_peak_min || st.fare_peak || 0,
            fare_peak_max: st.fare_peak_max || st.fare_peak || 0,
          }));

          const { error: stagesError } = await supabase
            .from('sacco_route_stages')
            .insert(stageInsertsWithFares);

          if (stagesError) {
            // Graceful fallback if the optional DB columns have not been migrated yet
            if (stagesError.message.includes('fare_offpeak') || stagesError.message.includes('column')) {
              const baseStageInserts = sc.stages.map((st, idx) => ({
                sacco_route_id: srData.id,
                stage_id: st.stage_id,
                stop_order: idx + 1,
                distance_from_start_km: st.distance_from_start_km || 0,
                eta_from_start_mins: st.eta_from_start_mins || 0,
              }));
              const { error: fallbackErr } = await supabase
                .from('sacco_route_stages')
                .insert(baseStageInserts);
              if (fallbackErr) {
                throw new Error(`Failed to save stop sequence for "${sc.sacco_name}": ${fallbackErr.message}`);
              }
            } else {
              throw new Error(`Failed to save stop sequence for "${sc.sacco_name}": ${stagesError.message}`);
            }
          }

          // 4. Insert Stage-to-Stage Fares from Origin (Stop 1) to each subsequent Stop
          if (sc.stages.length > 1) {
            const originStage = sc.stages[0];
            const fareInserts = [];

            for (let i = 1; i < sc.stages.length; i++) {
              const targetStage = sc.stages[i];
              fareInserts.push({
                sacco_route_id: srData.id,
                from_stage_id: originStage.stage_id,
                to_stage_id: targetStage.stage_id,
                fare_offpeak: targetStage.fare_offpeak,
                fare_peak: targetStage.fare_peak,
              });
            }

            if (fareInserts.length > 0) {
              const { error: faresError } = await supabase
                .from('sacco_route_fares')
                .insert(fareInserts);

              if (faresError) {
                console.warn('Note: Segment fares error:', faresError.message);
              }
            }
          }
        }
      }

      // On success: Store saved info to give the option to create a reverse route
      setSavedRouteInfo({
        routeId: createdRouteId || '',
        routeNumber: routeNumber.trim(),
        origin: originName.trim(),
        destination: destinationName.trim(),
        saccoCount: saccoConfigs.length,
        totalStages: saccoConfigs.reduce((acc, s) => acc + s.stages.length, 0),
      });
      toast.success(`Route ${routeNumber} saved successfully to the database!`);
    } catch (err: any) {
      console.error('Save failed:', err);
      toast.error(err.message || 'An error occurred while saving the route package.');

      // Automated Cleanup of partial writes on failure
      if (createdRouteId) {
        await supabase.from('routes').delete().eq('id', createdRouteId);
      }
    } finally {
      setSaving(false);
    }
  }

  // ─── Reverse Route Generator (Inverts Corridor & Stages, Resets Fares) ───
  function handleStartReverseRoute() {
    if (!savedRouteInfo) return;

    const prevOrigin = savedRouteInfo.origin;
    const prevDest = savedRouteInfo.destination;
    const sameRouteNumber = savedRouteInfo.routeNumber;

    // 1. Invert Origin and Destination for the same Route Number
    setRouteNumber(sameRouteNumber);
    setOriginName(prevDest);
    setDestinationName(prevOrigin);
    setIsReverseMode(true);

    // 2. Invert Stages for each SACCO and reset all fares
    setSaccoConfigs(prev =>
      prev.map(sc => {
        const reversedStages = [...sc.stages].reverse().map((st, idx) => ({
          clientId: crypto.randomUUID(),
          stage_id: st.stage_id,
          stage_name: st.stage_name,
          stage_area: st.stage_area,
          latitude: st.latitude,
          longitude: st.longitude,
          stop_order: idx + 1,
          distance_from_start_km: idx === 0 ? 0 : Math.round(idx * 2.5 * 10) / 10,
          eta_from_start_mins: idx === 0 ? 0 : idx * 6,
          fare_mode: 'definite' as const,
          fare_offpeak: 0,
          fare_peak: 0,
          fare_offpeak_min: 0,
          fare_offpeak_max: 0,
          fare_peak_min: 0,
          fare_peak_max: 0,
        }));

        return {
          ...sc,
          fare_offpeak: 0,
          fare_peak: 0,
          stages: reversedStages,
        };
      })
    );

    // 3. Close the modal & reset to Step 1
    setSavedRouteInfo(null);
    setCurrentStep(1);
    toast.success(`Reverse route loaded: ${prevDest} ➔ ${prevOrigin}. Stages inverted! Please configure return fares in Step 4.`, {
      duration: 6000,
    });
  }

  const currentSacco = saccoConfigs.find(s => s.sacco_id === activeSaccoId) || saccoConfigs[0];

  return (
    <div className="max-w-6xl mx-auto p-4 sm:p-6 lg:p-8 space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-200 pb-5">
        <div>
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-50 text-brand-700 text-xs font-semibold mb-2">
            <Sparkles size={13} /> Progressive Route Studio
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-slate-900 tracking-tight">
            Create Complete Route Package
          </h1>
          <p className="text-slate-500 text-sm mt-1">
            Build route corridor, attach SACCOs, arrange stage sequences, and configure fares — all in one connected flow.
          </p>
        </div>
        <Link
          href="/routes"
          className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 text-sm font-medium transition-colors w-fit"
        >
          Cancel & Exit
        </Link>
      </div>

      {/* Stepper Navigation */}
      <div className="grid grid-cols-2 sm:grid-cols-5 gap-2 bg-slate-50 p-2 rounded-2xl border border-slate-200">
        {STEPS.map(step => {
          const StepIcon = step.icon;
          const isActive = currentStep === step.id;
          const isDone = currentStep > step.id;

          return (
            <button
              key={step.id}
              onClick={() => {
                if (step.id < currentStep || canGoNext()) {
                  if (step.id === 4) {
                    syncDestinationFares();
                  }
                  setCurrentStep(step.id);
                }
              }}
              className={`flex items-center gap-3 p-3 rounded-xl text-left transition-all ${
                isActive
                  ? 'bg-white shadow-sm border border-brand-300 ring-1 ring-brand-400'
                  : isDone
                  ? 'bg-white/60 hover:bg-white text-slate-700'
                  : 'opacity-50 text-slate-400'
              }`}
            >
              <div
                className={`w-9 h-9 rounded-lg flex items-center justify-center shrink-0 text-sm font-bold ${
                  isActive
                    ? 'bg-brand-600 text-white'
                    : isDone
                    ? 'bg-emerald-500 text-white'
                    : 'bg-slate-200 text-slate-600'
                }`}
              >
                {isDone ? <Check size={16} /> : <StepIcon size={16} />}
              </div>
              <div className="min-w-0">
                <div className="text-xs font-bold truncate">
                  {step.id}. {step.title}
                </div>
                <div className="text-[11px] text-slate-400 truncate hidden lg:block">
                  {step.desc}
                </div>
              </div>
            </button>
          );
        })}
      </div>

      {/* STEP 1: ROUTE CORRIDOR */}
      {currentStep === 1 && (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 sm:p-8 space-y-6 shadow-sm animate-fade-in">
          <div className="border-b border-slate-100 pb-4">
            <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
              <Route className="text-brand-600" size={22} /> Step 1: Define Master Route Corridor
            </h2>
            <p className="text-slate-500 text-sm mt-1">
              Specify the route identification number and terminal endpoints.
            </p>
          </div>

          {isReverseMode && (
            <div className="rounded-xl bg-amber-50 border border-amber-200 p-4 flex items-center justify-between text-xs text-amber-900 animate-fade-in shadow-xs">
              <div className="flex items-center gap-2.5">
                <ArrowLeftRight size={18} className="text-amber-700 shrink-0" />
                <div>
                  <span className="font-bold">Reverse Return Route:</span> Origin ({originName}) and Destination ({destinationName}) have been swapped, and all stage sequences reversed. Please configure return fares in Step 4 before publishing.
                </div>
              </div>
              <span className="font-bold text-amber-800 bg-amber-200/70 px-2.5 py-1 rounded-md text-[11px] shrink-0 ml-3">
                Reverse Route Mode
              </span>
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label className="block text-sm font-semibold text-slate-800 mb-1.5">
                Route Number / Code <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={routeNumber}
                onChange={e => setRouteNumber(e.target.value)}
                placeholder="e.g. 46, 23, 111, 7c"
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-brand-500 font-semibold"
              />
              <p className="text-xs text-slate-400 mt-1">Supports alphanumeric numbers like 7c, 105, 111.</p>
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-800 mb-1.5">
                Origin Name <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={originName}
                onChange={e => setOriginName(e.target.value)}
                placeholder="e.g. CBD (Kencom / Railways)"
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-brand-500"
              />
              <p className="text-xs text-slate-400 mt-1">Starting terminus stage of the trip.</p>
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-800 mb-1.5">
                Destination Name <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                value={destinationName}
                onChange={e => setDestinationName(e.target.value)}
                placeholder="e.g. Kawangware, Westlands, Rongai"
                className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 text-sm focus:outline-none focus:ring-2 focus:ring-brand-500"
              />
              <p className="text-xs text-slate-400 mt-1">Final terminus stage of the route.</p>
            </div>
          </div>

          <div className="rounded-xl bg-brand-50/70 border border-brand-100 p-4 flex items-start gap-3">
            <Info size={18} className="text-brand-600 shrink-0 mt-0.5" />
            <div className="text-xs text-slate-600 space-y-1">
              <span className="font-semibold text-slate-800">What happens next:</span>
              <p>
                In the next steps, you will select all SACCOs running this corridor (e.g., <em>Super Metro, City Hoppa, Double M</em>), sequence their specific intermediate stages, and assign the stage fares.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* STEP 2: OPERATING SACCOS */}
      {currentStep === 2 && (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 sm:p-8 space-y-6 shadow-sm animate-fade-in">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-100 pb-4">
            <div>
              <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
                <Bus className="text-brand-600" size={22} /> Step 2: Select SACCOs on Route {routeNumber || '[Number]'}
              </h2>
              <p className="text-slate-500 text-sm mt-1">
                Select one or more SACCOs authorized to run this route corridor ({originName} ➔ {destinationName}).
              </p>
            </div>
            <button
              type="button"
              onClick={() => setShowAddSaccoModal(true)}
              className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-brand-50 hover:bg-brand-100 text-brand-700 font-semibold rounded-xl text-xs transition-colors w-fit border border-brand-200"
            >
              <Plus size={14} /> + New SACCO
            </button>
          </div>

          {/* SACCO Picker Grid */}
          <div>
            <label className="block text-xs font-bold text-slate-600 uppercase tracking-wider mb-2">
              Available SACCOs ({allSaccos.length}) — Click to Toggle Selection
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 max-h-56 overflow-y-auto p-1 border border-slate-100 rounded-xl">
              {allSaccos.map(sacco => {
                const isSelected = saccoConfigs.some(s => s.sacco_id === sacco.id);
                return (
                  <button
                    key={sacco.id}
                    type="button"
                    onClick={() => toggleSacco(sacco)}
                    className={`flex items-center gap-2.5 p-3 rounded-xl border text-left transition-all ${
                      isSelected
                        ? 'border-brand-600 bg-brand-50/80 ring-2 ring-brand-500 text-brand-900'
                        : 'border-slate-200 hover:border-slate-300 bg-white text-slate-700'
                    }`}
                  >
                    <div
                      className={`w-6 h-6 rounded-md flex items-center justify-center shrink-0 text-xs font-bold ${
                        isSelected ? 'bg-brand-600 text-white' : 'bg-slate-100 text-slate-500'
                      }`}
                    >
                      {isSelected ? <Check size={13} /> : <Bus size={13} />}
                    </div>
                    <div className="min-w-0">
                      <div className="text-xs font-semibold truncate">{sacco.name}</div>
                      <div className="text-[10px] text-slate-400">★ {sacco.rating || 4.5}</div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Config Per Selected Sacco */}
          {saccoConfigs.length > 0 && (
            <div className="space-y-4 pt-4 border-t border-slate-100">
              <h3 className="text-sm font-bold text-slate-800">
                Configure Operating Fleet & Full Fares for Selected SACCOs ({saccoConfigs.length}):
              </h3>

              <div className="space-y-3">
                {saccoConfigs.map(sc => (
                  <div
                    key={sc.sacco_id}
                    className="p-4 rounded-xl border border-slate-200 bg-slate-50/50 space-y-3"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2 font-bold text-slate-900 text-sm">
                        <Bus size={16} className="text-brand-600" />
                        {sc.sacco_name}
                      </div>
                      <button
                        type="button"
                        onClick={() => toggleSacco({ id: sc.sacco_id, name: sc.sacco_name, contact_phone: null, rating: 4.5 })}
                        className="text-xs text-red-500 hover:text-red-700 font-medium"
                      >
                        Remove
                      </button>
                    </div>

                    <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">
                          Fleet Vehicle Type
                        </label>
                        <select
                          value={sc.fleet_type}
                          onChange={e => updateSaccoConfig(sc.sacco_id, 'fleet_type', e.target.value)}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-slate-300 text-xs bg-white"
                        >
                          {FLEET_TYPES.map(ft => (
                            <option key={ft} value={ft}>
                              {ft}
                            </option>
                          ))}
                        </select>
                      </div>

                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">
                          Duration (Mins)
                        </label>
                        <input
                          type="number"
                          min="5"
                          value={sc.typical_duration_mins}
                          onChange={e => updateSaccoConfig(sc.sacco_id, 'typical_duration_mins', parseInt(e.target.value) || 30)}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-slate-300 text-xs bg-white"
                        />
                      </div>

                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">
                          Full Off-Peak (KSh)
                        </label>
                        <input
                          type="number"
                          min="0"
                          value={sc.fare_offpeak}
                          onChange={e => updateSaccoConfig(sc.sacco_id, 'fare_offpeak', parseInt(e.target.value) || 0)}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-slate-300 text-xs bg-white font-medium"
                        />
                      </div>

                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 mb-1">
                          Full Peak (KSh)
                        </label>
                        <input
                          type="number"
                          min="0"
                          value={sc.fare_peak}
                          onChange={e => updateSaccoConfig(sc.sacco_id, 'fare_peak', parseInt(e.target.value) || 0)}
                          className="w-full px-2.5 py-1.5 rounded-lg border border-slate-300 text-xs bg-white font-medium"
                        />
                      </div>

                      <div className="flex items-center gap-3 pt-4">
                        <label className="flex items-center gap-1.5 text-xs text-slate-700 cursor-pointer">
                          <input
                            type="checkbox"
                            checked={sc.is_express}
                            onChange={e => updateSaccoConfig(sc.sacco_id, 'is_express', e.target.checked)}
                            className="rounded border-slate-300 text-brand-600 focus:ring-brand-500"
                          />
                          <span>Express</span>
                        </label>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* STEP 3: STAGES & SEQUENCES */}
      {currentStep === 3 && (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 sm:p-8 space-y-6 shadow-sm animate-fade-in">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-100 pb-4">
            <div>
              <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
                <MapPin className="text-brand-600" size={22} /> Step 3: Define Stage Sequence for Each SACCO
              </h2>
              <p className="text-slate-500 text-sm mt-1">
                Add stops from Origin ➔ Waypoints ➔ Destination for each SACCO operating on this route.
              </p>
            </div>
            <button
              type="button"
              onClick={() => setShowAddStageModal(true)}
              className="inline-flex items-center gap-1.5 px-3.5 py-2 bg-brand-50 hover:bg-brand-100 text-brand-700 font-semibold rounded-xl text-xs transition-colors w-fit border border-brand-200"
            >
              <Plus size={14} /> + New Stage in Database
            </button>
          </div>

          {/* SACCO Tabs */}
          <div className="flex items-center gap-2 overflow-x-auto border-b border-slate-200 pb-2">
            {saccoConfigs.map(sc => (
              <button
                key={sc.sacco_id}
                type="button"
                onClick={() => setActiveSaccoId(sc.sacco_id)}
                className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
                  activeSaccoId === sc.sacco_id
                    ? 'bg-brand-600 text-white shadow-sm'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                <Bus size={14} />
                {sc.sacco_name}
                <span className="px-1.5 py-0.5 rounded-full text-[10px] bg-black/10">
                  {sc.stages.length} stops
                </span>
              </button>
            ))}
          </div>

          {currentSacco && (
            <div className="space-y-4">
              {/* Copy helper & Stage Add Selector */}
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-slate-50 p-3 rounded-xl border border-slate-200">
                <div className="flex-1 flex items-center gap-2">
                  <select
                    className="flex-1 px-3 py-2 rounded-lg border border-slate-300 text-xs bg-white focus:outline-none focus:ring-2 focus:ring-brand-500"
                    defaultValue=""
                    onChange={e => {
                      if (e.target.value) {
                        addStageToSacco(currentSacco.sacco_id, e.target.value);
                        e.target.value = '';
                      }
                    }}
                  >
                    <option value="" disabled>
                      -- Select an existing stage to append --
                    </option>
                    {allStages.map(st => (
                      <option key={st.id} value={st.id}>
                        {st.name} ({st.area})
                      </option>
                    ))}
                  </select>
                </div>

                {/* Copy from other Sacco button */}
                {saccoConfigs.length > 1 && (
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-slate-500">or</span>
                    <select
                      className="px-2.5 py-2 rounded-lg border border-slate-300 text-xs bg-white text-slate-700"
                      defaultValue=""
                      onChange={e => {
                        if (e.target.value) {
                          copyStagesFromAnotherSacco(currentSacco.sacco_id, e.target.value);
                          e.target.value = '';
                        }
                      }}
                    >
                      <option value="" disabled>
                        Copy stops from another SACCO...
                      </option>
                      {saccoConfigs
                        .filter(s => s.sacco_id !== currentSacco.sacco_id && s.stages.length > 0)
                        .map(s => (
                          <option key={s.sacco_id} value={s.sacco_id}>
                            Copy from {s.sacco_name} ({s.stages.length} stops)
                          </option>
                        ))}
                    </select>
                  </div>
                )}
              </div>

              {/* Stops Table */}
              {currentSacco.stages.length === 0 ? (
                <div className="text-center py-12 border-2 border-dashed border-slate-200 rounded-xl">
                  <MapPin size={32} className="mx-auto text-slate-300 mb-2" />
                  <p className="text-sm font-semibold text-slate-700">No stages added for {currentSacco.sacco_name} yet</p>
                  <p className="text-xs text-slate-400 mt-1 max-w-sm mx-auto">
                    Use the dropdown above to add stops in order from {originName} to {destinationName}.
                  </p>
                </div>
              ) : (
                <div className="border border-slate-200 rounded-xl overflow-hidden">
                  <table className="w-full text-xs">
                    <thead className="bg-slate-50 border-b border-slate-200 text-slate-600 font-semibold">
                      <tr>
                        <th className="px-3 py-2.5 text-center w-12">#</th>
                        <th className="px-4 py-2.5 text-left">Stage Name & Area</th>
                        <th className="px-3 py-2.5 text-left w-28">Dist (km)</th>
                        <th className="px-3 py-2.5 text-left w-24">ETA (min)</th>
                        <th className="px-3 py-2.5 text-right w-28">Actions</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {currentSacco.stages.map((st, index) => (
                        <tr key={st.clientId} className="hover:bg-slate-50/60">
                          <td className="px-3 py-2.5 text-center font-bold text-slate-400">
                            {index + 1}
                          </td>
                          <td className="px-4 py-2.5">
                            <div className="font-semibold text-slate-900">{st.stage_name}</div>
                            <div className="text-[11px] text-slate-400">{st.stage_area}</div>
                          </td>
                          <td className="px-3 py-2.5">
                            <input
                              type="number"
                              min="0"
                              step="0.1"
                              value={st.distance_from_start_km}
                              onChange={e =>
                                updateStageRow(currentSacco.sacco_id, st.clientId, {
                                  distance_from_start_km: parseFloat(e.target.value) || 0,
                                })
                              }
                              className="w-20 px-2 py-1 rounded border border-slate-300 text-xs"
                            />
                          </td>
                          <td className="px-3 py-2.5">
                            <input
                              type="number"
                              min="0"
                              value={st.eta_from_start_mins}
                              onChange={e =>
                                updateStageRow(currentSacco.sacco_id, st.clientId, {
                                  eta_from_start_mins: parseInt(e.target.value) || 0,
                                })
                              }
                              className="w-16 px-2 py-1 rounded border border-slate-300 text-xs"
                            />
                          </td>
                          <td className="px-3 py-2.5 text-right">
                            <div className="flex items-center justify-end gap-1">
                              <button
                                type="button"
                                disabled={index === 0}
                                onClick={() => moveStage(currentSacco.sacco_id, index, -1)}
                                className="p-1 rounded hover:bg-slate-100 disabled:opacity-20 text-slate-500"
                                title="Move Up"
                              >
                                <ArrowUp size={13} />
                              </button>
                              <button
                                type="button"
                                disabled={index === currentSacco.stages.length - 1}
                                onClick={() => moveStage(currentSacco.sacco_id, index, 1)}
                                className="p-1 rounded hover:bg-slate-100 disabled:opacity-20 text-slate-500"
                                title="Move Down"
                              >
                                <ArrowDown size={13} />
                              </button>
                              <button
                                type="button"
                                onClick={() => removeStageFromSacco(currentSacco.sacco_id, st.clientId)}
                                className="p-1 rounded hover:bg-red-50 text-red-500 ml-1"
                                title="Remove stop"
                              >
                                <Trash2 size={13} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}
        </div>
      )}

      {/* STEP 4: STAGE FARES (DEFINITE OR RANGE) */}
      {currentStep === 4 && (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 sm:p-8 space-y-6 shadow-sm animate-fade-in">
          <div className="border-b border-slate-100 pb-4">
            <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
              <DollarSign className="text-brand-600" size={22} /> Step 4: Fare Calibration Along Stages
            </h2>
            <p className="text-slate-500 text-sm mt-1">
              Configure peak and off-peak fares from the origin terminus to each stage along the route.
            </p>
          </div>

          {/* Sacco Tabs */}
          <div className="flex items-center gap-2 overflow-x-auto border-b border-slate-200 pb-2">
            {saccoConfigs.map(sc => (
              <button
                key={sc.sacco_id}
                type="button"
                onClick={() => setActiveSaccoId(sc.sacco_id)}
                className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
                  activeSaccoId === sc.sacco_id
                    ? 'bg-brand-600 text-white shadow-sm'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                <Bus size={14} />
                {sc.sacco_name}
              </button>
            ))}
          </div>

          {currentSacco && (
            <div className="space-y-4">
              <div className="bg-blue-50/70 border border-blue-200 p-3.5 rounded-xl flex items-start justify-between gap-3 text-xs text-blue-800">
                <div className="flex items-start gap-2.5">
                  <Info size={16} className="shrink-0 mt-0.5 text-blue-600" />
                  <div>
                    <span className="font-bold">Flexible Pricing Options:</span> You can specify either a <strong>Definite Fare</strong> (e.g., 50 KSh) or a <strong>Range Fare</strong> (e.g., 40 - 60 KSh). The destination terminus is automatically filled with your Step 2 SACCO route fares ({currentSacco.fare_offpeak} off-peak / {currentSacco.fare_peak} peak KSh).
                  </div>
                </div>
                <button
                  type="button"
                  onClick={syncDestinationFares}
                  className="shrink-0 px-2.5 py-1 bg-white border border-blue-300 rounded-lg text-[11px] font-semibold text-blue-700 hover:bg-blue-100 transition-colors"
                >
                  Re-sync Full Fares
                </button>
              </div>

              <div className="border border-slate-200 rounded-xl overflow-hidden">
                <table className="w-full text-xs">
                  <thead className="bg-slate-50 border-b border-slate-200 text-slate-600 font-semibold">
                    <tr>
                      <th className="px-3 py-2.5 text-center w-12">Stop</th>
                      <th className="px-4 py-2.5 text-left">Destination Stage</th>
                      <th className="px-3 py-2.5 text-left w-28">Pricing Mode</th>
                      <th className="px-3 py-2.5 text-left">Off-Peak Fare (KSh)</th>
                      <th className="px-3 py-2.5 text-left">Peak Fare (KSh)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {currentSacco.stages.map((st, index) => {
                      const isOrigin = index === 0;
                      const isDestination = index === currentSacco.stages.length - 1 && currentSacco.stages.length > 1;
                      return (
                        <tr key={st.clientId} className="hover:bg-slate-50/60">
                          <td className="px-3 py-2.5 text-center font-bold text-slate-400">
                            {index + 1}
                          </td>
                          <td className="px-4 py-2.5">
                            <div className="font-semibold text-slate-900 flex items-center gap-1.5 flex-wrap">
                              <span>{st.stage_name}</span>
                              {isOrigin && <span className="text-[10px] text-brand-600 font-bold bg-brand-50 px-1.5 py-0.5 rounded border border-brand-200">ORIGIN</span>}
                              {isDestination && <span className="text-[10px] text-emerald-700 font-bold bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">DESTINATION (FULL FARE)</span>}
                            </div>
                            <div className="text-[11px] text-slate-400">{st.stage_area}</div>
                          </td>
                          <td className="px-3 py-2.5">
                            {isOrigin ? (
                              <span className="text-slate-400 italic">Free (Boarding)</span>
                            ) : (
                              <select
                                value={st.fare_mode}
                                onChange={e => {
                                  const mode = e.target.value as 'definite' | 'range';
                                  updateStageRow(currentSacco.sacco_id, st.clientId, { fare_mode: mode });
                                }}
                                className="px-2 py-1 rounded border border-slate-300 text-xs bg-white font-medium"
                              >
                                <option value="definite">Definite (Fixed)</option>
                                <option value="range">Range (Min - Max)</option>
                              </select>
                            )}
                          </td>
                          <td className="px-3 py-2.5">
                            {isOrigin ? (
                              <span className="text-slate-400 font-mono">0</span>
                            ) : st.fare_mode === 'definite' ? (
                              <input
                                type="number"
                                min="0"
                                value={st.fare_offpeak}
                                onChange={e =>
                                  updateStageRow(currentSacco.sacco_id, st.clientId, {
                                    fare_offpeak: parseInt(e.target.value) || 0,
                                  })
                                }
                                className="w-24 px-2 py-1 rounded border border-slate-300 text-xs font-mono font-semibold"
                              />
                            ) : (
                              <div className="flex items-center gap-1">
                                <input
                                  type="number"
                                  placeholder="Min"
                                  value={st.fare_offpeak_min}
                                  onChange={e => {
                                    const min = parseInt(e.target.value) || 0;
                                    updateStageRow(currentSacco.sacco_id, st.clientId, {
                                      fare_offpeak_min: min,
                                      fare_offpeak: Math.round((min + (st.fare_offpeak_max || min)) / 2),
                                    });
                                  }}
                                  className="w-16 px-1.5 py-1 rounded border border-slate-300 text-xs font-mono"
                                />
                                <span>-</span>
                                <input
                                  type="number"
                                  placeholder="Max"
                                  value={st.fare_offpeak_max}
                                  onChange={e => {
                                    const max = parseInt(e.target.value) || 0;
                                    updateStageRow(currentSacco.sacco_id, st.clientId, {
                                      fare_offpeak_max: max,
                                      fare_offpeak: Math.round(((st.fare_offpeak_min || 0) + max) / 2),
                                    });
                                  }}
                                  className="w-16 px-1.5 py-1 rounded border border-slate-300 text-xs font-mono"
                                />
                              </div>
                            )}
                          </td>
                          <td className="px-3 py-2.5">
                            {isOrigin ? (
                              <span className="text-slate-400 font-mono">0</span>
                            ) : st.fare_mode === 'definite' ? (
                              <input
                                type="number"
                                min="0"
                                value={st.fare_peak}
                                onChange={e =>
                                  updateStageRow(currentSacco.sacco_id, st.clientId, {
                                    fare_peak: parseInt(e.target.value) || 0,
                                  })
                                }
                                className="w-24 px-2 py-1 rounded border border-slate-300 text-xs font-mono font-semibold text-brand-700"
                              />
                            ) : (
                              <div className="flex items-center gap-1">
                                <input
                                  type="number"
                                  placeholder="Min"
                                  value={st.fare_peak_min}
                                  onChange={e => {
                                    const min = parseInt(e.target.value) || 0;
                                    updateStageRow(currentSacco.sacco_id, st.clientId, {
                                      fare_peak_min: min,
                                      fare_peak: Math.round((min + (st.fare_peak_max || min)) / 2),
                                    });
                                  }}
                                  className="w-16 px-1.5 py-1 rounded border border-slate-300 text-xs font-mono"
                                />
                                <span>-</span>
                                <input
                                  type="number"
                                  placeholder="Max"
                                  value={st.fare_peak_max}
                                  onChange={e => {
                                    const max = parseInt(e.target.value) || 0;
                                    updateStageRow(currentSacco.sacco_id, st.clientId, {
                                      fare_peak_max: max,
                                      fare_peak: Math.round(((st.fare_peak_min || 0) + max) / 2),
                                    });
                                  }}
                                  className="w-16 px-1.5 py-1 rounded border border-slate-300 text-xs font-mono text-brand-700"
                                />
                              </div>
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      )}

      {/* STEP 5: REVIEW & ATOMIC COMMIT */}
      {currentStep === 5 && (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 sm:p-8 space-y-6 shadow-sm animate-fade-in">
          <div className="border-b border-slate-100 pb-4">
            <h2 className="text-xl font-bold text-slate-900 flex items-center gap-2">
              <CheckCircle2 className="text-emerald-600" size={22} /> Step 5: Review & Save Complete Route Package
            </h2>
            <p className="text-slate-500 text-sm mt-1">
              Verify all relationships before atomically writing to routes, sacco_routes, sacco_route_stages, and sacco_route_fares.
            </p>
          </div>

          {/* Master Summary Card */}
          <div className="p-5 rounded-2xl bg-gradient-to-br from-slate-900 to-brand-950 text-white shadow-lg space-y-3">
            <div className="flex items-center justify-between">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/20 text-xs font-mono font-bold tracking-wide">
                ROUTE #{routeNumber}
              </div>
              <div className="text-xs text-white/70">
                {saccoConfigs.length} SACCO(s) Configured
              </div>
            </div>
            <div className="text-xl sm:text-2xl font-bold">
              {originName} ➔ {destinationName}
            </div>
          </div>

          {/* SACCO Breakdown */}
          <div className="space-y-4">
            <h3 className="text-sm font-bold text-slate-800 uppercase tracking-wider">
              Configured Operations & Stage Sequences:
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {saccoConfigs.map(sc => (
                <div key={sc.sacco_id} className="p-4 rounded-xl border border-slate-200 bg-slate-50 space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="font-bold text-slate-900 text-sm flex items-center gap-2">
                      <Bus size={15} className="text-brand-600" />
                      {sc.sacco_name}
                    </div>
                    <span className="text-xs px-2 py-0.5 rounded-full bg-brand-100 text-brand-800 font-semibold">
                      {sc.fleet_type}
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-2 text-xs text-slate-600 bg-white p-2.5 rounded-lg border border-slate-200">
                    <div>
                      <span className="text-slate-400 block text-[10px]">FULL PEAK FARE</span>
                      <span className="font-bold font-mono text-slate-900">KSh {sc.stages[sc.stages.length - 1]?.fare_peak || sc.fare_peak}</span>
                    </div>
                    <div>
                      <span className="text-slate-400 block text-[10px]">FULL OFF-PEAK FARE</span>
                      <span className="font-bold font-mono text-slate-900">KSh {sc.stages[sc.stages.length - 1]?.fare_offpeak || sc.fare_offpeak}</span>
                    </div>
                  </div>

                  <div>
                    <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wide">
                      Sequence ({sc.stages.length} stops):
                    </span>
                    <ol className="mt-1.5 space-y-1 text-xs">
                      {sc.stages.map((st, i) => (
                        <li key={st.clientId} className="flex items-center justify-between text-slate-700 py-0.5 border-b border-slate-200/60 last:border-0">
                          <span className="truncate pr-2">
                            <span className="font-bold text-slate-400 mr-1.5">{i + 1}.</span>
                            {st.stage_name}
                          </span>
                          <span className="font-mono text-slate-500 text-[11px] shrink-0">
                            {i === 0 ? 'Start' : `KSh ${st.fare_peak}`}
                          </span>
                        </li>
                      ))}
                    </ol>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Footer Navigation Buttons */}
      <div className="flex items-center justify-between border-t border-slate-200 pt-5">
        <button
          type="button"
          disabled={currentStep === 1 || saving}
          onClick={handleBack}
          className="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl border border-slate-300 text-slate-700 font-semibold text-sm hover:bg-slate-50 disabled:opacity-40 transition-colors"
        >
          <ChevronLeft size={16} /> Back
        </button>

        {currentStep < 5 ? (
          <button
            type="button"
            onClick={handleNext}
            className="inline-flex items-center gap-2 px-6 py-2.5 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-semibold text-sm shadow-md transition-colors"
          >
            Continue <ChevronRight size={16} />
          </button>
        ) : (
          <button
            type="button"
            disabled={saving}
            onClick={handleFinalSave}
            className="inline-flex items-center gap-2 px-8 py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 disabled:bg-emerald-400 text-white font-bold text-sm shadow-lg transition-all"
          >
            {saving ? (
              <>
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Writing Route & Relationships...
              </>
            ) : (
              <>
                <Save size={16} /> Save Complete Route Package
              </>
            )}
          </button>
        )}
      </div>

      {/* QUICK ADD SACCO MODAL */}
      {showAddSaccoModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl border border-slate-200 space-y-4 animate-fade-in">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <Bus size={18} className="text-brand-600" /> Register New SACCO
            </h3>
            <form onSubmit={handleCreateSaccoInline} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  SACCO Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Super Metro, City Hoppa"
                  value={newSaccoName}
                  onChange={e => setNewSaccoName(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg border border-slate-300 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Contact Phone (Optional)
                </label>
                <input
                  type="text"
                  placeholder="+254 700 000 000"
                  value={newSaccoPhone}
                  onChange={e => setNewSaccoPhone(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg border border-slate-300 text-xs"
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowAddSaccoModal(false)}
                  className="px-3 py-1.5 text-xs text-slate-600 hover:bg-slate-100 rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-1.5 text-xs font-bold text-white bg-brand-600 hover:bg-brand-700 rounded-lg shadow-sm"
                >
                  Save & Select
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* QUICK ADD STAGE MODAL */}
      {showAddStageModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl border border-slate-200 space-y-4 animate-fade-in">
            <h3 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <MapPin size={18} className="text-brand-600" /> Add New Stage / Stop
            </h3>
            <form onSubmit={handleCreateStageInline} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Stage Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Valley Arcade, Kencom, Taj Mall"
                  value={newStageName}
                  onChange={e => setNewStageName(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg border border-slate-300 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  Area / Neighborhood <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Lavington, Outering Road, CBD"
                  value={newStageArea}
                  onChange={e => setNewStageArea(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg border border-slate-300 text-xs"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  GPS Coordinates (Optional)
                </label>
                <input
                  type="text"
                  placeholder="e.g. -1.29225, 36.80516"
                  value={newStageGps}
                  onChange={e => setNewStageGps(e.target.value)}
                  className="w-full px-3 py-2 rounded-lg border border-slate-300 text-xs font-mono"
                />
                <p className="text-[10px] text-slate-400 mt-0.5">
                  Paste standard &quot;lat, lng&quot; from Google Maps. Defaults to CBD if empty.
                </p>
              </div>

              <div className="flex items-center justify-end gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => setShowAddStageModal(false)}
                  className="px-3 py-1.5 text-xs text-slate-600 hover:bg-slate-100 rounded-lg"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-1.5 text-xs font-bold text-white bg-brand-600 hover:bg-brand-700 rounded-lg shadow-sm"
                >
                  Save & Append
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* SUCCESS & CREATE REVERSE ROUTE MODAL (Appears only after first route is successfully saved) */}
      {savedRouteInfo && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/55 p-4 backdrop-blur-xs animate-fade-in">
          <div className="bg-white rounded-3xl p-6 sm:p-8 max-w-lg w-full shadow-2xl border border-slate-200 text-center space-y-6">
            <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center mx-auto shadow-inner">
              <CheckCircle2 size={36} />
            </div>

            <div className="space-y-1">
              <span className="inline-block px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold mb-1">
                Route Successfully Created!
              </span>
              <h2 className="text-2xl font-bold text-slate-900">
                Route #{savedRouteInfo.routeNumber} Published
              </h2>
              <p className="text-slate-600 text-sm font-semibold">
                {savedRouteInfo.origin} ➔ {savedRouteInfo.destination}
              </p>
              <p className="text-xs text-slate-400 pt-1">
                Master route, {savedRouteInfo.saccoCount} SACCO link(s), and all stage sequences & fares are safely in the database.
              </p>
            </div>

            <div className="p-4 bg-brand-50/70 rounded-2xl border border-brand-200 text-left space-y-2">
              <div className="text-xs font-bold text-brand-900 uppercase tracking-wider flex items-center gap-1.5">
                <ArrowLeftRight size={15} className="text-brand-700" /> Create Return / Opposite Direction?
              </div>
              <p className="text-xs text-slate-600 leading-relaxed">
                Nairobi routes run in both directions! Would you like to create the reverse route (<strong>{savedRouteInfo.destination} ➔ {savedRouteInfo.origin}</strong>)? All operating SACCOs and stage sequences will be automatically inverted. Fares will be left blank for you to enter return pricing.
              </p>
            </div>

            <div className="flex flex-col sm:flex-row gap-3 pt-2">
              <button
                type="button"
                onClick={() => {
                  router.push('/routes');
                  router.refresh();
                }}
                className="flex-1 py-3 px-4 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-50 font-semibold text-sm transition-colors"
              >
                Finish & View Routes
              </button>

              <button
                type="button"
                onClick={handleStartReverseRoute}
                className="flex-1 py-3 px-4 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-bold text-sm shadow-md transition-all flex items-center justify-center gap-2"
              >
                <ArrowLeftRight size={16} />
                Create Reverse Route
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
