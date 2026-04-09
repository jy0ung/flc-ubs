begin;

create extension if not exists pgcrypto;
create extension if not exists citext;
create extension if not exists pg_trgm;

create schema if not exists core;
create schema if not exists sales;
create schema if not exists svc;
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
begin;

create table if not exists core.branches (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists core.roles (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  category text not null default 'business',
  is_system boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists core.permissions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  module_name text not null,
  action_name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists core.role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_code text not null references core.roles(code) on delete cascade,
  permission_code text not null references core.permissions(code) on delete cascade,
  created_at timestamptz not null default now(),
  unique (role_code, permission_code)
);

create table if not exists core.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  email citext,
  home_branch_id uuid references core.branches(id),
  phone text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists core.user_branch_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  branch_id uuid not null references core.branches(id) on delete cascade,
  role_code text not null references core.roles(code),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, branch_id, role_code)
);

create table if not exists core.reference_values (
  id uuid primary key default gen_random_uuid(),
  domain_name text not null,
  value_key text not null,
  label text not null,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  value_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (domain_name, value_key)
);

create table if not exists core.attachments (
  id uuid primary key default gen_random_uuid(),
  storage_bucket text not null default 'attachments',
  storage_path text not null unique,
  original_filename text not null,
  mime_type text,
  size_bytes bigint not null default 0 check (size_bytes >= 0),
  checksum_sha256 text,
  entity_type text,
  entity_id uuid,
  uploaded_by uuid references auth.users(id),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists core.notification_queue (
  id uuid primary key default gen_random_uuid(),
  notification_type text not null,
  recipient text not null,
  subject text,
  payload jsonb not null default '{}'::jsonb,
  status core.notification_status not null default 'queued',
  retry_count integer not null default 0,
  scheduled_at timestamptz,
  sent_at timestamptz,
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

commit;
begin;

create table if not exists sales.customers (
  id uuid primary key default gen_random_uuid(),
  customer_code text not null unique,
  full_name text not null,
  id_type text,
  id_value_encrypted bytea,
  id_last4 text,
  phone text,
  email citext,
  address_json jsonb not null default '{}'::jsonb,
  branch_id uuid not null references core.branches(id),
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists sales.customer_contacts (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references sales.customers(id) on delete cascade,
  contact_type text not null default 'other',
  full_name text not null,
  phone text,
  email citext,
  is_primary boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists sales.bookings (
  id uuid primary key default gen_random_uuid(),
  booking_no text not null unique,
  customer_id uuid not null references sales.customers(id),
  branch_id uuid not null references core.branches(id),
  sales_owner_user_id uuid references auth.users(id),
  booking_date date not null default current_date,
  reserved_until timestamptz,
  status sales.booking_status not null default 'draft',
  model_code text not null,
  amount_total numeric(14,2) not null default 0 check (amount_total >= 0),
  deposit_amount numeric(14,2) not null default 0 check (deposit_amount >= 0),
  currency_code text not null default 'MYR',
  notes text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists sales.booking_status_events (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references sales.bookings(id) on delete cascade,
  from_status sales.booking_status,
  to_status sales.booking_status not null,
  changed_by uuid references auth.users(id),
  reason_code text,
  notes text,
  changed_at timestamptz not null default now()
);

create table if not exists sales.reservations (
  id uuid primary key default gen_random_uuid(),
  reservation_no text not null unique,
  booking_id uuid not null references sales.bookings(id) on delete cascade,
  reserved_at timestamptz not null default now(),
  reserved_until timestamptz not null,
  status text not null default 'active',
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists sales.payments (
  id uuid primary key default gen_random_uuid(),
  payment_no text unique,
  booking_id uuid not null references sales.bookings(id) on delete cascade,
  payment_date date not null default current_date,
  amount numeric(14,2) not null check (amount > 0),
  method text not null,
  reference_no text,
  verification_status sales.payment_verification_status not null default 'pending',
  verified_by uuid references auth.users(id),
  verified_at timestamptz,
  attachment_id uuid references core.attachments(id),
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists sales.refunds (
  id uuid primary key default gen_random_uuid(),
  refund_no text not null unique,
  booking_id uuid not null references sales.bookings(id) on delete cascade,
  amount numeric(14,2) not null check (amount > 0),
  reason text,
  status sales.refund_status not null default 'requested',
  requested_by uuid references auth.users(id),
  requested_at timestamptz not null default now(),
  approved_by uuid references auth.users(id),
  approved_at timestamptz,
  processed_by uuid references auth.users(id),
  processed_at timestamptz,
  attachment_id uuid references core.attachments(id),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists sales.invoices (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references sales.bookings(id),
  customer_id uuid not null references sales.customers(id),
  branch_id uuid not null references core.branches(id),
  invoice_no text not null unique,
  invoice_date date not null,
  due_date date,
  subtotal numeric(14,2) not null default 0 check (subtotal >= 0),
  tax_amount numeric(14,2) not null default 0 check (tax_amount >= 0),
  total_amount numeric(14,2) not null default 0 check (total_amount >= 0),
  status text not null default 'draft',
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

commit;
begin;

create table if not exists svc.vehicles (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references sales.customers(id),
  branch_id uuid references core.branches(id),
  reg_no text,
  chassis_no text,
  engine_no text,
  make text,
  model text,
  variant text,
  vehicle_year integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (reg_no),
  unique (chassis_no)
);

create table if not exists svc.service_appointments (
  id uuid primary key default gen_random_uuid(),
  appointment_no text not null unique,
  vehicle_id uuid references svc.vehicles(id),
  customer_id uuid not null references sales.customers(id),
  branch_id uuid not null references core.branches(id),
  appointment_at timestamptz not null,
  service_type text not null,
  advisor_user_id uuid references auth.users(id),
  status svc.appointment_status not null default 'scheduled',
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists svc.work_orders (
  id uuid primary key default gen_random_uuid(),
  wo_no text not null unique,
  appointment_id uuid references svc.service_appointments(id),
  vehicle_id uuid references svc.vehicles(id),
  customer_id uuid not null references sales.customers(id),
  branch_id uuid not null references core.branches(id),
  service_manager_user_id uuid references auth.users(id),
  opened_at timestamptz not null default now(),
  started_at timestamptz,
  completed_at timestamptz,
  delivered_at timestamptz,
  status svc.work_order_status not null default 'opened',
  total_amount numeric(14,2) not null default 0 check (total_amount >= 0),
  notes text,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists svc.work_order_items (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid not null references svc.work_orders(id) on delete cascade,
  line_no integer not null,
  item_type text not null default 'service',
  description text not null,
  quantity numeric(12,2) not null default 1 check (quantity > 0),
  unit_price numeric(14,2) not null default 0 check (unit_price >= 0),
  line_total numeric(14,2) generated always as (round((quantity * unit_price)::numeric, 2)) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (work_order_id, line_no)
);

create table if not exists svc.work_order_status_events (
  id uuid primary key default gen_random_uuid(),
  work_order_id uuid not null references svc.work_orders(id) on delete cascade,
  from_status svc.work_order_status,
  to_status svc.work_order_status not null,
  changed_by uuid references auth.users(id),
  reason_code text,
  notes text,
  changed_at timestamptz not null default now()
);

commit;
begin;

create table if not exists acct.accounting_accounts (
  id uuid primary key default gen_random_uuid(),
  account_code text not null unique,
  account_name text not null,
  account_type text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists acct.journal_entries (
  id uuid primary key default gen_random_uuid(),
  source_type text,
  source_id uuid,
  branch_id uuid references core.branches(id),
  reference_no text,
  posting_date date not null default current_date,
  status acct.journal_status not null default 'draft',
  memo text,
  created_by uuid references auth.users(id),
  posted_by uuid references auth.users(id),
  posted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists acct.journal_lines (
  id uuid primary key default gen_random_uuid(),
  journal_entry_id uuid not null references acct.journal_entries(id) on delete cascade,
  line_no integer not null,
  account_id uuid not null references acct.accounting_accounts(id),
  debit numeric(14,2) not null default 0 check (debit >= 0),
  credit numeric(14,2) not null default 0 check (credit >= 0),
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((debit = 0 and credit > 0) or (credit = 0 and debit > 0)),
  unique (journal_entry_id, line_no)
);

create table if not exists acct.ar_open_items (
  id uuid primary key default gen_random_uuid(),
  source_type text not null,
  source_id uuid,
  branch_id uuid not null references core.branches(id),
  customer_id uuid not null references sales.customers(id),
  invoice_id uuid references sales.invoices(id),
  invoice_no text,
  due_date date not null,
  amount_due numeric(14,2) not null check (amount_due >= 0),
  amount_paid numeric(14,2) not null default 0 check (amount_paid >= 0),
  balance numeric(14,2) generated always as (round((amount_due - amount_paid)::numeric, 2)) stored,
  aging_bucket text not null default 'current',
  snapshot_date date not null default current_date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists acct.reconciliation_items (
  id uuid primary key default gen_random_uuid(),
  source_type text not null,
  source_id uuid,
  branch_id uuid references core.branches(id),
  reconciliation_date date,
  status text not null default 'open',
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

commit;
begin;

create table if not exists hr.employees (
  id uuid primary key default gen_random_uuid(),
  staff_no text not null unique,
  full_name text not null,
  branch_id uuid references core.branches(id),
  linked_user_id uuid unique references auth.users(id),
  department text,
  hire_date date,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists hr.leave_types (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  days_per_year numeric(8,2) not null default 0 check (days_per_year >= 0),
  requires_attachment boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists hr.leave_balances (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid not null references hr.employees(id) on delete cascade,
  leave_type_id uuid not null references hr.leave_types(id),
  balance_year integer not null,
  entitlement_days numeric(8,2) not null default 0 check (entitlement_days >= 0),
  used_days numeric(8,2) not null default 0 check (used_days >= 0),
  remaining_days numeric(8,2) generated always as (round((entitlement_days - used_days)::numeric, 2)) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (employee_id, leave_type_id, balance_year)
);

create table if not exists hr.leave_requests (
  id uuid primary key default gen_random_uuid(),
  request_no text not null unique,
  employee_id uuid not null references hr.employees(id),
  leave_type_id uuid not null references hr.leave_types(id),
  start_date date not null,
  end_date date not null,
  days_requested numeric(8,2) not null check (days_requested > 0),
  reason text,
  status hr.leave_request_status not null default 'draft',
  approver_user_id uuid references auth.users(id),
  attachment_id uuid references core.attachments(id),
  submitted_at timestamptz,
  approved_at timestamptz,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_date >= start_date)
);

create table if not exists hr.leave_approval_events (
  id uuid primary key default gen_random_uuid(),
  leave_request_id uuid not null references hr.leave_requests(id) on delete cascade,
  from_status hr.leave_request_status,
  to_status hr.leave_request_status not null,
  changed_by uuid references auth.users(id),
  notes text,
  changed_at timestamptz not null default now()
);

commit;
begin;

create table if not exists audit.audit_events (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null default now(),
  actor_user_id uuid references auth.users(id),
  branch_id uuid references core.branches(id),
  entity_type text not null,
  entity_id uuid,
  action text not null,
  old_values_json jsonb,
  new_values_json jsonb,
  ip_address inet,
  user_agent text,
  request_id text,
  metadata jsonb not null default '{}'::jsonb
);

create table if not exists analytics.dim_date (
  date_day date primary key,
  day_of_week integer not null,
  day_of_month integer not null,
  week_of_year integer not null,
  month_of_year integer not null,
  quarter_of_year integer not null,
  calendar_year integer not null,
  is_weekend boolean not null
);

create table if not exists analytics.dim_branch (
  branch_id uuid primary key references core.branches(id) on delete cascade,
  branch_code text not null,
  branch_name text not null,
  is_active boolean not null default true,
  refreshed_at timestamptz not null default now()
);

create table if not exists analytics.dim_staff (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  home_branch_id uuid references core.branches(id),
  refreshed_at timestamptz not null default now()
);

create table if not exists analytics.fact_sales_daily (
  id uuid primary key default gen_random_uuid(),
  snapshot_date date not null,
  branch_id uuid not null references core.branches(id),
  sales_owner_user_id uuid references auth.users(id),
  booking_count integer not null default 0,
  reserved_count integer not null default 0,
  deposit_verified_count integer not null default 0,
  invoice_count integer not null default 0,
  booking_value_total numeric(14,2) not null default 0,
  deposit_value_total numeric(14,2) not null default 0,
  refreshed_at timestamptz not null default now(),
  unique (snapshot_date, branch_id, sales_owner_user_id)
);

create table if not exists analytics.fact_service_daily (
  id uuid primary key default gen_random_uuid(),
  snapshot_date date not null,
  branch_id uuid not null references core.branches(id),
  service_manager_user_id uuid references auth.users(id),
  appointment_count integer not null default 0,
  work_order_open_count integer not null default 0,
  work_order_completed_count integer not null default 0,
  work_order_revenue_total numeric(14,2) not null default 0,
  refreshed_at timestamptz not null default now(),
  unique (snapshot_date, branch_id, service_manager_user_id)
);

create table if not exists analytics.fact_ar_snapshot (
  id uuid primary key default gen_random_uuid(),
  snapshot_date date not null,
  branch_id uuid not null references core.branches(id),
  customer_id uuid references sales.customers(id),
  bucket_name text not null,
  balance_total numeric(14,2) not null default 0,
  refreshed_at timestamptz not null default now(),
  unique (snapshot_date, branch_id, customer_id, bucket_name)
);

create or replace view analytics.vw_ar_aging_latest as
with latest_snapshot as (
  select max(snapshot_date) as snapshot_date
  from acct.ar_open_items
)
select
  a.branch_id,
  a.customer_id,
  a.invoice_id,
  a.invoice_no,
  a.due_date,
  a.amount_due,
  a.amount_paid,
  a.balance,
  case
    when a.balance <= 0 then 'settled'
    when current_date - a.due_date <= 0 then 'current'
    when current_date - a.due_date between 1 and 30 then '1_30'
    when current_date - a.due_date between 31 and 60 then '31_60'
    when current_date - a.due_date between 61 and 90 then '61_90'
    else '90_plus'
  end as aging_bucket_runtime,
  a.snapshot_date
from acct.ar_open_items a
join latest_snapshot ls
  on a.snapshot_date = ls.snapshot_date;

create or replace view analytics.vw_booking_pipeline_open as
select
  b.branch_id,
  b.status,
  count(*) as booking_count,
  coalesce(sum(b.amount_total), 0)::numeric(14,2) as booking_value_total,
  coalesce(sum(b.deposit_amount), 0)::numeric(14,2) as deposit_value_total
from sales.bookings b
where b.status not in ('completed', 'cancelled', 'expired')
group by b.branch_id, b.status;

create or replace view analytics.vw_work_order_backlog as
select
  w.branch_id,
  w.status,
  count(*) as work_order_count,
  coalesce(sum(w.total_amount), 0)::numeric(14,2) as work_order_total
from svc.work_orders w
where w.status not in ('closed', 'cancelled')
group by w.branch_id, w.status;

commit;
begin;

create index if not exists idx_core_user_profiles_home_branch
  on core.user_profiles (home_branch_id);

create index if not exists idx_core_user_branch_access_user_branch
  on core.user_branch_access (user_id, branch_id)
  where is_active = true;

create index if not exists idx_core_reference_values_domain_active
  on core.reference_values (domain_name, is_active, sort_order);

create index if not exists idx_core_notification_queue_status_sched
  on core.notification_queue (status, scheduled_at);

create index if not exists idx_core_attachments_entity
  on core.attachments (entity_type, entity_id);

create index if not exists idx_sales_customers_branch_created
  on sales.customers (branch_id, created_at desc);

create index if not exists idx_sales_customers_phone
  on sales.customers (phone);

create index if not exists idx_sales_customers_email
  on sales.customers (email);

create index if not exists idx_sales_customers_full_name_trgm
  on sales.customers using gin (full_name gin_trgm_ops);

create index if not exists idx_sales_customer_contacts_customer
  on sales.customer_contacts (customer_id, is_primary desc);

create index if not exists idx_sales_bookings_branch_status_date
  on sales.bookings (branch_id, status, booking_date desc);

create index if not exists idx_sales_bookings_owner_status
  on sales.bookings (sales_owner_user_id, status, booking_date desc);

create index if not exists idx_sales_bookings_customer
  on sales.bookings (customer_id, created_at desc);

create index if not exists idx_sales_bookings_reserved_until
  on sales.bookings (reserved_until)
  where reserved_until is not null;

create index if not exists idx_sales_bookings_model_code
  on sales.bookings (model_code);

create index if not exists idx_sales_booking_events_booking_changed_at
  on sales.booking_status_events (booking_id, changed_at desc);

create index if not exists idx_sales_reservations_booking
  on sales.reservations (booking_id, reserved_until desc);

create index if not exists idx_sales_payments_booking_date
  on sales.payments (booking_id, payment_date desc);

create index if not exists idx_sales_payments_verification_status
  on sales.payments (verification_status, payment_date desc);

create index if not exists idx_sales_payments_reference_no
  on sales.payments (reference_no);

create index if not exists idx_sales_refunds_status_requested
  on sales.refunds (status, requested_at desc);

create index if not exists idx_sales_refunds_booking
  on sales.refunds (booking_id);

create index if not exists idx_sales_invoices_branch_status_date
  on sales.invoices (branch_id, status, invoice_date desc);

create index if not exists idx_sales_invoices_customer_due
  on sales.invoices (customer_id, due_date);

create index if not exists idx_svc_vehicles_customer
  on svc.vehicles (customer_id);

create index if not exists idx_svc_vehicles_branch
  on svc.vehicles (branch_id);

create index if not exists idx_svc_service_appointments_branch_time
  on svc.service_appointments (branch_id, appointment_at desc);

create index if not exists idx_svc_service_appointments_status
  on svc.service_appointments (status, appointment_at desc);

create index if not exists idx_svc_service_appointments_customer
  on svc.service_appointments (customer_id);

create index if not exists idx_svc_work_orders_branch_status_opened
  on svc.work_orders (branch_id, status, opened_at desc);

create index if not exists idx_svc_work_orders_manager_status
  on svc.work_orders (service_manager_user_id, status, opened_at desc);

create index if not exists idx_svc_work_orders_customer
  on svc.work_orders (customer_id);

create index if not exists idx_svc_work_order_events_work_order_changed
  on svc.work_order_status_events (work_order_id, changed_at desc);

create index if not exists idx_acct_journal_entries_status_date
  on acct.journal_entries (status, posting_date desc);

create index if not exists idx_acct_journal_entries_source
  on acct.journal_entries (source_type, source_id);

create index if not exists idx_acct_journal_lines_journal
  on acct.journal_lines (journal_entry_id, line_no);

create index if not exists idx_acct_ar_open_items_snapshot_branch
  on acct.ar_open_items (snapshot_date, branch_id);

create index if not exists idx_acct_ar_open_items_customer_due
  on acct.ar_open_items (customer_id, due_date);

create index if not exists idx_acct_ar_open_items_balance_open
  on acct.ar_open_items (balance)
  where balance > 0;

create index if not exists idx_acct_reconciliation_items_status_date
  on acct.reconciliation_items (status, reconciliation_date);

create index if not exists idx_hr_employees_branch
  on hr.employees (branch_id, is_active);

create index if not exists idx_hr_leave_balances_employee_year
  on hr.leave_balances (employee_id, balance_year);

create index if not exists idx_hr_leave_requests_status_dates
  on hr.leave_requests (status, start_date, end_date);

create index if not exists idx_hr_leave_requests_approver_status
  on hr.leave_requests (approver_user_id, status);

create index if not exists idx_hr_leave_requests_employee_created
  on hr.leave_requests (employee_id, created_at desc);

create index if not exists idx_hr_leave_approval_events_leave_changed
  on hr.leave_approval_events (leave_request_id, changed_at desc);

create index if not exists idx_audit_events_actor_occurred
  on audit.audit_events (actor_user_id, occurred_at desc);

create index if not exists idx_audit_events_entity
  on audit.audit_events (entity_type, entity_id, occurred_at desc);

create index if not exists idx_audit_events_action_occurred
  on audit.audit_events (action, occurred_at desc);

create index if not exists idx_analytics_fact_sales_daily_snapshot_branch
  on analytics.fact_sales_daily (snapshot_date, branch_id);

create index if not exists idx_analytics_fact_service_daily_snapshot_branch
  on analytics.fact_service_daily (snapshot_date, branch_id);

create index if not exists idx_analytics_fact_ar_snapshot_snapshot_branch
  on analytics.fact_ar_snapshot (snapshot_date, branch_id, bucket_name);

commit;
begin;

create or replace function sales.log_booking_status_change()
returns trigger
language plpgsql
as $$
declare
  v_actor uuid;
begin
  v_actor := coalesce(new.updated_by, new.created_by, core.current_app_user_id());

  if tg_op = 'INSERT' then
    insert into sales.booking_status_events (
      booking_id,
      from_status,
      to_status,
      changed_by,
      reason_code,
      notes,
      changed_at
    ) values (
      new.id,
      null,
      new.status,
      v_actor,
      'initial',
      'initial booking status',
      now()
    );
    return new;
  end if;

  if new.status is distinct from old.status then
    insert into sales.booking_status_events (
      booking_id,
      from_status,
      to_status,
      changed_by,
      reason_code,
      notes,
      changed_at
    ) values (
      new.id,
      old.status,
      new.status,
      v_actor,
      'update',
      'booking status changed',
      now()
    );
  end if;

  return new;
end;
$$;

create or replace function svc.log_work_order_status_change()
returns trigger
language plpgsql
as $$
declare
  v_actor uuid;
begin
  v_actor := coalesce(new.updated_by, new.created_by, core.current_app_user_id());

  if tg_op = 'INSERT' then
    insert into svc.work_order_status_events (
      work_order_id,
      from_status,
      to_status,
      changed_by,
      reason_code,
      notes,
      changed_at
    ) values (
      new.id,
      null,
      new.status,
      v_actor,
      'initial',
      'initial work order status',
      now()
    );
    return new;
  end if;

  if new.status is distinct from old.status then
    insert into svc.work_order_status_events (
      work_order_id,
      from_status,
      to_status,
      changed_by,
      reason_code,
      notes,
      changed_at
    ) values (
      new.id,
      old.status,
      new.status,
      v_actor,
      'update',
      'work order status changed',
      now()
    );
  end if;

  return new;
end;
$$;

create or replace function hr.log_leave_request_status_change()
returns trigger
language plpgsql
as $$
declare
  v_actor uuid;
begin
  v_actor := coalesce(new.approver_user_id, new.created_by, core.current_app_user_id());

  if tg_op = 'INSERT' then
    insert into hr.leave_approval_events (
      leave_request_id,
      from_status,
      to_status,
      changed_by,
      notes,
      changed_at
    ) values (
      new.id,
      null,
      new.status,
      v_actor,
      'initial leave request status',
      now()
    );
    return new;
  end if;

  if new.status is distinct from old.status then
    insert into hr.leave_approval_events (
      leave_request_id,
      from_status,
      to_status,
      changed_by,
      notes,
      changed_at
    ) values (
      new.id,
      old.status,
      new.status,
      v_actor,
      'leave request status changed',
      now()
    );
  end if;

  return new;
end;
$$;

drop trigger if exists trg_branches_set_updated_at on core.branches;
create trigger trg_branches_set_updated_at
before update on core.branches
for each row execute function core.set_updated_at();

drop trigger if exists trg_roles_set_updated_at on core.roles;
create trigger trg_roles_set_updated_at
before update on core.roles
for each row execute function core.set_updated_at();

drop trigger if exists trg_permissions_set_updated_at on core.permissions;
create trigger trg_permissions_set_updated_at
before update on core.permissions
for each row execute function core.set_updated_at();

drop trigger if exists trg_user_profiles_set_updated_at on core.user_profiles;
create trigger trg_user_profiles_set_updated_at
before update on core.user_profiles
for each row execute function core.set_updated_at();

drop trigger if exists trg_user_branch_access_set_updated_at on core.user_branch_access;
create trigger trg_user_branch_access_set_updated_at
before update on core.user_branch_access
for each row execute function core.set_updated_at();

drop trigger if exists trg_reference_values_set_updated_at on core.reference_values;
create trigger trg_reference_values_set_updated_at
before update on core.reference_values
for each row execute function core.set_updated_at();

drop trigger if exists trg_attachments_set_updated_at on core.attachments;
create trigger trg_attachments_set_updated_at
before update on core.attachments
for each row execute function core.set_updated_at();

drop trigger if exists trg_notification_queue_set_updated_at on core.notification_queue;
create trigger trg_notification_queue_set_updated_at
before update on core.notification_queue
for each row execute function core.set_updated_at();

drop trigger if exists trg_customers_set_updated_at on sales.customers;
create trigger trg_customers_set_updated_at
before update on sales.customers
for each row execute function core.set_updated_at();

drop trigger if exists trg_customer_contacts_set_updated_at on sales.customer_contacts;
create trigger trg_customer_contacts_set_updated_at
before update on sales.customer_contacts
for each row execute function core.set_updated_at();

drop trigger if exists trg_bookings_set_updated_at on sales.bookings;
create trigger trg_bookings_set_updated_at
before update on sales.bookings
for each row execute function core.set_updated_at();

drop trigger if exists trg_reservations_set_updated_at on sales.reservations;
create trigger trg_reservations_set_updated_at
before update on sales.reservations
for each row execute function core.set_updated_at();

drop trigger if exists trg_payments_set_updated_at on sales.payments;
create trigger trg_payments_set_updated_at
before update on sales.payments
for each row execute function core.set_updated_at();

drop trigger if exists trg_refunds_set_updated_at on sales.refunds;
create trigger trg_refunds_set_updated_at
before update on sales.refunds
for each row execute function core.set_updated_at();

drop trigger if exists trg_invoices_set_updated_at on sales.invoices;
create trigger trg_invoices_set_updated_at
before update on sales.invoices
for each row execute function core.set_updated_at();

drop trigger if exists trg_bookings_status_event on sales.bookings;
create trigger trg_bookings_status_event
after insert or update of status on sales.bookings
for each row execute function sales.log_booking_status_change();

drop trigger if exists trg_vehicles_set_updated_at on svc.vehicles;
create trigger trg_vehicles_set_updated_at
before update on svc.vehicles
for each row execute function core.set_updated_at();

drop trigger if exists trg_service_appointments_set_updated_at on svc.service_appointments;
create trigger trg_service_appointments_set_updated_at
before update on svc.service_appointments
for each row execute function core.set_updated_at();

drop trigger if exists trg_work_orders_set_updated_at on svc.work_orders;
create trigger trg_work_orders_set_updated_at
before update on svc.work_orders
for each row execute function core.set_updated_at();

drop trigger if exists trg_work_order_items_set_updated_at on svc.work_order_items;
create trigger trg_work_order_items_set_updated_at
before update on svc.work_order_items
for each row execute function core.set_updated_at();

drop trigger if exists trg_work_orders_status_event on svc.work_orders;
create trigger trg_work_orders_status_event
after insert or update of status on svc.work_orders
for each row execute function svc.log_work_order_status_change();

drop trigger if exists trg_accounting_accounts_set_updated_at on acct.accounting_accounts;
create trigger trg_accounting_accounts_set_updated_at
before update on acct.accounting_accounts
for each row execute function core.set_updated_at();

drop trigger if exists trg_journal_entries_set_updated_at on acct.journal_entries;
create trigger trg_journal_entries_set_updated_at
before update on acct.journal_entries
for each row execute function core.set_updated_at();

drop trigger if exists trg_journal_lines_set_updated_at on acct.journal_lines;
create trigger trg_journal_lines_set_updated_at
before update on acct.journal_lines
for each row execute function core.set_updated_at();

drop trigger if exists trg_ar_open_items_set_updated_at on acct.ar_open_items;
create trigger trg_ar_open_items_set_updated_at
before update on acct.ar_open_items
for each row execute function core.set_updated_at();

drop trigger if exists trg_reconciliation_items_set_updated_at on acct.reconciliation_items;
create trigger trg_reconciliation_items_set_updated_at
before update on acct.reconciliation_items
for each row execute function core.set_updated_at();

drop trigger if exists trg_employees_set_updated_at on hr.employees;
create trigger trg_employees_set_updated_at
before update on hr.employees
for each row execute function core.set_updated_at();

drop trigger if exists trg_leave_types_set_updated_at on hr.leave_types;
create trigger trg_leave_types_set_updated_at
before update on hr.leave_types
for each row execute function core.set_updated_at();

drop trigger if exists trg_leave_balances_set_updated_at on hr.leave_balances;
create trigger trg_leave_balances_set_updated_at
before update on hr.leave_balances
for each row execute function core.set_updated_at();

drop trigger if exists trg_leave_requests_set_updated_at on hr.leave_requests;
create trigger trg_leave_requests_set_updated_at
before update on hr.leave_requests
for each row execute function core.set_updated_at();

drop trigger if exists trg_leave_requests_status_event on hr.leave_requests;
create trigger trg_leave_requests_status_event
after insert or update of status on hr.leave_requests
for each row execute function hr.log_leave_request_status_change();

commit;
begin;

insert into core.roles (code, name, category, is_system)
values
  ('director_of_service', 'Director of Service', 'business', true),
  ('gm_service', 'General Manager of Service', 'business', true),
  ('gm_sales', 'General Manager of Sales', 'business', true),
  ('accounting_manager', 'Accounting Manager', 'business', true),
  ('finance_manager', 'Finance Manager', 'business', true),
  ('sales_admin', 'Sales Admin', 'business', true),
  ('service_manager', 'Service Manager', 'business', true),
  ('sales_manager', 'Sales Manager', 'business', true),
  ('system_admin', 'System Administrator', 'system', true)
on conflict (code) do update
set
  name = excluded.name,
  category = excluded.category,
  is_system = excluded.is_system,
  updated_at = now();

insert into core.permissions (code, name, module_name, action_name, description)
values
  ('dashboard.executive.view', 'View executive dashboard', 'dashboard', 'view', 'View executive KPI dashboard'),
  ('dashboard.executive.export', 'Export executive dashboard', 'dashboard', 'export', 'Export executive dashboard data'),
  ('branch.view', 'View branches', 'branch', 'view', 'View branches'),
  ('branch.manage', 'Manage branches', 'branch', 'manage', 'Create and update branches'),
  ('user.manage', 'Manage users', 'user', 'manage', 'Create and update users'),
  ('role.assign', 'Assign roles', 'role', 'assign', 'Assign roles to users'),
  ('customer.view', 'View customers', 'customer', 'view', 'View customers'),
  ('customer.manage', 'Manage customers', 'customer', 'manage', 'Create and edit customers'),
  ('booking.view', 'View bookings', 'booking', 'view', 'View bookings'),
  ('booking.manage', 'Manage bookings', 'booking', 'manage', 'Create and edit bookings'),
  ('booking.approve', 'Approve bookings', 'booking', 'approve', 'Approve sales bookings'),
  ('payment.view', 'View payments', 'payment', 'view', 'View payments'),
  ('payment.manage', 'Manage payments', 'payment', 'manage', 'Create payments'),
  ('payment.verify', 'Verify payments', 'payment', 'verify', 'Verify payments'),
  ('refund.request', 'Request refunds', 'refund', 'request', 'Create refund requests'),
  ('refund.approve', 'Approve refunds', 'refund', 'approve', 'Approve refunds'),
  ('service.appointment.manage', 'Manage service appointments', 'service_appointment', 'manage', 'Manage service appointments'),
  ('service.work_order.manage', 'Manage work orders', 'work_order', 'manage', 'Manage work orders'),
  ('service.analytics.view', 'View service analytics', 'service_analytics', 'view', 'View service analytics'),
  ('invoice.manage', 'Manage invoices', 'invoice', 'manage', 'Create and edit invoices'),
  ('ar_aging.view', 'View AR aging', 'ar_aging', 'view', 'View AR aging analytics'),
  ('journal.review', 'Review journals', 'journal', 'review', 'Review journal entries'),
  ('leave.request', 'Request leave', 'leave', 'request', 'Submit leave requests'),
  ('leave.approve', 'Approve leave', 'leave', 'approve', 'Approve leave requests'),
  ('audit.view', 'View audit logs', 'audit', 'view', 'View audit events'),
  ('export.sensitive', 'Sensitive export', 'export', 'sensitive', 'Export sensitive data')
on conflict (code) do update
set
  name = excluded.name,
  module_name = excluded.module_name,
  action_name = excluded.action_name,
  description = excluded.description,
  updated_at = now();

insert into core.role_permissions (role_code, permission_code)
values
  ('director_of_service', 'dashboard.executive.view'),
  ('director_of_service', 'dashboard.executive.export'),
  ('director_of_service', 'branch.view'),
  ('director_of_service', 'service.analytics.view'),

  ('gm_service', 'dashboard.executive.view'),
  ('gm_service', 'dashboard.executive.export'),
  ('gm_service', 'branch.view'),
  ('gm_service', 'service.appointment.manage'),
  ('gm_service', 'service.work_order.manage'),
  ('gm_service', 'service.analytics.view'),
  ('gm_service', 'leave.approve'),

  ('gm_sales', 'dashboard.executive.view'),
  ('gm_sales', 'dashboard.executive.export'),
  ('gm_sales', 'branch.view'),
  ('gm_sales', 'customer.view'),
  ('gm_sales', 'booking.view'),
  ('gm_sales', 'payment.view'),
  ('gm_sales', 'invoice.manage'),
  ('gm_sales', 'ar_aging.view'),
  ('gm_sales', 'export.sensitive'),

  ('accounting_manager', 'dashboard.executive.view'),
  ('accounting_manager', 'dashboard.executive.export'),
  ('accounting_manager', 'branch.view'),
  ('accounting_manager', 'customer.view'),
  ('accounting_manager', 'booking.view'),
  ('accounting_manager', 'payment.view'),
  ('accounting_manager', 'invoice.manage'),
  ('accounting_manager', 'ar_aging.view'),
  ('accounting_manager', 'journal.review'),
  ('accounting_manager', 'audit.view'),
  ('accounting_manager', 'export.sensitive'),

  ('finance_manager', 'dashboard.executive.view'),
  ('finance_manager', 'dashboard.executive.export'),
  ('finance_manager', 'branch.view'),
  ('finance_manager', 'customer.view'),
  ('finance_manager', 'booking.view'),
  ('finance_manager', 'payment.view'),
  ('finance_manager', 'payment.manage'),
  ('finance_manager', 'payment.verify'),
  ('finance_manager', 'refund.approve'),
  ('finance_manager', 'invoice.manage'),
  ('finance_manager', 'ar_aging.view'),
  ('finance_manager', 'export.sensitive'),

  ('sales_admin', 'customer.view'),
  ('sales_admin', 'customer.manage'),
  ('sales_admin', 'booking.view'),
  ('sales_admin', 'booking.manage'),
  ('sales_admin', 'payment.manage'),
  ('sales_admin', 'refund.request'),
  ('sales_admin', 'leave.request'),

  ('service_manager', 'service.appointment.manage'),
  ('service_manager', 'service.work_order.manage'),
  ('service_manager', 'service.analytics.view'),
  ('service_manager', 'leave.request'),
  ('service_manager', 'leave.approve'),

  ('sales_manager', 'dashboard.executive.view'),
  ('sales_manager', 'customer.view'),
  ('sales_manager', 'customer.manage'),
  ('sales_manager', 'booking.view'),
  ('sales_manager', 'booking.manage'),
  ('sales_manager', 'booking.approve'),
  ('sales_manager', 'payment.view'),
  ('sales_manager', 'ar_aging.view'),
  ('sales_manager', 'leave.request'),
  ('sales_manager', 'leave.approve'),

  ('system_admin', 'dashboard.executive.view'),
  ('system_admin', 'branch.view'),
  ('system_admin', 'branch.manage'),
  ('system_admin', 'user.manage'),
  ('system_admin', 'role.assign'),
  ('system_admin', 'audit.view'),
  ('system_admin', 'export.sensitive')
on conflict (role_code, permission_code) do nothing;

insert into hr.leave_types (code, name, days_per_year, requires_attachment)
values
  ('annual', 'Annual Leave', 12, false),
  ('medical', 'Medical Leave', 14, true),
  ('emergency', 'Emergency Leave', 3, false),
  ('unpaid', 'Unpaid Leave', 0, false)
on conflict (code) do update
set
  name = excluded.name,
  days_per_year = excluded.days_per_year,
  requires_attachment = excluded.requires_attachment,
  updated_at = now();

insert into core.reference_values (domain_name, value_key, label, sort_order, value_json)
values
  ('payment_method', 'cash', 'Cash', 10, '{}'::jsonb),
  ('payment_method', 'bank_transfer', 'Bank Transfer', 20, '{}'::jsonb),
  ('payment_method', 'cheque', 'Cheque', 30, '{}'::jsonb),
  ('payment_method', 'card', 'Card', 40, '{}'::jsonb),
  ('refund_reason', 'booking_cancelled', 'Booking Cancelled', 10, '{}'::jsonb),
  ('refund_reason', 'duplicate_payment', 'Duplicate Payment', 20, '{}'::jsonb),
  ('refund_reason', 'overpayment', 'Overpayment', 30, '{}'::jsonb),
  ('service_type', 'maintenance', 'Maintenance', 10, '{}'::jsonb),
  ('service_type', 'repair', 'Repair', 20, '{}'::jsonb),
  ('service_type', 'inspection', 'Inspection', 30, '{}'::jsonb)
on conflict (domain_name, value_key) do update
set
  label = excluded.label,
  sort_order = excluded.sort_order,
  value_json = excluded.value_json,
  updated_at = now();

commit;
