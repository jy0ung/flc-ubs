begin;

create index if not exists idx_core_user_profiles_home_branch
  on core.user_profiles (home_branch_id);

create index if not exists idx_core_user_branch_access_user_branch
  on core.user_branch_access (user_id, branch_id)
  where is_active = true;

create index if not exists idx_core_reference_values_domain_active
  on core.reference_values (domain_name, is_active, sort_order);

create index if not exists idx_core_notification_queue_status_sched
  on core.notification_queue (status, scheduled_at);

create index if not exists idx_core_attachments_entity
  on core.attachments (entity_type, entity_id);

create index if not exists idx_sales_customers_branch_created
  on sales.customers (branch_id, created_at desc);

create index if not exists idx_sales_customers_phone
  on sales.customers (phone);

create index if not exists idx_sales_customers_email
  on sales.customers (email);

create index if not exists idx_sales_customers_full_name_trgm
  on sales.customers using gin (full_name gin_trgm_ops);

create index if not exists idx_sales_customer_contacts_customer
  on sales.customer_contacts (customer_id, is_primary desc);

create index if not exists idx_sales_bookings_branch_status_date
  on sales.bookings (branch_id, status, booking_date desc);

create index if not exists idx_sales_bookings_owner_status
  on sales.bookings (sales_owner_user_id, status, booking_date desc);

create index if not exists idx_sales_bookings_customer
  on sales.bookings (customer_id, created_at desc);

create index if not exists idx_sales_bookings_reserved_until
  on sales.bookings (reserved_until)
  where reserved_until is not null;

create index if not exists idx_sales_bookings_model_code
  on sales.bookings (model_code);

create index if not exists idx_sales_booking_events_booking_changed_at
  on sales.booking_status_events (booking_id, changed_at desc);

create index if not exists idx_sales_reservations_booking
  on sales.reservations (booking_id, reserved_until desc);

create index if not exists idx_sales_payments_booking_date
  on sales.payments (booking_id, payment_date desc);

create index if not exists idx_sales_payments_verification_status
  on sales.payments (verification_status, payment_date desc);

create index if not exists idx_sales_payments_reference_no
  on sales.payments (reference_no);

create index if not exists idx_sales_refunds_status_requested
  on sales.refunds (status, requested_at desc);

create index if not exists idx_sales_refunds_booking
  on sales.refunds (booking_id);

create index if not exists idx_sales_invoices_branch_status_date
  on sales.invoices (branch_id, status, invoice_date desc);

create index if not exists idx_sales_invoices_customer_due
  on sales.invoices (customer_id, due_date);

create index if not exists idx_svc_vehicles_customer
  on svc.vehicles (customer_id);

create index if not exists idx_svc_vehicles_branch
  on svc.vehicles (branch_id);

create index if not exists idx_svc_service_appointments_branch_time
  on svc.service_appointments (branch_id, appointment_at desc);

create index if not exists idx_svc_service_appointments_status
  on svc.service_appointments (status, appointment_at desc);

create index if not exists idx_svc_service_appointments_customer
  on svc.service_appointments (customer_id);

create index if not exists idx_svc_work_orders_branch_status_opened
  on svc.work_orders (branch_id, status, opened_at desc);

create index if not exists idx_svc_work_orders_manager_status
  on svc.work_orders (service_manager_user_id, status, opened_at desc);

create index if not exists idx_svc_work_orders_customer
  on svc.work_orders (customer_id);

create index if not exists idx_svc_work_order_events_work_order_changed
  on svc.work_order_status_events (work_order_id, changed_at desc);

create index if not exists idx_acct_journal_entries_status_date
  on acct.journal_entries (status, posting_date desc);

create index if not exists idx_acct_journal_entries_source
  on acct.journal_entries (source_type, source_id);

create index if not exists idx_acct_journal_lines_journal
  on acct.journal_lines (journal_entry_id, line_no);

create index if not exists idx_acct_ar_open_items_snapshot_branch
  on acct.ar_open_items (snapshot_date, branch_id);

create index if not exists idx_acct_ar_open_items_customer_due
  on acct.ar_open_items (customer_id, due_date);

create index if not exists idx_acct_ar_open_items_balance_open
  on acct.ar_open_items (balance)
  where balance > 0;

create index if not exists idx_acct_reconciliation_items_status_date
  on acct.reconciliation_items (status, reconciliation_date);

create index if not exists idx_hr_employees_branch
  on hr.employees (branch_id, is_active);

create index if not exists idx_hr_leave_balances_employee_year
  on hr.leave_balances (employee_id, balance_year);

create index if not exists idx_hr_leave_requests_status_dates
  on hr.leave_requests (status, start_date, end_date);

create index if not exists idx_hr_leave_requests_approver_status
  on hr.leave_requests (approver_user_id, status);

create index if not exists idx_hr_leave_requests_employee_created
  on hr.leave_requests (employee_id, created_at desc);

create index if not exists idx_hr_leave_approval_events_leave_changed
  on hr.leave_approval_events (leave_request_id, changed_at desc);

create index if not exists idx_audit_events_actor_occurred
  on audit.audit_events (actor_user_id, occurred_at desc);

create index if not exists idx_audit_events_entity
  on audit.audit_events (entity_type, entity_id, occurred_at desc);

create index if not exists idx_audit_events_action_occurred
  on audit.audit_events (action, occurred_at desc);

create index if not exists idx_analytics_fact_sales_daily_snapshot_branch
  on analytics.fact_sales_daily (snapshot_date, branch_id);

create index if not exists idx_analytics_fact_service_daily_snapshot_branch
  on analytics.fact_service_daily (snapshot_date, branch_id);

create index if not exists idx_analytics_fact_ar_snapshot_snapshot_branch
  on analytics.fact_ar_snapshot (snapshot_date, branch_id, bucket_name);

commit;
