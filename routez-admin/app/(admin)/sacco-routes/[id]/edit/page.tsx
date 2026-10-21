import { createClient } from '@/lib/supabase/server';
import { notFound } from 'next/navigation';
import SaccoRouteForm from '../../SaccoRouteForm';
export default async function EditSaccoRoutePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data } = await supabase.from('sacco_routes').select('*').eq('id', id).single();
  if (!data) notFound();
  return <SaccoRouteForm existing={data} />;
}
