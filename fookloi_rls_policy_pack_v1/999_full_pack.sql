-- >>> 000_grants_and_helpers.sql
begin;

revoke all on all tables in schema core, sales, svc, acct, hr, audit, analytics from anon;
revoke all on all sequences in schema core, sales, svc, acct, hr, audit, analytics from anon;

grant usage on schema core, sales, svc, acct, hr, audit, analytics to authenticated;
grant usage on schema core, sales, svc, acct, hr, audit, analytics to service_role;

grant select, insert, update, delete on all tables in schema core, sales, svc, acct, hr, audit, analytics to authenticated;
grant select, insert, update, delete on all tables in schema core, sales, svc, acct, hr, audit, analytics to service_role;

grant usage, select on all sequences in schema core, sales, svc, acct, hr, audit, analytics to authenticated;
grant usage, select on all sequences in schema core, sales, svc, acct, hr, audit, analytics to service_role;

alter default privileges in schema core, sales, svc, acct, hr, audit, analytics
  grant select, insert, update, delete on tables to authenticated;
alter default privileges in schema core, sales, svc, acct, hr, audit, analytics
  grant select, insert, update, delete on tables to service_role;
alter default privileges in schema core, sales, svc, acct, hr, audit, analytics
  grant usage, select on sequences to authenticated;
alter default privileges in schema core, sales, svc, acct, hr, audit, analytics
  grant usage, select on sequences to service_role;

create or replace function core.effective_user_id()
returns uuid
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select coalesce(auth.uid(), core.current_app_user_id())
$$;

create or replace function core.is_platform_admin()
returns boolean
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select exists (
    select 1
    from core.user_branch_access uba
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and uba.role_code = 'system_admin'
  )
$$;

create or replace function core.user_can_access_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select
    core.is_platform_admin()
    or exists (
      select 1
      from core.user_branch_access uba
      where uba.user_id = core.effective_user_id()
        and uba.branch_id = p_branch_id
        and uba.is_active = true
    )
$$;

