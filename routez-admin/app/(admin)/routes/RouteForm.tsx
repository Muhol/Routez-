'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { routeSchema, type RouteFormValues } from '@/lib/validation/schemas';
import { createClient } from '@/lib/supabase/client';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import type { Route } from '@/types/database';

interface RouteFormProps {
  existing?: Route;
}

export default function RouteForm({ existing }: RouteFormProps) {
  const router = useRouter();
  const supabase = createClient();
  const isEdit = !!existing;

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<RouteFormValues>({
    resolver: zodResolver(routeSchema),
    defaultValues: existing
      ? {
          route_number: existing.route_number,
          origin_name: existing.origin_name,
          destination_name: existing.destination_name,
        }
      : {},
  });

  async function onSubmit(values: RouteFormValues) {
    // Check for similar existing routes to warn about duplicates
    if (!isEdit) {
      const { data: similar } = await supabase
        .from('routes')
        .select('id, route_number, origin_name, destination_name')
        .eq('route_number', values.route_number);
      if (similar && similar.length > 0) {
        const confirmed = window.confirm(
          `A route with number "${values.route_number}" already exists: ` +
          `${similar[0].origin_name} → ${similar[0].destination_name}.\n\n` +
          `Do you want to create another route with the same number?`
        );
        if (!confirmed) return;
      }
    }

    const payload = {
      route_number: values.route_number,
      origin_name: values.origin_name,
      destination_name: values.destination_name,
    };

    const { error } = isEdit
      ? await supabase.from('routes').update(payload).eq('id', existing!.id)
      : await supabase.from('routes').insert(payload);

    if (error) {
      toast.error(`Failed to save: ${error.message}`);
    } else {
      toast.success(isEdit ? 'Route updated' : 'Route created');
      router.push('/routes');
      router.refresh();
    }
  }

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in max-w-xl">
      <div>
        <Link href="/routes" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700 mb-4">
          <ArrowLeft size={14} /> Back to Routes
        </Link>
        <h1 className="text-2xl font-bold text-slate-900">
          {isEdit ? 'Edit Route' : 'Add Route'}
        </h1>
        <p className="text-slate-500 mt-1 text-sm">
          Route numbers can contain letters (e.g. 7c). They are stored as text.
        </p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="bg-white rounded-xl border border-slate-200 p-6 space-y-5">
        {/* Route Number */}
        <div>
          <label htmlFor="route_number" className="block text-sm font-medium text-slate-700 mb-1.5">
            Route Number <span className="text-red-500">*</span>
          </label>
          <input
            id="route_number"
            {...register('route_number')}
            placeholder="e.g. 46, 2, 7c, 8"
            className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                       focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400"
          />
          <p className="text-xs text-slate-400 mt-1">
            Alphanumeric values like "7c" are fully supported.
          </p>
          {errors.route_number && (
            <p className="text-xs text-red-600 mt-1">{errors.route_number.message}</p>
          )}
        </div>

        {/* Origin */}
        <div>
          <label htmlFor="origin_name" className="block text-sm font-medium text-slate-700 mb-1.5">
            Origin (From) <span className="text-red-500">*</span>
          </label>
          <input
            id="origin_name"
            {...register('origin_name')}
            placeholder="e.g. CBD, Kawangware"
            className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                       focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400"
          />
          {errors.origin_name && (
            <p className="text-xs text-red-600 mt-1">{errors.origin_name.message}</p>
          )}
        </div>

        {/* Destination */}
        <div>
          <label htmlFor="destination_name" className="block text-sm font-medium text-slate-700 mb-1.5">
            Destination (To) <span className="text-red-500">*</span>
          </label>
          <input
            id="destination_name"
            {...register('destination_name')}
            placeholder="e.g. Kawangware, Kenyatta"
            className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                       focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400"
          />
          {errors.destination_name && (
            <p className="text-xs text-red-600 mt-1">{errors.destination_name.message}</p>
          )}
        </div>

        <div className="flex items-center gap-3 pt-2">
          <button
            type="submit"
            disabled={isSubmitting}
            className="px-5 py-2.5 bg-brand-600 hover:bg-brand-700 disabled:bg-brand-300
                       text-white text-sm font-medium rounded-lg transition-colors"
          >
            {isSubmitting ? 'Saving…' : isEdit ? 'Save Changes' : 'Create Route'}
          </button>
          <Link href="/routes"
            className="px-5 py-2.5 border border-slate-300 hover:bg-slate-50 text-slate-600
                       text-sm font-medium rounded-lg transition-colors">
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
