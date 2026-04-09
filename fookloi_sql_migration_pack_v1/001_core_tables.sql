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