create or replace function core.user_has_role_in_branch(p_role_code text, p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select
    core.is_platform_admin()
    or exists (
      select 1
      from core.user_branch_access uba
      where uba.user_id = core.effective_user_id()
        and uba.is_active = true
        and uba.role_code = p_role_code
        and uba.branch_id = p_branch_id
    )
$$;

create or replace function core.user_has_any_role_in_branch(p_role_codes text[], p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select
    core.is_platform_admin()
    or exists (
      select 1
      from core.user_branch_access uba
      where uba.user_id = core.effective_user_id()
        and uba.is_active = true
        and uba.role_code = any (p_role_codes)
        and uba.branch_id = p_branch_id
    )
$$;

create or replace function core.user_has_permission_in_branch(p_permission_code text, p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select
    core.is_platform_admin()
    or exists (
      select 1
      from core.user_branch_access uba
      join core.role_permissions rp
        on rp.role_code = uba.role_code
      where uba.user_id = core.effective_user_id()
        and uba.is_active = true
        and rp.permission_code = p_permission_code
        and (
          uba.branch_id = p_branch_id
          or uba.role_code = 'system_admin'
        )
    )
$$;

create or replace function core.user_has_any_permission_in_branch(p_permission_codes text[], p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select
    core.is_platform_admin()
    or exists (
      select 1
      from core.user_branch_access uba
      join core.role_permissions rp
        on rp.role_code = uba.role_code
      where uba.user_id = core.effective_user_id()
        and uba.is_active = true
        and rp.permission_code = any (p_permission_codes)
        and (
          uba.branch_id = p_branch_id
          or uba.role_code = 'system_admin'
        )
    )
$$;

create or replace function core.can_view_customer_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(array['customer.view', 'customer.manage'], p_branch_id)
$$;

create or replace function core.can_manage_customer_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_permission_in_branch('customer.manage', p_branch_id)
$$;

create or replace function core.can_view_booking_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(array['booking.view', 'booking.manage', 'booking.approve'], p_branch_id)
$$;

create or replace function core.can_manage_booking_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(array['booking.manage', 'booking.approve'], p_branch_id)
$$;

create or replace function core.can_view_payment_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(array['payment.view', 'payment.manage', 'payment.verify'], p_branch_id)
$$;

create or replace function core.can_manage_payment_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(array['payment.manage', 'payment.verify'], p_branch_id)
$$;

create or replace function core.can_view_refund_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(
    array['refund.request', 'refund.approve', 'payment.view', 'payment.manage', 'payment.verify', 'booking.view', 'booking.manage', 'booking.approve'],
    p_branch_id
  )
$$;

create or replace function core.can_request_refund_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_permission_in_branch('refund.request', p_branch_id)
$$;

create or replace function core.can_approve_refund_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_permission_in_branch('refund.approve', p_branch_id)
$$;

create or replace function core.can_view_invoice_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(array['invoice.manage', 'ar_aging.view'], p_branch_id)
$$;

create or replace function core.can_manage_invoice_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_permission_in_branch('invoice.manage', p_branch_id)
$$;

create or replace function core.can_view_service_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(
    array['service.appointment.manage', 'service.work_order.manage', 'service.analytics.view'],
    p_branch_id
  )
$$;

create or replace function core.can_manage_service_branch(p_branch_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select core.user_has_any_permission_in_branch(array['service.appointment.manage', 'service.work_order.manage'], p_branch_id)
$$;

create or replace function core.users_share_branch(p_target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, core, auth
as $$
  select
    core.is_platform_admin()
    or p_target_user_id = core.effective_user_id()
    or exists (
      select 1
      from core.user_branch_access me
      join core.user_branch_access them
        on them.branch_id = me.branch_id
       and them.is_active = true
      where me.user_id = core.effective_user_id()
        and me.is_active = true
        and them.user_id = p_target_user_id
    )
$$;

create or replace function core.employee_belongs_to_current_user(p_employee_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, hr, core, auth
as $$
  select exists (
    select 1
    from hr.employees e
    where e.id = p_employee_id
      and e.linked_user_id = core.effective_user_id()
  )
$$;

create or replace function core.can_view_leave_request(p_leave_request_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, hr, core, auth
as $$
  select
    core.is_platform_admin()
    or exists (
      select 1
      from hr.leave_requests lr
      join hr.employees e on e.id = lr.employee_id
      where lr.id = p_leave_request_id
        and (
          e.linked_user_id = core.effective_user_id()
          or lr.approver_user_id = core.effective_user_id()
          or core.user_has_permission_in_branch('leave.approve', e.branch_id)
        )
    )
$$;

create or replace function core.can_approve_leave_request(p_leave_request_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, hr, core, auth
as $$
  select
    core.is_platform_admin()
    or exists (
      select 1
      from hr.leave_requests lr
      join hr.employees e on e.id = lr.employee_id
      where lr.id = p_leave_request_id
        and core.user_has_permission_in_branch('leave.approve', e.branch_id)
    )
$$;

create or replace function core.can_view_attachment(p_entity_type text, p_entity_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, core, sales, svc, acct, hr, auth
as $$
declare
  v_branch_id uuid;
begin
  if core.is_platform_admin() then
    return true;
  end if;

  if p_entity_type is null or p_entity_id is null then
    return false;
  end if;

  case p_entity_type
    when 'customer' then
      select c.branch_id into v_branch_id from sales.customers c where c.id = p_entity_id;
      return coalesce(core.can_view_customer_branch(v_branch_id), false);

    when 'booking' then
      select b.branch_id into v_branch_id from sales.bookings b where b.id = p_entity_id;
      return coalesce(core.can_view_booking_branch(v_branch_id), false);

    when 'reservation' then
      select b.branch_id into v_branch_id
      from sales.reservations r
      join sales.bookings b on b.id = r.booking_id
      where r.id = p_entity_id;
      return coalesce(core.can_view_booking_branch(v_branch_id), false);

    when 'payment' then
      select b.branch_id into v_branch_id
      from sales.payments p
      join sales.bookings b on b.id = p.booking_id
      where p.id = p_entity_id;
      return coalesce(core.can_view_payment_branch(v_branch_id), false);

    when 'refund' then
      select b.branch_id into v_branch_id
      from sales.refunds r
      join sales.bookings b on b.id = r.booking_id
      where r.id = p_entity_id;
      return coalesce(core.can_view_refund_branch(v_branch_id), false);

    when 'invoice' then
      select i.branch_id into v_branch_id from sales.invoices i where i.id = p_entity_id;
      return coalesce(core.can_view_invoice_branch(v_branch_id), false);

    when 'vehicle' then
      select v.branch_id into v_branch_id from svc.vehicles v where v.id = p_entity_id;
      return coalesce(core.can_view_service_branch(v_branch_id), false);

    when 'service_appointment' then
      select a.branch_id into v_branch_id from svc.service_appointments a where a.id = p_entity_id;
      return coalesce(core.can_view_service_branch(v_branch_id), false);

    when 'work_order' then
      select w.branch_id into v_branch_id from svc.work_orders w where w.id = p_entity_id;
      return coalesce(core.can_view_service_branch(v_branch_id), false);

    when 'work_order_item' then
      select w.branch_id into v_branch_id
      from svc.work_order_items i
      join svc.work_orders w on w.id = i.work_order_id
      where i.id = p_entity_id;
      return coalesce(core.can_view_service_branch(v_branch_id), false);

    when 'leave_request' then
      return core.can_view_leave_request(p_entity_id);

    else
      return false;
  end case;
end;
$$;

create or replace function core.can_manage_attachment(p_entity_type text, p_entity_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, core, sales, svc, acct, hr, auth
as $$
declare
  v_branch_id uuid;
begin
  if core.is_platform_admin() then
    return true;
  end if;

  if p_entity_type is null or p_entity_id is null then
    return false;
  end if;

  case p_entity_type
    when 'customer' then
      select c.branch_id into v_branch_id from sales.customers c where c.id = p_entity_id;
      return coalesce(core.can_manage_customer_branch(v_branch_id), false);

    when 'booking' then
      select b.branch_id into v_branch_id from sales.bookings b where b.id = p_entity_id;
      return coalesce(core.can_manage_booking_branch(v_branch_id), false);

    when 'reservation' then
      select b.branch_id into v_branch_id
      from sales.reservations r
      join sales.bookings b on b.id = r.booking_id
      where r.id = p_entity_id;
      return coalesce(core.can_manage_booking_branch(v_branch_id), false);

    when 'payment' then
      select b.branch_id into v_branch_id
      from sales.payments p
      join sales.bookings b on b.id = p.booking_id
      where p.id = p_entity_id;
      return coalesce(core.can_manage_payment_branch(v_branch_id), false);

    when 'refund' then
      select b.branch_id into v_branch_id
      from sales.refunds r
      join sales.bookings b on b.id = r.booking_id
      where r.id = p_entity_id;
      return coalesce(core.can_approve_refund_branch(v_branch_id) or core.can_request_refund_branch(v_branch_id), false);

    when 'invoice' then
      select i.branch_id into v_branch_id from sales.invoices i where i.id = p_entity_id;
      return coalesce(core.can_manage_invoice_branch(v_branch_id), false);

    when 'vehicle' then
      select v.branch_id into v_branch_id from svc.vehicles v where v.id = p_entity_id;
      return coalesce(core.can_manage_service_branch(v_branch_id), false);

    when 'service_appointment' then
      select a.branch_id into v_branch_id from svc.service_appointments a where a.id = p_entity_id;
      return coalesce(core.can_manage_service_branch(v_branch_id), false);

    when 'work_order' then
      select w.branch_id into v_branch_id from svc.work_orders w where w.id = p_entity_id;
      return coalesce(core.can_manage_service_branch(v_branch_id), false);

    when 'work_order_item' then
      select w.branch_id into v_branch_id
      from svc.work_order_items i
      join svc.work_orders w on w.id = i.work_order_id
      where i.id = p_entity_id;
      return coalesce(core.can_manage_service_branch(v_branch_id), false);

    when 'leave_request' then
      return core.can_approve_leave_request(p_entity_id) or core.can_view_leave_request(p_entity_id);

    else
      return false;
  end case;
end;
$$;

grant execute on all functions in schema core, sales, svc, acct, hr, audit, analytics to authenticated;
grant execute on all functions in schema core, sales, svc, acct, hr, audit, analytics to service_role;

commit;

-- >>> 001_core_rls.sql
begin;

do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname in ('core')
  loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
  end loop;
end $$;

drop policy if exists branches_select on core.branches;
create policy branches_select on core.branches
for select to authenticated
using (
  core.is_platform_admin()
  or core.user_can_access_branch(id)
  or core.user_has_permission_in_branch('branch.view', id)
  or core.user_has_permission_in_branch('branch.manage', id)
);

drop policy if exists branches_insert on core.branches;
create policy branches_insert on core.branches
for insert to authenticated
with check (core.is_platform_admin());

drop policy if exists branches_update on core.branches;
create policy branches_update on core.branches
for update to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists branches_delete on core.branches;
create policy branches_delete on core.branches
for delete to authenticated
using (core.is_platform_admin());

drop policy if exists roles_select on core.roles;
create policy roles_select on core.roles
for select to authenticated
using (core.is_platform_admin());

drop policy if exists roles_write on core.roles;
create policy roles_write on core.roles
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists permissions_select on core.permissions;
create policy permissions_select on core.permissions
for select to authenticated
using (core.is_platform_admin());

drop policy if exists permissions_write on core.permissions;
create policy permissions_write on core.permissions
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists role_permissions_select on core.role_permissions;
create policy role_permissions_select on core.role_permissions
for select to authenticated
using (core.is_platform_admin());

drop policy if exists role_permissions_write on core.role_permissions;
create policy role_permissions_write on core.role_permissions
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists user_profiles_select on core.user_profiles;
create policy user_profiles_select on core.user_profiles
for select to authenticated
using (
  core.is_platform_admin()
  or user_id = core.effective_user_id()
  or core.users_share_branch(user_id)
);

drop policy if exists user_profiles_insert on core.user_profiles;
create policy user_profiles_insert on core.user_profiles
for insert to authenticated
with check (
  core.is_platform_admin()
  or user_id = core.effective_user_id()
);

drop policy if exists user_profiles_update on core.user_profiles;
create policy user_profiles_update on core.user_profiles
for update to authenticated
using (
  core.is_platform_admin()
  or user_id = core.effective_user_id()
)
with check (
  core.is_platform_admin()
  or user_id = core.effective_user_id()
);

drop policy if exists user_branch_access_select on core.user_branch_access;
create policy user_branch_access_select on core.user_branch_access
for select to authenticated
using (
  core.is_platform_admin()
  or user_id = core.effective_user_id()
);

drop policy if exists user_branch_access_write on core.user_branch_access;
create policy user_branch_access_write on core.user_branch_access
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists reference_values_select on core.reference_values;
create policy reference_values_select on core.reference_values
for select to authenticated
using (true);

drop policy if exists reference_values_write on core.reference_values;
create policy reference_values_write on core.reference_values
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists attachments_select on core.attachments;
create policy attachments_select on core.attachments
for select to authenticated
using (
  core.is_platform_admin()
  or uploaded_by = core.effective_user_id()
  or core.can_view_attachment(entity_type, entity_id)
);

drop policy if exists attachments_insert on core.attachments;
create policy attachments_insert on core.attachments
for insert to authenticated
with check (
  core.is_platform_admin()
  or (
    coalesce(uploaded_by, core.effective_user_id()) = core.effective_user_id()
    and core.can_manage_attachment(entity_type, entity_id)
  )
);

drop policy if exists attachments_update on core.attachments;
create policy attachments_update on core.attachments
for update to authenticated
using (
  core.is_platform_admin()
  or uploaded_by = core.effective_user_id()
  or core.can_manage_attachment(entity_type, entity_id)
)
with check (
  core.is_platform_admin()
  or uploaded_by = core.effective_user_id()
  or core.can_manage_attachment(entity_type, entity_id)
);

drop policy if exists attachments_delete on core.attachments;
create policy attachments_delete on core.attachments
for delete to authenticated
using (
  core.is_platform_admin()
  or uploaded_by = core.effective_user_id()
  or core.can_manage_attachment(entity_type, entity_id)
);

drop policy if exists notification_queue_select on core.notification_queue;
create policy notification_queue_select on core.notification_queue
for select to authenticated
using (core.is_platform_admin());

drop policy if exists notification_queue_write on core.notification_queue;
create policy notification_queue_write on core.notification_queue
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

commit;

-- >>> 002_sales_rls.sql
begin;

do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname in ('sales')
  loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
  end loop;
end $$;

drop policy if exists customers_select on sales.customers;
create policy customers_select on sales.customers
for select to authenticated
using (core.can_view_customer_branch(branch_id));

drop policy if exists customers_insert on sales.customers;
create policy customers_insert on sales.customers
for insert to authenticated
with check (core.can_manage_customer_branch(branch_id));

drop policy if exists customers_update on sales.customers;
create policy customers_update on sales.customers
for update to authenticated
using (core.can_manage_customer_branch(branch_id))
with check (core.can_manage_customer_branch(branch_id));

drop policy if exists customer_contacts_select on sales.customer_contacts;
create policy customer_contacts_select on sales.customer_contacts
for select to authenticated
using (
  exists (
    select 1
    from sales.customers c
    where c.id = customer_id
      and core.can_view_customer_branch(c.branch_id)
  )
);

drop policy if exists customer_contacts_write on sales.customer_contacts;
create policy customer_contacts_write on sales.customer_contacts
for all to authenticated
using (
  exists (
    select 1
    from sales.customers c
    where c.id = customer_id
      and core.can_manage_customer_branch(c.branch_id)
  )
)
with check (
  exists (
    select 1
    from sales.customers c
    where c.id = customer_id
      and core.can_manage_customer_branch(c.branch_id)
  )
);

drop policy if exists bookings_select on sales.bookings;
create policy bookings_select on sales.bookings
for select to authenticated
using (core.can_view_booking_branch(branch_id));

drop policy if exists bookings_insert on sales.bookings;
create policy bookings_insert on sales.bookings
for insert to authenticated
with check (core.can_manage_booking_branch(branch_id));

drop policy if exists bookings_update on sales.bookings;
create policy bookings_update on sales.bookings
for update to authenticated
using (core.can_manage_booking_branch(branch_id))
with check (core.can_manage_booking_branch(branch_id));

drop policy if exists bookings_delete on sales.bookings;
create policy bookings_delete on sales.bookings
for delete to authenticated
using (core.is_platform_admin());

drop policy if exists booking_status_events_select on sales.booking_status_events;
create policy booking_status_events_select on sales.booking_status_events
for select to authenticated
using (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_view_booking_branch(b.branch_id)
  )
);

drop policy if exists booking_status_events_insert on sales.booking_status_events;
create policy booking_status_events_insert on sales.booking_status_events
for insert to authenticated
with check (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_manage_booking_branch(b.branch_id)
  )
);

drop policy if exists reservations_select on sales.reservations;
create policy reservations_select on sales.reservations
for select to authenticated
using (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_view_booking_branch(b.branch_id)
  )
);

drop policy if exists reservations_write on sales.reservations;
create policy reservations_write on sales.reservations
for all to authenticated
using (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_manage_booking_branch(b.branch_id)
  )
)
with check (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_manage_booking_branch(b.branch_id)
  )
);

drop policy if exists payments_select on sales.payments;
create policy payments_select on sales.payments
for select to authenticated
using (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_view_payment_branch(b.branch_id)
  )
);

drop policy if exists payments_insert on sales.payments;
create policy payments_insert on sales.payments
for insert to authenticated
with check (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_manage_payment_branch(b.branch_id)
  )
);

drop policy if exists payments_update on sales.payments;
create policy payments_update on sales.payments
for update to authenticated
using (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_manage_payment_branch(b.branch_id)
  )
)
with check (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_manage_payment_branch(b.branch_id)
  )
);

drop policy if exists refunds_select on sales.refunds;
create policy refunds_select on sales.refunds
for select to authenticated
using (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_view_refund_branch(b.branch_id)
  )
);

drop policy if exists refunds_insert on sales.refunds;
create policy refunds_insert on sales.refunds
for insert to authenticated
with check (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and core.can_request_refund_branch(b.branch_id)
  )
);

