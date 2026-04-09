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
