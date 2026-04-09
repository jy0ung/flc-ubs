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