drop policy if exists refunds_update on sales.refunds;
create policy refunds_update on sales.refunds
for update to authenticated
using (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and (
        core.can_request_refund_branch(b.branch_id)
        or core.can_approve_refund_branch(b.branch_id)
      )
  )
)
with check (
  exists (
    select 1
    from sales.bookings b
    where b.id = booking_id
      and (
        core.can_request_refund_branch(b.branch_id)
        or core.can_approve_refund_branch(b.branch_id)
      )
  )
);

drop policy if exists invoices_select on sales.invoices;
create policy invoices_select on sales.invoices
for select to authenticated
using (core.can_view_invoice_branch(branch_id));

drop policy if exists invoices_insert on sales.invoices;
create policy invoices_insert on sales.invoices
for insert to authenticated
with check (core.can_manage_invoice_branch(branch_id));

drop policy if exists invoices_update on sales.invoices;
create policy invoices_update on sales.invoices
for update to authenticated
using (core.can_manage_invoice_branch(branch_id))
with check (core.can_manage_invoice_branch(branch_id));

commit;

-- >>> 003_service_rls.sql
begin;

do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname in ('svc')
  loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
  end loop;
end $$;

drop policy if exists vehicles_select on svc.vehicles;
create policy vehicles_select on svc.vehicles
for select to authenticated
using (core.can_view_service_branch(branch_id));

