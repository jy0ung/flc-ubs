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
