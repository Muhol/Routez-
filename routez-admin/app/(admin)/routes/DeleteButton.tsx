'use client';

import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { Trash2 } from 'lucide-react';

interface DeleteButtonProps {
  id: string;
  label: string;
  table: string;
}

export default function DeleteButton({ id, label, table }: DeleteButtonProps) {
  const [confirming, setConfirming] = useState(false);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const supabase = createClient();

  async function handleDelete() {
    setLoading(true);
    const { error } = await supabase.from(table).delete().eq('id', id);
    if (error) {
      toast.error(`Could not delete: ${error.message}`);
    } else {
      toast.success(`${label} deleted`);
      router.refresh();
    }
    setLoading(false);
    setConfirming(false);
  }

  if (confirming) {
    return (
      <div className="flex items-center gap-1.5">
        <span className="text-xs text-slate-500">Sure?</span>
        <button
          onClick={handleDelete}
          disabled={loading}
          className="px-2 py-1 text-xs bg-red-600 hover:bg-red-700 text-white rounded transition-colors disabled:opacity-50"
        >
          {loading ? '…' : 'Delete'}
        </button>
        <button
          onClick={() => setConfirming(false)}
          className="px-2 py-1 text-xs border border-slate-300 rounded text-slate-600 hover:bg-slate-50 transition-colors"
        >
          Cancel
        </button>
      </div>
    );
  }

  return (
    <button
      onClick={() => setConfirming(true)}
      className="p-1.5 rounded hover:bg-red-50 text-slate-400 hover:text-red-600 transition-colors"
      title="Delete"
    >
      <Trash2 size={14} />
    </button>
  );
}
