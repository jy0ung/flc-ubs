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
