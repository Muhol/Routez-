'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { toast } from 'sonner';

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const [isSignUp, setIsSignUp] = useState(false);

  async function handleAuth(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);

    if (isSignUp) {
      const { data, error } = await supabase.auth.signUp({ email, password });

      if (error) {
        toast.error(error.message || 'Failed to create account.');
      } else if (data.session) {
        toast.success('Account created and signed in successfully!');
        router.push('/dashboard');
        router.refresh();
      } else {
        toast.success('Account created! If email confirmation is enabled, check your inbox or confirm in Supabase dashboard.');
      }
    } else {
      const { error } = await supabase.auth.signInWithPassword({ email, password });

      if (error) {
        toast.error(error.message || 'Sign-in failed. Check your email and password.');
      } else {
        toast.success('Signed in successfully');
        router.push('/dashboard');
        router.refresh();
      }
    }

    setLoading(false);
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-100 to-brand-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo / Brand */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-brand-600 text-white text-2xl font-bold mb-4 shadow-lg">
            R
          </div>
          <h1 className="text-2xl font-bold text-slate-900">Routez Admin</h1>
          <p className="text-slate-500 mt-1 text-sm">Nairobi Matatu Data Management</p>
        </div>

        {/* Card */}
        <div className="bg-white rounded-2xl shadow-xl border border-slate-200 p-8">
          <div className="flex border-b border-slate-200 mb-6">
            <button
              type="button"
              onClick={() => setIsSignUp(false)}
              className={`flex-1 pb-3 text-sm font-semibold border-b-2 transition-colors ${
                !isSignUp
                  ? 'border-brand-600 text-brand-600'
                  : 'border-transparent text-slate-400 hover:text-slate-600'
              }`}
            >
              Sign In
            </button>
            <button
              type="button"
              onClick={() => setIsSignUp(true)}
              className={`flex-1 pb-3 text-sm font-semibold border-b-2 transition-colors ${
                isSignUp
                  ? 'border-brand-600 text-brand-600'
                  : 'border-transparent text-slate-400 hover:text-slate-600'
              }`}
            >
              Create Admin Account
            </button>
          </div>

          <form onSubmit={handleAuth} className="space-y-5">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-slate-700 mb-1.5">
                Email address
              </label>
              <input
                id="email"
                type="email"
                autoComplete="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@example.com"
                className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm
                           focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500
                           placeholder:text-slate-400 transition-colors"
              />
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-slate-700 mb-1.5">
                Password
              </label>
              <input
                id="password"
                type="password"
                autoComplete={isSignUp ? 'new-password' : 'current-password'}
                required
                minLength={6}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full px-3.5 py-2.5 rounded-lg border border-slate-300 text-sm
                           focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500
                           placeholder:text-slate-400 transition-colors"
              />
              {isSignUp && (
                <p className="mt-1 text-xs text-slate-400">At least 6 characters</p>
              )}
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-2.5 px-4 bg-brand-600 hover:bg-brand-700 disabled:bg-brand-300
                         text-white font-medium rounded-lg text-sm transition-colors
                         focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2"
            >
              {loading
                ? isSignUp
                  ? 'Creating account…'
                  : 'Signing in…'
                : isSignUp
                ? 'Create Account & Sign In'
                : 'Sign In'}
            </button>
          </form>

          <p className="mt-6 text-xs text-slate-400 text-center">
            Connected to your Supabase project (<code>blcvbmbdvfqwbvxmzuix</code>).
          </p>
        </div>
      </div>
    </div>
  );
}
