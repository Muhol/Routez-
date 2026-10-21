'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { stageSchema, type StageFormValues, parseLatLng } from '@/lib/validation/schemas';
import { createClient } from '@/lib/supabase/client';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import Link from 'next/link';
import { ArrowLeft, MapPin } from 'lucide-react';
import { useState, useEffect, useCallback } from 'react';
import dynamic from 'next/dynamic';
import type { Stage } from '@/types/database';

// Dynamically import the map (Leaflet needs browser)
const StageMapPicker = dynamic(() => import('./StageMapPicker'), {
  ssr: false,
  loading: () => (
    <div className="h-64 rounded-lg bg-slate-100 flex items-center justify-center text-slate-400 text-sm">
      Loading map…
    </div>
  ),
});

interface StageFormProps {
  existing?: Stage;
}

export default function StageForm({ existing }: StageFormProps) {
  const router = useRouter();
  const supabase = createClient();
  const isEdit = !!existing;

  const [rawGps, setRawGps] = useState('');
  const [gpsParseError, setGpsParseError] = useState('');

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors, isSubmitting },
  } = useForm<StageFormValues>({
    resolver: zodResolver(stageSchema),
    defaultValues: existing
      ? {
          name: existing.name,
          area: existing.area,
          latitude: existing.latitude,
          longitude: existing.longitude,
        }
      : {},
  });

  const lat = watch('latitude');
  const lng = watch('longitude');

  // Handle pasted combined GPS
  function handleGpsPaste(value: string) {
    setRawGps(value);
    const parsed = parseLatLng(value);
    if (parsed) {
      setValue('latitude', parsed.latitude, { shouldValidate: true });
      setValue('longitude', parsed.longitude, { shouldValidate: true });
      setGpsParseError('');
    } else if (value.trim()) {
      setGpsParseError('Could not parse coordinates. Use format: -1.2922, 36.8051');
    } else {
      setGpsParseError('');
    }
  }

  // Called when user clicks on the map
  const handleMapClick = useCallback(
    (newLat: number, newLng: number) => {
      setValue('latitude', newLat, { shouldValidate: true });
      setValue('longitude', newLng, { shouldValidate: true });
      setRawGps(`${newLat}, ${newLng}`);
    },
    [setValue]
  );

  async function onSubmit(values: StageFormValues) {
    // Nairobi bounding box soft warning
    const inNairobi =
      values.latitude >= -1.5 && values.latitude <= -1.1 &&
      values.longitude >= 36.6 && values.longitude <= 37.1;
    if (!inNairobi) {
      const ok = window.confirm(
        `These coordinates (${values.latitude}, ${values.longitude}) are outside the expected Nairobi area.\n\nAre you sure the coordinates are correct?`
      );
      if (!ok) return;
    }

    const payload = {
      name: values.name,
      area: values.area,
      latitude: values.latitude,
      longitude: values.longitude,
    };

    const { error } = isEdit
      ? await supabase.from('stages').update(payload).eq('id', existing!.id)
      : await supabase.from('stages').insert(payload);

    if (error) {
      toast.error(`Failed to save: ${error.message}`);
    } else {
      toast.success(isEdit ? 'Stage updated' : 'Stage created');
      router.push('/stages');
      router.refresh();
    }
  }

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in max-w-2xl">
      <div>
        <Link href="/stages" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700 mb-4">
          <ArrowLeft size={14} /> Back to Stages
        </Link>
        <h1 className="text-2xl font-bold text-slate-900">{isEdit ? 'Edit Stage' : 'Add Stage'}</h1>
        <p className="text-slate-500 mt-1 text-sm">
          All four fields are required. You can paste GPS coordinates or click the map.
        </p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        <div className="bg-white rounded-xl border border-slate-200 p-6 space-y-5">
          {/* Name */}
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-slate-700 mb-1.5">
              Stage Name <span className="text-red-500">*</span>
            </label>
            <input id="name" {...register('name')}
              placeholder="e.g. Valley Road, Yaya Centre"
              className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                         focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400" />
            {errors.name && <p className="text-xs text-red-600 mt-1">{errors.name.message}</p>}
          </div>

          {/* Area */}
          <div>
            <label htmlFor="area" className="block text-sm font-medium text-slate-700 mb-1.5">
              Area / Neighbourhood <span className="text-red-500">*</span>
            </label>
            <input id="area" {...register('area')}
              placeholder="e.g. Kilimani, Kawangware, CBD"
              className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                         focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400" />
            <p className="text-xs text-slate-400 mt-1">
              Used to distinguish stages with similar names in different areas.
            </p>
            {errors.area && <p className="text-xs text-red-600 mt-1">{errors.area.message}</p>}
          </div>

          {/* Combined GPS paste */}
          <div>
            <label htmlFor="gps_paste" className="block text-sm font-medium text-slate-700 mb-1.5">
              Paste GPS Coordinates <span className="text-slate-400 font-normal">(optional shortcut)</span>
            </label>
            <input
              id="gps_paste"
              value={rawGps}
              onChange={(e) => handleGpsPaste(e.target.value)}
              placeholder="-1.2922522, 36.8051638"
              className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm font-mono
                         focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400"
            />
            {gpsParseError && <p className="text-xs text-red-600 mt-1">{gpsParseError}</p>}
            <p className="text-xs text-slate-400 mt-1">
              Paste combined "lat, lng" from your spreadsheet — it will split automatically.
            </p>
          </div>

          {/* Lat / Lng */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="latitude" className="block text-sm font-medium text-slate-700 mb-1.5">
                Latitude <span className="text-red-500">*</span>
              </label>
              <input id="latitude" {...register('latitude')} type="number" step="any"
                placeholder="-1.2922522"
                className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm font-mono
                           focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400" />
              {errors.latitude && <p className="text-xs text-red-600 mt-1">{errors.latitude.message}</p>}
            </div>
            <div>
              <label htmlFor="longitude" className="block text-sm font-medium text-slate-700 mb-1.5">
                Longitude <span className="text-red-500">*</span>
              </label>
              <input id="longitude" {...register('longitude')} type="number" step="any"
                placeholder="36.8051638"
                className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm font-mono
                           focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400" />
              {errors.longitude && <p className="text-xs text-red-600 mt-1">{errors.longitude.message}</p>}
            </div>
          </div>
        </div>

        {/* Map */}
        <div className="bg-white rounded-xl border border-slate-200 p-4">
          <div className="flex items-center gap-2 mb-3">
            <MapPin size={15} className="text-brand-600" />
            <p className="text-sm font-medium text-slate-700">
              Click the map to set or adjust the stage location
            </p>
          </div>
          <StageMapPicker
            latitude={lat}
            longitude={lng}
            onLocationChange={handleMapClick}
          />
          {(lat !== undefined && lng !== undefined && !isNaN(lat) && !isNaN(lng)) && (
            <p className="text-xs text-slate-400 mt-2 font-mono">
              Selected: {lat}, {lng}
            </p>
          )}
        </div>

        <div className="flex items-center gap-3">
          <button type="submit" disabled={isSubmitting}
            className="px-5 py-2.5 bg-brand-600 hover:bg-brand-700 disabled:bg-brand-300
                       text-white text-sm font-medium rounded-lg transition-colors">
            {isSubmitting ? 'Saving…' : isEdit ? 'Save Changes' : 'Create Stage'}
          </button>
          <Link href="/stages"
            className="px-5 py-2.5 border border-slate-300 hover:bg-slate-50 text-slate-600
                       text-sm font-medium rounded-lg transition-colors">
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
