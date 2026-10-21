import { createClient } from '@/lib/supabase/server';
import { notFound } from 'next/navigation';
import StageForm from '../../StageForm';

export default async function EditStagePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: stage } = await supabase.from('stages').select('*').eq('id', id).single();
  if (!stage) notFound();
  return <StageForm existing={stage} />;
}
