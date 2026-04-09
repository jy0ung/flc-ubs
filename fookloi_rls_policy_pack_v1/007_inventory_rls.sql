begin;

-- Enable RLS on inventory tables
alter table inv.products enable row level security;
alter table inv.stock_levels enable row level security;
alter table inv.stock_movements enable row level security;
alter table inv.adjustments enable row level security;

-- Products: Branch-based access
create policy "products_branch_access" on inv.products
  for all using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
    )
  );

-- Stock levels: Branch-based access
create policy "stock_levels_branch_access" on inv.stock_levels
  for all using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
    )
  );

-- Stock movements: Branch-based access
create policy "stock_movements_branch_access" on inv.stock_movements
  for all using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
    )
  );

-- Adjustments: Branch-based access with role restrictions
create policy "adjustments_branch_access" on inv.adjustments
  for all using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
      and role in ('manager', 'admin')
    )
  );

-- Allow service role full access (for backend jobs)
create policy "products_service_role" on inv.products
  for all using (auth.jwt() ->> 'role' = 'service_role');

create policy "stock_levels_service_role" on inv.stock_levels
  for all using (auth.jwt() ->> 'role' = 'service_role');

create policy "stock_movements_service_role" on inv.stock_movements
  for all using (auth.jwt() ->> 'role' = 'service_role');

create policy "adjustments_service_role" on inv.adjustments
  for all using (auth.jwt() ->> 'role' = 'service_role');

commit;