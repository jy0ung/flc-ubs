begin;

create extension if not exists pgcrypto;
create extension if not exists citext;
create extension if not exists pg_trgm;

create schema if not exists core;
create schema if not exists sales;
create schema if not exists svc;
create schema if not exists inv;
create schema if not exists acct;
create schema if not exists hr;
create schema if not exists audit;
create schema if not exists analytics;

create type sales.booking_status as enum (
  'draft',
  'submitted',
  'reserved',
  'deposit_pending',
  'deposit_verified',
  'invoiced',
  'completed',
  'expired',
  'cancelled'
);

create type sales.payment_verification_status as enum (
  'pending',
  'verified',
  'rejected'
);

create type sales.refund_status as enum (
  'requested',
  'approved',
  'rejected',
  'processed',
  'cancelled'
);

create type svc.appointment_status as enum (
  'scheduled',
  'checked_in',
  'cancelled',
  'completed',
  'no_show'
);

create type svc.work_order_status as enum (
  'opened',
  'in_progress',
  'waiting_approval',
  'waiting_parts',
  'completed',
  'delivered',
  'closed',
  'cancelled'
);

create type acct.journal_status as enum (
  'draft',
  'posted',
  'reversed'
);

create type hr.leave_request_status as enum (
  'draft',
  'submitted',
  'approved',
  'rejected',
  'cancelled'
);

create type inv.adjustment_type as enum (
  'stock_in',
  'stock_out',
  'adjustment',
  'transfer'
);

create type inv.stock_status as enum (
  'active',
  'discontinued',
  'out_of_stock'
);

create type core.notification_status as enum (
  'queued',
  'processing',
  'sent',
  'failed',
  'cancelled'
);

create or replace function core.current_app_user_id()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

create or replace function core.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

commit;