drop policy if exists vehicles_write on svc.vehicles;
create policy vehicles_write on svc.vehicles
for all to authenticated
using (core.can_manage_service_branch(branch_id))
with check (core.can_manage_service_branch(branch_id));

drop policy if exists service_appointments_select on svc.service_appointments;
create policy service_appointments_select on svc.service_appointments
for select to authenticated
using (core.can_view_service_branch(branch_id));

drop policy if exists service_appointments_write on svc.service_appointments;
create policy service_appointments_write on svc.service_appointments
for all to authenticated
using (core.can_manage_service_branch(branch_id))
with check (core.can_manage_service_branch(branch_id));

drop policy if exists work_orders_select on svc.work_orders;
create policy work_orders_select on svc.work_orders
for select to authenticated
using (core.can_view_service_branch(branch_id));

drop policy if exists work_orders_write on svc.work_orders;
create policy work_orders_write on svc.work_orders
for all to authenticated
using (core.can_manage_service_branch(branch_id))
with check (core.can_manage_service_branch(branch_id));

drop policy if exists work_order_items_select on svc.work_order_items;
create policy work_order_items_select on svc.work_order_items
for select to authenticated
using (
  exists (
    select 1
    from svc.work_orders w
    where w.id = work_order_id
      and core.can_view_service_branch(w.branch_id)
  )
);

