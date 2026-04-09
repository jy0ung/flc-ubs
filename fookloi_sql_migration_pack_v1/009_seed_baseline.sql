begin;

insert into core.roles (code, name, category, is_system)
values
  ('director_of_service', 'Director of Service', 'business', true),
  ('gm_service', 'General Manager of Service', 'business', true),
  ('gm_sales', 'General Manager of Sales', 'business', true),
  ('accounting_manager', 'Accounting Manager', 'business', true),
  ('finance_manager', 'Finance Manager', 'business', true),
  ('sales_admin', 'Sales Admin', 'business', true),
  ('service_manager', 'Service Manager', 'business', true),
  ('sales_manager', 'Sales Manager', 'business', true),
  ('system_admin', 'System Administrator', 'system', true)
on conflict (code) do update
set
  name = excluded.name,
  category = excluded.category,
  is_system = excluded.is_system,
  updated_at = now();

insert into core.permissions (code, name, module_name, action_name, description)
values
  ('dashboard.executive.view', 'View executive dashboard', 'dashboard', 'view', 'View executive KPI dashboard'),
  ('dashboard.executive.export', 'Export executive dashboard', 'dashboard', 'export', 'Export executive dashboard data'),
  ('branch.view', 'View branches', 'branch', 'view', 'View branches'),
  ('branch.manage', 'Manage branches', 'branch', 'manage', 'Create and update branches'),
  ('user.manage', 'Manage users', 'user', 'manage', 'Create and update users'),
  ('role.assign', 'Assign roles', 'role', 'assign', 'Assign roles to users'),
  ('customer.view', 'View customers', 'customer', 'view', 'View customers'),
  ('customer.manage', 'Manage customers', 'customer', 'manage', 'Create and edit customers'),
  ('booking.view', 'View bookings', 'booking', 'view', 'View bookings'),
  ('booking.manage', 'Manage bookings', 'booking', 'manage', 'Create and edit bookings'),
  ('booking.approve', 'Approve bookings', 'booking', 'approve', 'Approve sales bookings'),
  ('payment.view', 'View payments', 'payment', 'view', 'View payments'),
  ('payment.manage', 'Manage payments', 'payment', 'manage', 'Create payments'),
  ('payment.verify', 'Verify payments', 'payment', 'verify', 'Verify payments'),
  ('refund.request', 'Request refunds', 'refund', 'request', 'Create refund requests'),
  ('refund.approve', 'Approve refunds', 'refund', 'approve', 'Approve refunds'),
  ('service.appointment.manage', 'Manage service appointments', 'service_appointment', 'manage', 'Manage service appointments'),
  ('service.work_order.manage', 'Manage work orders', 'work_order', 'manage', 'Manage work orders'),
  ('service.analytics.view', 'View service analytics', 'service_analytics', 'view', 'View service analytics'),
  ('invoice.manage', 'Manage invoices', 'invoice', 'manage', 'Create and edit invoices'),
  ('ar_aging.view', 'View AR aging', 'ar_aging', 'view', 'View AR aging analytics'),
  ('journal.review', 'Review journals', 'journal', 'review', 'Review journal entries'),
  ('leave.request', 'Request leave', 'leave', 'request', 'Submit leave requests'),
  ('leave.approve', 'Approve leave', 'leave', 'approve', 'Approve leave requests'),
  ('audit.view', 'View audit logs', 'audit', 'view', 'View audit events'),
  ('export.sensitive', 'Sensitive export', 'export', 'sensitive', 'Export sensitive data')
on conflict (code) do update
set
  name = excluded.name,
  module_name = excluded.module_name,
  action_name = excluded.action_name,
  description = excluded.description,
  updated_at = now();

