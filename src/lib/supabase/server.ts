import { createClient } from '@supabase/supabase-js';

export function createSupabaseServerClient() {
  const url = import.meta.env.PUBLIC_SUPABASE_URL;
  const key = import.meta.env.PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) throw new Error('Supabase environment variables are missing.');
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}
