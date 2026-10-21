import { createClient } from '@/lib/supabase/server';
import { notFound } from 'next/navigation';
import RouteForm from '../../RouteForm';

export default async function EditRoutePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: route } = await supabase.from('routes').select('*').eq('id', id).single();
  if (!route) notFound();
  return <RouteForm existing={route} />;
}
