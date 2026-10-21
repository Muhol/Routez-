'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { saccoSchema, type SaccoFormValues } from '@/lib/validation/schemas';
import { createClient } from '@/lib/supabase/client';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import type { Sacco } from '@/types/database';

export default function SaccoForm({ existing }: { existing?: Sacco }) {
  const router = useRouter();
  const supabase = createClient();
  const isEdit = !!existing;

  const { register, handleSubmit, watch, formState: { errors, isSubmitting } } = useForm<SaccoFormValues>({
    resolver: zodResolver(saccoSchema),
    defaultValues: existing
      ? { name: existing.name, logo_url: existing.logo_url ?? '', contact_phone: existing.contact_phone ?? '', rating: existing.rating }
      : { rating: 4.5 },
  });

  const logoUrl = watch('logo_url');

  async function onSubmit(values: SaccoFormValues) {
    if (!isEdit) {
      const { data: similar } = await supabase.from('saccos').select('id, name').ilike('name', `%${values.name}%`);
      if (similar && similar.length > 0) {
        const ok = window.confirm(
          `A SACCO with a similar name already exists: "${similar[0].name}".\nDo you still want to create a new one?`
        );
        if (!ok) return;
      }
    }

    const payload = {
      name: values.name,
      logo_url: values.logo_url || null,
      contact_phone: values.contact_phone || null,
      rating: values.rating,
    };

    const { error } = isEdit
      ? await supabase.from('saccos').update(payload).eq('id', existing!.id)
      : await supabase.from('saccos').insert(payload);

    if (error) {
      toast.error(`Failed to save: ${error.message}`);
    } else {
      toast.success(isEdit ? 'SACCO updated' : 'SACCO created');
      router.push('/saccos');
      router.refresh();
    }
  }

  return (
    <div className="p-6 lg:p-8 space-y-6 animate-fade-in max-w-xl">
      <div>
        <Link href="/saccos" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700 mb-4">
          <ArrowLeft size={14} /> Back to SACCOs
        </Link>
        <h1 className="text-2xl font-bold text-slate-900">{isEdit ? 'Edit SACCO' : 'Add SACCO'}</h1>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="bg-white rounded-xl border border-slate-200 p-6 space-y-5">
        <div>
          <label htmlFor="name" className="block text-sm font-medium text-slate-700 mb-1.5">
            SACCO Name <span className="text-red-500">*</span>
          </label>
          <input id="name" {...register('name')} placeholder="e.g. Super Metro, Citi Hoppa"
            className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                       focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400" />
          {errors.name && <p className="text-xs text-red-600 mt-1">{errors.name.message}</p>}
        </div>

        <div>
          <label htmlFor="contact_phone" className="block text-sm font-medium text-slate-700 mb-1.5">
            Contact Phone <span className="text-slate-400 font-normal">(optional)</span>
          </label>
          <input id="contact_phone" {...register('contact_phone')} placeholder="+254 700 111 222"
            className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                       focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400" />
        </div>

        <div>
          <label htmlFor="logo_url" className="block text-sm font-medium text-slate-700 mb-1.5">
            Logo URL <span className="text-slate-400 font-normal">(optional)</span>
          </label>
          <input id="logo_url" {...register('logo_url')} placeholder="https://example.com/logo.png"
            className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                       focus:ring-2 focus:ring-brand-500 focus:border-brand-500 placeholder:text-slate-400" />
          {errors.logo_url && <p className="text-xs text-red-600 mt-1">{errors.logo_url.message}</p>}
          {logoUrl && (
            <div className="mt-2 flex items-center gap-2">
              <img src={logoUrl} alt="Logo preview" className="w-10 h-10 rounded-full object-cover border border-slate-200"
                onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }} />
              <span className="text-xs text-slate-400">Logo preview</span>
            </div>
          )}
        </div>

        <div>
          <label htmlFor="rating" className="block text-sm font-medium text-slate-700 mb-1.5">
            Rating (0–5)
          </label>
          <input id="rating" {...register('rating')} type="number" step="0.1" min="0" max="5"
            className="w-32 px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm focus:outline-none
                       focus:ring-2 focus:ring-brand-500 focus:border-brand-500" />
          {errors.rating && <p className="text-xs text-red-600 mt-1">{errors.rating.message}</p>}
        </div>

        <div className="flex items-center gap-3 pt-2">
          <button type="submit" disabled={isSubmitting}
            className="px-5 py-2.5 bg-brand-600 hover:bg-brand-700 disabled:bg-brand-300
                       text-white text-sm font-medium rounded-lg transition-colors">
            {isSubmitting ? 'Saving…' : isEdit ? 'Save Changes' : 'Create SACCO'}
          </button>
          <Link href="/saccos"
            className="px-5 py-2.5 border border-slate-300 hover:bg-slate-50 text-slate-600
                       text-sm font-medium rounded-lg transition-colors">
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
