-- 1. Create the staff_profiles table
CREATE TABLE IF NOT EXISTS public.staff_profiles (
  id uuid REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email text NOT NULL,
  name text NOT NULL,
  role text NOT NULL DEFAULT 'customer_service',
  branch_id text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.staff_profiles ENABLE ROW LEVEL SECURITY;

-- 3. Create basic policies
-- Allow all authenticated users to read staff profiles
CREATE POLICY "Allow authenticated users to read staff profiles"
ON public.staff_profiles
FOR SELECT
TO authenticated
USING (true);

-- Allow users to update their own profile
CREATE POLICY "Allow users to update own profile"
ON public.staff_profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id);

-- 4. Create sample users directly via SQL
-- Note: Supabase provides the `crypt` extension which is used by auth.users
-- Password for all below is 'password123'

DO $$
DECLARE
  v_admin_id uuid := gen_random_uuid();
  v_manager_id uuid := gen_random_uuid();
  v_cs_id uuid := gen_random_uuid();
  v_dm_id uuid := gen_random_uuid();
  v_delivery_id uuid := gen_random_uuid();
BEGIN
  -- Insert into auth.users
  INSERT INTO auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
  VALUES 
    (v_admin_id, 'authenticated', 'authenticated', 'admin_test@sabeh.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now()),
    (v_manager_id, 'authenticated', 'authenticated', 'manager_test@sabeh.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now()),
    (v_cs_id, 'authenticated', 'authenticated', 'cs_test@sabeh.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now()),
    (v_dm_id, 'authenticated', 'authenticated', 'dm_test@sabeh.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now()),
    (v_delivery_id, 'authenticated', 'authenticated', 'delivery_test@sabeh.com', crypt('password123', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now());

  -- Insert into auth.identities
  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), v_admin_id, v_admin_id::text, format('{"sub":"%s","email":"%s"}', v_admin_id::text, 'admin_test@sabeh.com')::jsonb, 'email', now(), now(), now()),
    (gen_random_uuid(), v_manager_id, v_manager_id::text, format('{"sub":"%s","email":"%s"}', v_manager_id::text, 'manager_test@sabeh.com')::jsonb, 'email', now(), now(), now()),
    (gen_random_uuid(), v_cs_id, v_cs_id::text, format('{"sub":"%s","email":"%s"}', v_cs_id::text, 'cs_test@sabeh.com')::jsonb, 'email', now(), now(), now()),
    (gen_random_uuid(), v_dm_id, v_dm_id::text, format('{"sub":"%s","email":"%s"}', v_dm_id::text, 'dm_test@sabeh.com')::jsonb, 'email', now(), now(), now()),
    (gen_random_uuid(), v_delivery_id, v_delivery_id::text, format('{"sub":"%s","email":"%s"}', v_delivery_id::text, 'delivery_test@sabeh.com')::jsonb, 'email', now(), now(), now());

  -- Insert into public.staff_profiles
  INSERT INTO public.staff_profiles (id, email, name, role, is_active)
  VALUES
    (v_admin_id, 'admin_test@sabeh.com', 'Admin User', 'admin', true),
    (v_manager_id, 'manager_test@sabeh.com', 'Manager User', 'manager', true),
    (v_cs_id, 'cs_test@sabeh.com', 'Customer Service', 'customer_service', true),
    (v_dm_id, 'dm_test@sabeh.com', 'Delivery Manager', 'delivery_manager', true),
    (v_delivery_id, 'delivery_test@sabeh.com', 'Delivery User', 'delivery_user', true);
END $$;