drop policy if exists work_order_items_write on svc.work_order_items;
create policy work_order_items_write on svc.work_order_items
for all to authenticated
using (
  exists (
    select 1
    from svc.work_orders w
    where w.id = work_order_id
      and core.can_manage_service_branch(w.branch_id)
  )
)
with check (
  exists (
    select 1
    from svc.work_orders w
    where w.id = work_order_id
      and core.can_manage_service_branch(w.branch_id)
  )
);

drop policy if exists work_order_status_events_select on svc.work_order_status_events;
create policy work_order_status_events_select on svc.work_order_status_events
for select to authenticated
using (
  exists (
    select 1
    from svc.work_orders w
    where w.id = work_order_id
      and core.can_view_service_branch(w.branch_id)
  )
);

drop policy if exists work_order_status_events_insert on svc.work_order_status_events;
create policy work_order_status_events_insert on svc.work_order_status_events
for insert to authenticated
with check (
  exists (
    select 1
    from svc.work_orders w
    where w.id = work_order_id
      and core.can_manage_service_branch(w.branch_id)
  )
);

commit;

-- >>> 004_accounting_rls.sql
begin;

do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname in ('acct')
  loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
  end loop;
end $$;

drop policy if exists accounting_accounts_select on acct.accounting_accounts;
create policy accounting_accounts_select on acct.accounting_accounts
for select to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
);