insert into core.role_permissions (role_code, permission_code)
values
  ('director_of_service', 'dashboard.executive.view'),
  ('director_of_service', 'dashboard.executive.export'),
  ('director_of_service', 'branch.view'),
  ('director_of_service', 'service.analytics.view'),

  ('gm_service', 'dashboard.executive.view'),
  ('gm_service', 'dashboard.executive.export'),
  ('gm_service', 'branch.view'),
  ('gm_service', 'service.appointment.manage'),
  ('gm_service', 'service.work_order.manage'),
  ('gm_service', 'service.analytics.view'),
  ('gm_service', 'leave.approve'),

  ('gm_sales', 'dashboard.executive.view'),
  ('gm_sales', 'dashboard.executive.export'),
  ('gm_sales', 'branch.view'),
  ('gm_sales', 'customer.view'),
  ('gm_sales', 'booking.view'),
  ('gm_sales', 'payment.view'),
  ('gm_sales', 'invoice.manage'),
  ('gm_sales', 'ar_aging.view'),
  ('gm_sales', 'export.sensitive'),

  ('accounting_manager', 'dashboard.executive.view'),
  ('accounting_manager', 'dashboard.executive.export'),
  ('accounting_manager', 'branch.view'),
  ('accounting_manager', 'customer.view'),
  ('accounting_manager', 'booking.view'),
  ('accounting_manager', 'payment.view'),
  ('accounting_manager', 'invoice.manage'),
  ('accounting_manager', 'ar_aging.view'),
  ('accounting_manager', 'journal.review'),
  ('accounting_manager', 'audit.view'),
  ('accounting_manager', 'export.sensitive'),

  ('finance_manager', 'dashboard.executive.view'),
  ('finance_manager', 'dashboard.executive.export'),
  ('finance_manager', 'branch.view'),
  ('finance_manager', 'customer.view'),
  ('finance_manager', 'booking.view'),
  ('finance_manager', 'payment.view'),
  ('finance_manager', 'payment.manage'),
  ('finance_manager', 'payment.verify'),
  ('finance_manager', 'refund.approve'),
  ('finance_manager', 'invoice.manage'),
  ('finance_manager', 'ar_aging.view'),
  ('finance_manager', 'export.sensitive'),

  ('sales_admin', 'customer.view'),
  ('sales_admin', 'customer.manage'),
  ('sales_admin', 'booking.view'),
  ('sales_admin', 'booking.manage'),
  ('sales_admin', 'payment.manage'),
  ('sales_admin', 'refund.request'),
  ('sales_admin', 'leave.request'),

  ('service_manager', 'service.appointment.manage'),
  ('service_manager', 'service.work_order.manage'),
  ('service_manager', 'service.analytics.view'),
  ('service_manager', 'leave.request'),
  ('service_manager', 'leave.approve'),

  ('sales_manager', 'dashboard.executive.view'),
  ('sales_manager', 'customer.view'),
  ('sales_manager', 'customer.manage'),
  ('sales_manager', 'booking.view'),
  ('sales_manager', 'booking.manage'),
  ('sales_manager', 'booking.approve'),
  ('sales_manager', 'payment.view'),
  ('sales_manager', 'ar_aging.view'),
  ('sales_manager', 'leave.request'),
  ('sales_manager', 'leave.approve'),

  ('system_admin', 'dashboard.executive.view'),
  ('system_admin', 'branch.view'),
  ('system_admin', 'branch.manage'),
  ('system_admin', 'user.manage'),
  ('system_admin', 'role.assign'),
  ('system_admin', 'audit.view'),
  ('system_admin', 'export.sensitive')
on conflict (role_code, permission_code) do nothing;

insert into hr.leave_types (code, name, days_per_year, requires_attachment)
values
  ('annual', 'Annual Leave', 12, false),
  ('medical', 'Medical Leave', 14, true),
  ('emergency', 'Emergency Leave', 3, false),
  ('unpaid', 'Unpaid Leave', 0, false)
on conflict (code) do update
set
  name = excluded.name,
  days_per_year = excluded.days_per_year,
  requires_attachment = excluded.requires_attachment,
  updated_at = now();

insert into core.reference_values (domain_name, value_key, label, sort_order, value_json)
values
  ('payment_method', 'cash', 'Cash', 10, '{}'::jsonb),
  ('payment_method', 'bank_transfer', 'Bank Transfer', 20, '{}'::jsonb),
  ('payment_method', 'cheque', 'Cheque', 30, '{}'::jsonb),
  ('payment_method', 'card', 'Card', 40, '{}'::jsonb),
  ('refund_reason', 'booking_cancelled', 'Booking Cancelled', 10, '{}'::jsonb),
  ('refund_reason', 'duplicate_payment', 'Duplicate Payment', 20, '{}'::jsonb),
  ('refund_reason', 'overpayment', 'Overpayment', 30, '{}'::jsonb),
  ('service_type', 'maintenance', 'Maintenance', 10, '{}'::jsonb),
  ('service_type', 'repair', 'Repair', 20, '{}'::jsonb),
  ('service_type', 'inspection', 'Inspection', 30, '{}'::jsonb)
on conflict (domain_name, value_key) do update
set
  label = excluded.label,
  sort_order = excluded.sort_order,
  value_json = excluded.value_json,
  updated_at = now();

commit;
