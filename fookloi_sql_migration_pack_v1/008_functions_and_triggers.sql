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