drop policy if exists accounting_accounts_write on acct.accounting_accounts;
create policy accounting_accounts_write on acct.accounting_accounts
for all to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
)
with check (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
);

drop policy if exists journal_entries_select on acct.journal_entries;
create policy journal_entries_select on acct.journal_entries
for select to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
);

drop policy if exists journal_entries_write on acct.journal_entries;
create policy journal_entries_write on acct.journal_entries
for all to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
)
with check (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
);

drop policy if exists journal_lines_select on acct.journal_lines;
create policy journal_lines_select on acct.journal_lines
for select to authenticated
using (
  exists (
    select 1
    from acct.journal_entries je
    where je.id = journal_entry_id
      and (
        core.is_platform_admin()
        or exists (
          select 1
          from core.user_branch_access uba
          join core.role_permissions rp on rp.role_code = uba.role_code
          where uba.user_id = core.effective_user_id()
            and uba.is_active = true
            and rp.permission_code = 'journal.review'
        )
      )
  )
);

drop policy if exists journal_lines_write on acct.journal_lines;
create policy journal_lines_write on acct.journal_lines
for all to authenticated
using (
  exists (
    select 1
    from acct.journal_entries je
    where je.id = journal_entry_id
      and (
        core.is_platform_admin()
        or exists (
          select 1
          from core.user_branch_access uba
          join core.role_permissions rp on rp.role_code = uba.role_code
          where uba.user_id = core.effective_user_id()
            and uba.is_active = true
            and rp.permission_code = 'journal.review'
        )
      )
  )
)
with check (
  exists (
    select 1
    from acct.journal_entries je
    where je.id = journal_entry_id
      and (
        core.is_platform_admin()
        or exists (
          select 1
          from core.user_branch_access uba
          join core.role_permissions rp on rp.role_code = uba.role_code
          where uba.user_id = core.effective_user_id()
            and uba.is_active = true
            and rp.permission_code = 'journal.review'
        )
      )
  )
);

drop policy if exists ar_open_items_select on acct.ar_open_items;
create policy ar_open_items_select on acct.ar_open_items
for select to authenticated
using (core.user_has_permission_in_branch('ar_aging.view', branch_id));

drop policy if exists ar_open_items_write on acct.ar_open_items;
create policy ar_open_items_write on acct.ar_open_items
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists reconciliation_items_select on acct.reconciliation_items;
create policy reconciliation_items_select on acct.reconciliation_items
for select to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
);

