import { createClient } from '@/lib/supabase/server';
import { notFound } from 'next/navigation';
import SaccoForm from '../../SaccoForm';

export default async function EditSaccoPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data } = await supabase.from('saccos').select('*').eq('id', id).single();
  if (!data) notFound();
  return <SaccoForm existing={data} />;
}
