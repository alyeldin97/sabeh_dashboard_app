-- Migration: order types, rejected status, late thresholds, loyalty reason
-- Run this in Supabase SQL editor

-- 1. Add order_type column to orders
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS order_type text NOT NULL DEFAULT 'normal';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'orders_order_type_check' AND conrelid = 'public.orders'::regclass
  ) THEN
    ALTER TABLE public.orders
      ADD CONSTRAINT orders_order_type_check CHECK (order_type IN ('normal', 'compensation'));
  END IF;
END $$;

-- 2. Extend status check constraint to include 'rejected'
-- Drop existing constraint if it exists, then recreate with 'rejected'
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'orders_status_check' AND conrelid = 'public.orders'::regclass
  ) THEN
    ALTER TABLE public.orders DROP CONSTRAINT orders_status_check;
  END IF;
END $$;

ALTER TABLE public.orders
  ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending','confirmed','preparing','prepared','out_for_delivery','delivered','cancelled','rejected'));

-- 3. Add late-threshold columns to app_settings
ALTER TABLE public.app_settings
  ADD COLUMN IF NOT EXISTS late_pending_minutes integer NOT NULL DEFAULT 30,
  ADD COLUMN IF NOT EXISTS late_confirmed_minutes integer NOT NULL DEFAULT 30,
  ADD COLUMN IF NOT EXISTS late_preparing_minutes integer NOT NULL DEFAULT 30,
  ADD COLUMN IF NOT EXISTS late_prepared_minutes integer NOT NULL DEFAULT 30,
  ADD COLUMN IF NOT EXISTS late_out_for_delivery_minutes integer NOT NULL DEFAULT 60;

-- 4. Add reason column to loyalty_transactions (visible in history)
ALTER TABLE public.loyalty_transactions
  ADD COLUMN IF NOT EXISTS reason text;

-- 5. Add status_changed_at column to orders (tracks when order last changed status)
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS status_changed_at timestamptz NOT NULL DEFAULT NOW();
