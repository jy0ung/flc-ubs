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
