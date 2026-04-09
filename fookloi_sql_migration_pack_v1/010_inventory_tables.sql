begin;

create table if not exists inv.products (
  id uuid primary key default gen_random_uuid(),
  product_code text not null unique,
  product_name text not null,
  description text,
  category text,
  unit_of_measure text not null default 'unit',
  unit_cost numeric(14,2) not null default 0 check (unit_cost >= 0),
  selling_price numeric(14,2) not null default 0 check (selling_price >= 0),
  reorder_point integer not null default 0 check (reorder_point >= 0),
  status inv.stock_status not null default 'active',
  branch_id uuid not null references core.branches(id),
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists inv.stock_levels (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references inv.products(id) on delete cascade,
  branch_id uuid not null references core.branches(id),
  quantity_on_hand integer not null default 0,
  quantity_reserved integer not null default 0 check (quantity_reserved >= 0),
  quantity_available integer generated always as (quantity_on_hand - quantity_reserved) stored,
  last_stock_take timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(product_id, branch_id)
);

create table if not exists inv.stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references inv.products(id),
  branch_id uuid not null references core.branches(id),
  movement_type inv.adjustment_type not null,
  quantity integer not null,
  reference_type text, -- 'sales', 'service', 'adjustment', etc.
  reference_id uuid, -- foreign key to related record
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists inv.adjustments (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references inv.products(id),
  branch_id uuid not null references core.branches(id),
  adjustment_type inv.adjustment_type not null,
  quantity integer not null,
  reason text not null,
  approved_by uuid references auth.users(id),
  approved_at timestamptz,
  notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- Indexes for performance
create index if not exists idx_inv_products_branch on inv.products(branch_id);
create index if not exists idx_inv_products_status on inv.products(status);
create index if not exists idx_inv_stock_levels_product on inv.stock_levels(product_id);
create index if not exists idx_inv_stock_movements_product on inv.stock_movements(product_id);
create index if not exists idx_inv_stock_movements_created on inv.stock_movements(created_at);
create index if not exists idx_inv_adjustments_product on inv.adjustments(product_id);
create index if not exists idx_inv_adjustments_created on inv.adjustments(created_at);

-- Triggers for updated_at
create trigger set_updated_at_inv_products
  before update on inv.products
  for each row execute function core.set_updated_at();

create trigger set_updated_at_inv_stock_levels
  before update on inv.stock_levels
  for each row execute function core.set_updated_at();

commit;