drop policy if exists reconciliation_items_write on acct.reconciliation_items;
create policy reconciliation_items_write on acct.reconciliation_items
for all to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
)
with check (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'journal.review'
  )
);

commit;

-- >>> 005_hr_rls.sql
begin;

do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname in ('hr')
  loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
  end loop;
end $$;

drop policy if exists employees_select on hr.employees;
create policy employees_select on hr.employees
for select to authenticated
using (
  core.is_platform_admin()
  or linked_user_id = core.effective_user_id()
  or core.user_has_permission_in_branch('leave.approve', branch_id)
);

drop policy if exists employees_insert on hr.employees;
create policy employees_insert on hr.employees
for insert to authenticated
with check (core.is_platform_admin());

drop policy if exists employees_update on hr.employees;
create policy employees_update on hr.employees
for update to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists leave_types_select on hr.leave_types;
create policy leave_types_select on hr.leave_types
for select to authenticated
using (true);

drop policy if exists leave_types_write on hr.leave_types;
create policy leave_types_write on hr.leave_types
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists leave_balances_select on hr.leave_balances;
create policy leave_balances_select on hr.leave_balances
for select to authenticated
using (
  exists (
    select 1
    from hr.employees e
    where e.id = employee_id
      and (
        e.linked_user_id = core.effective_user_id()
        or core.user_has_permission_in_branch('leave.approve', e.branch_id)
        or core.is_platform_admin()
      )
  )
);

drop policy if exists leave_balances_write on hr.leave_balances;
create policy leave_balances_write on hr.leave_balances
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists leave_requests_select on hr.leave_requests;
create policy leave_requests_select on hr.leave_requests
for select to authenticated
using (core.can_view_leave_request(id));

drop policy if exists leave_requests_insert on hr.leave_requests;
create policy leave_requests_insert on hr.leave_requests
for insert to authenticated
with check (
  core.is_platform_admin()
  or core.employee_belongs_to_current_user(employee_id)
);

drop policy if exists leave_requests_update on hr.leave_requests;
create policy leave_requests_update on hr.leave_requests
for update to authenticated
using (
  core.is_platform_admin()
  or core.can_approve_leave_request(id)
  or core.employee_belongs_to_current_user(employee_id)
)
with check (
  core.is_platform_admin()
  or core.can_approve_leave_request(id)
  or core.employee_belongs_to_current_user(employee_id)
);

drop policy if exists leave_requests_delete on hr.leave_requests;
create policy leave_requests_delete on hr.leave_requests
for delete to authenticated
using (
  core.is_platform_admin()
  or (
    core.employee_belongs_to_current_user(employee_id)
    and status = 'draft'
  )
);

drop policy if exists leave_approval_events_select on hr.leave_approval_events;
create policy leave_approval_events_select on hr.leave_approval_events
for select to authenticated
using (core.can_view_leave_request(leave_request_id));

drop policy if exists leave_approval_events_insert on hr.leave_approval_events;
create policy leave_approval_events_insert on hr.leave_approval_events
for insert to authenticated
with check (
  core.is_platform_admin()
  or core.can_approve_leave_request(leave_request_id)
  or core.can_view_leave_request(leave_request_id)
);

commit;

-- >>> 006_audit_analytics_rls.sql
begin;

do $$
declare
  r record;
begin
  for r in
    select schemaname, tablename
    from pg_tables
    where schemaname in ('audit', 'analytics')
  loop
    execute format('alter table %I.%I enable row level security', r.schemaname, r.tablename);
  end loop;
end $$;

alter view analytics.vw_ar_aging_latest set (security_invoker = true);
alter view analytics.vw_booking_pipeline_open set (security_invoker = true);
alter view analytics.vw_work_order_backlog set (security_invoker = true);

drop policy if exists audit_events_select on audit.audit_events;
create policy audit_events_select on audit.audit_events
for select to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code = 'audit.view'
      and (
        branch_id is null
        or uba.branch_id = branch_id
        or uba.role_code = 'system_admin'
      )
  )
);

drop policy if exists audit_events_insert on audit.audit_events;
create policy audit_events_insert on audit.audit_events
for insert to authenticated
with check (
  core.is_platform_admin()
  or actor_user_id is null
  or actor_user_id = core.effective_user_id()
);

drop policy if exists audit_events_update on audit.audit_events;
create policy audit_events_update on audit.audit_events
for update to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists dim_date_select on analytics.dim_date;
create policy dim_date_select on analytics.dim_date
for select to authenticated
using (
  core.is_platform_admin()
  or exists (
    select 1
    from core.user_branch_access uba
    join core.role_permissions rp on rp.role_code = uba.role_code
    where uba.user_id = core.effective_user_id()
      and uba.is_active = true
      and rp.permission_code in ('dashboard.executive.view', 'service.analytics.view', 'ar_aging.view')
  )
);

drop policy if exists dim_date_write on analytics.dim_date;
create policy dim_date_write on analytics.dim_date
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists dim_branch_select on analytics.dim_branch;
create policy dim_branch_select on analytics.dim_branch
for select to authenticated
using (
  core.is_platform_admin()
  or core.user_can_access_branch(branch_id)
);

drop policy if exists dim_branch_write on analytics.dim_branch;
create policy dim_branch_write on analytics.dim_branch
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists dim_staff_select on analytics.dim_staff;
create policy dim_staff_select on analytics.dim_staff
for select to authenticated
using (
  core.is_platform_admin()
  or user_id = core.effective_user_id()
  or core.users_share_branch(user_id)
);

drop policy if exists dim_staff_write on analytics.dim_staff;
create policy dim_staff_write on analytics.dim_staff
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists fact_sales_daily_select on analytics.fact_sales_daily;
create policy fact_sales_daily_select on analytics.fact_sales_daily
for select to authenticated
using (
  core.user_has_any_permission_in_branch(
    array['dashboard.executive.view', 'booking.view', 'booking.manage', 'booking.approve'],
    branch_id
  )
);

drop policy if exists fact_sales_daily_write on analytics.fact_sales_daily;
create policy fact_sales_daily_write on analytics.fact_sales_daily
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists fact_service_daily_select on analytics.fact_service_daily;
create policy fact_service_daily_select on analytics.fact_service_daily
for select to authenticated
using (
  core.user_has_any_permission_in_branch(
    array['dashboard.executive.view', 'service.analytics.view', 'service.work_order.manage', 'service.appointment.manage'],
    branch_id
  )
);

drop policy if exists fact_service_daily_write on analytics.fact_service_daily;
create policy fact_service_daily_write on analytics.fact_service_daily
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

drop policy if exists fact_ar_snapshot_select on analytics.fact_ar_snapshot;
create policy fact_ar_snapshot_select on analytics.fact_ar_snapshot
for select to authenticated
using (core.user_has_any_permission_in_branch(array['dashboard.executive.view', 'ar_aging.view'], branch_id));

drop policy if exists fact_ar_snapshot_write on analytics.fact_ar_snapshot;
create policy fact_ar_snapshot_write on analytics.fact_ar_snapshot
for all to authenticated
using (core.is_platform_admin())
with check (core.is_platform_admin());

grant select on analytics.vw_ar_aging_latest to authenticated, service_role;
grant select on analytics.vw_booking_pipeline_open to authenticated, service_role;
grant select on analytics.vw_work_order_backlog to authenticated, service_role;

-- Inventory RLS policies
alter table inv.products enable row level security;
alter table inv.stock_levels enable row level security;
alter table inv.stock_movements enable row level security;
alter table inv.adjustments enable row level security;

drop policy if exists products_branch_access on inv.products;
create policy products_branch_access on inv.products
  for all to authenticated
  using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
    )
  );

drop policy if exists stock_levels_branch_access on inv.stock_levels;
create policy stock_levels_branch_access on inv.stock_levels
  for all to authenticated
  using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
    )
  );

drop policy if exists stock_movements_branch_access on inv.stock_movements;
create policy stock_movements_branch_access on inv.stock_movements
  for all to authenticated
  using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
    )
  );

drop policy if exists adjustments_branch_access on inv.adjustments;
create policy adjustments_branch_access on inv.adjustments
  for all to authenticated
  using (
    branch_id in (
      select branch_id from core.user_branch_access
      where user_id = core.current_app_user_id()
      and role in ('manager', 'admin')
    )
  );

drop policy if exists products_service_role on inv.products;
create policy products_service_role on inv.products
  for all using (auth.jwt() ->> 'role' = 'service_role');

drop policy if exists stock_levels_service_role on inv.stock_levels;
create policy stock_levels_service_role on inv.stock_levels
  for all using (auth.jwt() ->> 'role' = 'service_role');

drop policy if exists stock_movements_service_role on inv.stock_movements;
create policy stock_movements_service_role on inv.stock_movements
  for all using (auth.jwt() ->> 'role' = 'service_role');

drop policy if exists adjustments_service_role on inv.adjustments;
create policy adjustments_service_role on inv.adjustments
  for all using (auth.jwt() ->> 'role' = 'service_role');

