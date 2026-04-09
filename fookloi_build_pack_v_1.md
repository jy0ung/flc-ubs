# Fook Loi Unified Business Suite
## Build Pack V1

**Version:** 1.0  
**Date:** 2026-04-08  
**Deployment Target:** Ubuntu Server, Intel i3 9th Gen, 16GB DDR4 RAM, NVMe SSD  
**Backend Target:** Self-hosted Supabase Stack  
**Product Scope:** Sales + Service first, Finance/Accounting controls, Executive analytics, HR Leave Management, Basic Inventory

---

## 1. Purpose of this Build Pack

This Build Pack converts the approved high-level PRD into an implementation-ready foundation for engineering, product, and deployment work.

It defines:
- MVP scope and exclusions
- module boundaries
- role-based access model
- canonical data model
- API and event contracts
- screen and navigation map
- deployment blueprint
- first sprint backlog
- acceptance gates for phase 1

This document is the baseline reference before production coding begins.

---

## 2. Product Goal

Build a secure, role-based, on-premise Unified Business Suite for Fook Loi Corporation that:
- replaces fragmented legacy workflows
- gives management real-time visibility into operations and cash collection
- supports Sales and Service as the operational core
- adds Finance/Accounting approvals and AR aging visibility
- includes HR Leave Management as the first HR module
- provides basic inventory tracking and warehouse management
- remains performant on a single modest Ubuntu server

---

## 3. MVP Scope Freeze

## 3.1 In Scope for V1

### Foundation
- authentication
- user profiles
- branch management
- RBAC
- audit logging
- reference data management

### Sales
- customer master
- booking / reservation management
- quotation-to-booking support
- payment capture
- refund request and approval flow
- sales dashboard

### Service
- service appointment management
- work order management
- service status timeline
- service dashboard

### Finance / Accounting
- invoice records
- payment verification
- refund approvals
- AR aging analytics
- accounting skeleton (journal-ready posting structure, not full ERP)

### Executive Analytics
- role-based KPI dashboards
- branch-filtered analytics
- aging, cash, operational SLA, backlog, conversion

### HR Core Phase 1
- leave type setup
- leave request submission
- leave approval workflow
- leave balance tracking
- leave reporting

### Inventory
- product/item master
- stock levels and tracking
- inventory adjustments
- basic warehouse management
- stock movement logging
- payroll
- employee claims
- recruitment
- attendance/clock-in
- procurement
- full warehouse ERP (advanced features like multi-location, batch tracking)
- customer self-service portal
- public e-commerce booking flow
- deep OEM integrations
- full general ledger close automation
- multi-server HA cluster

## 3.3 Reason for Scope Freeze

The target hardware is sufficient for a focused modular monolith, but not for an overly broad enterprise rollout in phase 1. The MVP is intentionally constrained so the team can stabilize security, workflows, and analytics first.

---

## 4. Design Principles

1. **Single source of truth**  
   One canonical record per customer, booking, payment, work order, employee, and leave request.

2. **RBAC before UI convenience**  
   Access control is enforced in database policy and backend logic, not just hidden in the frontend.

3. **Branch-aware by default**  
   Every transactional record must belong to a branch or clearly defined shared scope.

4. **Audit every sensitive action**  
   Logins, approvals, financial edits, exports, and status changes must be captured.

5. **Dashboard from trusted source data**  
   KPI tiles are derived from transactional events, not manually maintained summary fields.

6. **Performance on modest hardware**  
   Avoid unnecessary microservices, avoid heavy real-time features by default, and pre-aggregate analytics where needed.

7. **Build for phased expansion**  
   V1 must make future HR, payroll, portal, and additional finance modules possible without reworking the foundation.

---

## 5. Module Boundaries

## 5.1 Core Platform Module
Owns:
- users
- branches
- roles
- permissions
- profiles
- audit logs
- reference data
- notifications queue

## 5.2 Sales Module
Owns:
- customers
- sales leads (optional V1-lite)
- quotations (optional V1-lite)
- bookings
- reservations
- deposits/payments
- refunds
- sales pipeline states

## 5.3 Service Module
Owns:
- service customers linkage
- vehicles/assets
- service appointments
- work orders
- service statuses
- service notes and attachments

## 5.4 Finance & Accounting Module
Owns:
- invoices
- payment verification
- refund approvals
- AR aging snapshots
- accounting posting structures
- reconciliation states

## 5.5 HR Leave Module
Owns:
- employee master linkage
- leave types
- leave balances
- leave requests
- leave approvals
- leave calendar/reporting

## 5.6 Analytics Module
Owns:
- KPI views
- dashboard datasets
- materialized summaries
- executive filters
- scheduled snapshot tables

---

## 6. User Roles and RBAC Matrix

## 6.1 Role Catalog
- Director of Service
- General Manager of Service
- General Manager of Sales
- Accounting Manager
- Finance Manager
- Sales Admin
- Service Manager
- Sales Manager
- System Administrator

## 6.2 Permission Model

Permission levels:
- **N** = no access
- **V** = view only
- **C** = create
- **E** = edit
- **A** = approve
- **X** = export
- Combined values allowed, e.g. **V/C/E**, **V/A/X**

## 6.3 RBAC Matrix

| Module / Capability | Director of Service | GM Service | GM Sales | Accounting Manager | Finance Manager | Sales Admin | Service Manager | Sales Manager | System Admin |
|---|---|---|---|---|---|---|---|---|---|
| Executive dashboard | V/X | V/X | V/X | V/X | V/X | N | V | V | V |
| Branch master | V | V | V | V | V | N | V | V | V/C/E |
| User management | N | N | N | N | N | N | N | N | V/C/E/A |
| Role assignment | N | N | N | N | N | N | N | N | V/C/E/A |
| Customer records | V | V | V/X | V | V | V/C/E | V | V/C/E | V |
| Sales bookings | N | N | V/X | V | V | V/C/E | N | V/C/E/A | V |
| Sales payments | N | N | V | V/X | V/C/E/A/X | V/C | N | V | V |
| Refund requests | N | N | V | V | V/A/X | V/C | N | V | V |
| Refund approvals | N | N | N | V | V/A/X | N | N | N | V |
| Service appointments | V | V/C/E/X | N | N | N | N | V/C/E/A | N | V |
| Work orders | V | V/C/E/X | N | N | N | N | V/C/E/A | N | V |
| Service SLA analytics | V/X | V/X | N | N | N | N | V/X | N | V |
| Invoice records | N | N | V | V/C/E/X | V/C/E/A/X | V/C | N | V | V |
| AR aging | N | N | V | V/X | V/X | N | N | V | V |
| Journal posting review | N | N | N | V/C/E/A/X | V/V | N | N | N | V |
| Leave requests | N | N | N | N | N | V/C/E | V/C/E | V/C/E | V |
| Leave approvals | N | N | N | N | N | N | V/A | V/A | V |
| Audit logs | N | N | N | V | V | N | N | N | V/X |
| Sensitive exports | N | N | V (limited) | V/A/X | V/A/X | N | N | N | V/A/X |

## 6.4 RBAC Rules

1. All roles are branch-scoped unless specifically marked as cross-branch.
2. GM roles can view dashboards across allowed branches but may not edit financial control tables unless explicitly granted.
3. Finance approvals require a separate approval permission, not just edit permission.
4. System Admin can manage users and roles but should not be the default approver for finance workflows.
5. Sensitive exports must be explicitly logged and protected with step-up authentication for privileged roles.

---

## 7. Canonical Data Model V1

## 7.1 Core Entities

### Core Platform
- branches
- users
- user_profiles
- user_branch_access
- roles
- permissions
- audit_events
- notification_queue
- reference_values

### Sales
- customers
- customer_contacts
- bookings
- booking_status_events
- reservations
- payments
- refunds
- invoices
- attachments

### Service
- vehicles
- service_appointments
- work_orders
- work_order_status_events
- work_order_items
- service_attachments

### Finance / Accounting
- ar_open_items
- accounting_accounts
- journal_entries
- journal_lines
- reconciliation_items

### HR Leave
- employees
- leave_types
- leave_balances
- leave_requests
- leave_approval_events

### Analytics
- fact_sales_daily
- fact_service_daily
- fact_ar_snapshot
- dim_date
- dim_branch
- dim_staff

## 7.2 Schema Layout Recommendation

- `core`
- `sales`
- `svc`
- `acct`
- `hr`
- `audit`
- `analytics`

## 7.3 Table Blueprint (V1 Minimal)

### core.branches
- id (uuid, pk)
- code (text, unique)
- name (text)
- is_active (boolean)
- created_at
- updated_at

### core.user_profiles
- user_id (uuid, pk, auth user link)
- display_name
- email
- home_branch_id
- phone
- is_active
- created_at
- updated_at

### core.user_branch_access
- id
- user_id
- branch_id
- role_code
- is_active
- created_at

### sales.customers
- id
- customer_code
- full_name
- id_type
- id_value_encrypted
- phone
- email
- address_json
- branch_id
- created_by
- created_at
- updated_at

### sales.bookings
- id
- booking_no
- customer_id
- branch_id
- sales_owner_user_id
- booking_date
- reserved_until
- status
- model_code
- amount_total
- deposit_amount
- notes
- created_at
- updated_at

### sales.booking_status_events
- id
- booking_id
- from_status
- to_status
- changed_by
- reason_code
- changed_at

### sales.payments
- id
- booking_id
- payment_date
- amount
- method
- reference_no
- verification_status
- verified_by
- verified_at
- attachment_id
- created_at

### sales.refunds
- id
- booking_id
- refund_no
- amount
- reason
- status
- requested_by
- requested_at
- approved_by
- approved_at
- processed_at

### sales.invoices
- id
- booking_id
- invoice_no
- invoice_date
- subtotal
- tax_amount
- total_amount
- status
- created_at

### svc.vehicles
- id
- customer_id
- reg_no
- chassis_no
- engine_no
- make
- model
- variant
- year
- created_at

### svc.service_appointments
- id
- appointment_no
- vehicle_id
- customer_id
- branch_id
- appointment_at
- service_type
- advisor_user_id
- status
- created_at

### svc.work_orders
- id
- wo_no
- appointment_id
- vehicle_id
- customer_id
- branch_id
- service_manager_user_id
- opened_at
- started_at
- completed_at
- status
- total_amount
- notes

### svc.work_order_status_events
- id
- work_order_id
- from_status
- to_status
- changed_by
- reason_code
- changed_at

### acct.ar_open_items
- id
- source_type
- source_id
- branch_id
- customer_id
- invoice_no
- due_date
- amount_due
- amount_paid
- balance
- aging_bucket
- snapshot_date

### acct.accounting_accounts
- id
- account_code
- account_name
- account_type
- is_active

### acct.journal_entries
- id
- source_type
- source_id
- posting_date
- status
- created_by
- created_at

### acct.journal_lines
- id
- journal_entry_id
- account_id
- debit
- credit
- description

### hr.employees
- id
- staff_no
- full_name
- branch_id
- linked_user_id
- department
- is_active

### hr.leave_types
- id
- code
- name
- days_per_year
- requires_attachment
- is_active

### hr.leave_balances
- id
- employee_id
- leave_type_id
- year
- entitlement_days
- used_days
- remaining_days

### hr.leave_requests
- id
- request_no
- employee_id
- leave_type_id
- start_date
- end_date
- days_requested
- reason
- status
- approver_user_id
- submitted_at
- approved_at
- attachment_id

### audit.audit_events
- id
- occurred_at
- actor_user_id
- branch_id
- entity_type
- entity_id
- action
- old_values_json
- new_values_json
- ip_address
- user_agent

---

## 8. Status Models

## 8.1 Booking Status Flow

Draft → Submitted → Reserved → Deposit Pending → Deposit Verified → Invoiced → Completed  
Alternative paths:  
- Reserved → Expired  
- Any pre-completion state → Cancelled  
- Deposit Verified / Invoiced → Refund Requested → Refund Approved → Refund Processed

## 8.2 Service Appointment / Work Order Flow

Appointment Scheduled → Checked In → Work Order Opened → In Progress → Waiting Approval / Waiting Parts → Completed → Delivered / Closed

## 8.3 Leave Request Flow

Draft → Submitted → Approved / Rejected → Cancelled

---

## 9. API and Event Contract V1

## 9.1 API Style

- internal JSON API
- versioned routes under `/api/v1`
- Supabase-backed data access
- service role used only in secure backend functions, never in public frontend

## 9.2 Core API Groups

### Auth / Session
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/logout`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/mfa/verify`

### Branch / User / Access
- `GET /api/v1/branches`
- `GET /api/v1/users/me/access`
- `POST /api/v1/admin/users`
- `POST /api/v1/admin/users/{id}/roles`

### Customers
- `GET /api/v1/customers`
- `POST /api/v1/customers`
- `GET /api/v1/customers/{id}`
- `PATCH /api/v1/customers/{id}`

### Bookings
- `GET /api/v1/bookings`
- `POST /api/v1/bookings`
- `GET /api/v1/bookings/{id}`
- `PATCH /api/v1/bookings/{id}`
- `POST /api/v1/bookings/{id}/reserve`
- `POST /api/v1/bookings/{id}/verify-deposit`
- `POST /api/v1/bookings/{id}/cancel`

### Payments
- `GET /api/v1/payments`
- `POST /api/v1/bookings/{id}/payments`
- `POST /api/v1/payments/{id}/verify`

### Refunds
- `POST /api/v1/bookings/{id}/refunds`
- `POST /api/v1/refunds/{id}/approve`
- `POST /api/v1/refunds/{id}/process`

### Service
- `GET /api/v1/appointments`
- `POST /api/v1/appointments`
- `GET /api/v1/work-orders`
- `POST /api/v1/work-orders`
- `PATCH /api/v1/work-orders/{id}`
- `POST /api/v1/work-orders/{id}/status`

### Finance / Accounting
- `GET /api/v1/invoices`
- `GET /api/v1/ar-aging`
- `GET /api/v1/journals`
- `POST /api/v1/journals/{id}/post`

### HR Leave
- `GET /api/v1/leave-types`
- `GET /api/v1/leave-balances/me`
- `POST /api/v1/leave-requests`
- `GET /api/v1/leave-requests`
- `POST /api/v1/leave-requests/{id}/approve`
- `POST /api/v1/leave-requests/{id}/reject`

### Analytics
- `GET /api/v1/dashboard/executive`
- `GET /api/v1/dashboard/sales`
- `GET /api/v1/dashboard/service`
- `GET /api/v1/dashboard/finance`

## 9.3 Event Contract

Every important business event should be written to an event or status history table.

### Minimum Event Types
- booking.created
- booking.status_changed
- payment.created
- payment.verified
- refund.requested
- refund.approved
- refund.processed
- appointment.created
- work_order.created
- work_order.status_changed
- leave.submitted
- leave.approved
- leave.rejected
- user.login
- export.generated

## 9.4 Idempotency Rules

The following actions must be idempotent:
- payment verification
- refund approval
- refund processing
- journal posting
- notification dispatch

Use request IDs or source references to prevent duplicate processing.

---

## 10. Frontend Screen Map V1

## 10.1 Common Screens
- Login
- MFA challenge
- Unauthorized / forbidden page
- Profile
- Branch switcher
- Notifications tray

## 10.2 Executive Screens
- Executive dashboard
- AR aging dashboard
- Service SLA dashboard
- Sales performance dashboard
- Export center

## 10.3 Sales Screens
- Sales dashboard
- Customer list
- Customer details
- Booking list
- Booking details
- Create/Edit booking
- Payment entry
- Refund request
- Booking status history

## 10.4 Service Screens
- Service dashboard
- Appointment calendar/list
- Create appointment
- Work order list
- Work order detail
- Work order status timeline

## 10.5 Finance / Accounting Screens
- Payment verification queue
- Refund approval queue
- Invoice list
- AR aging report
- Journal review screen

## 10.6 HR Leave Screens
- Leave dashboard
- Leave request form
- My leave history
- Leave approvals queue
- Leave balance view
- Leave type admin

## 10.7 System Admin Screens
- User management
- Role assignment
- Branch setup
- Reference data management
- Audit event search
- System configuration

---

## 11. Navigation Map

### Main Navigation by Role

#### Director of Service
- Executive Dashboard
- Service SLA Dashboard
- AR Aging (view only if granted)

#### GM Service
- Executive Dashboard
- Service Dashboard
- Appointments
- Work Orders
- Leave Approvals

#### GM Sales
- Executive Dashboard
- Sales Dashboard
- Customers
- Bookings
- AR Aging

#### Accounting Manager
- Finance Dashboard
- Invoices
- AR Aging
- Journal Review
- Audit Search

#### Finance Manager
- Finance Dashboard
- Payment Verification
- Refund Approvals
- AR Aging
- Export Center

#### Sales Admin
- Sales Dashboard
- Customers
- Bookings
- Payments
- Leave

#### Service Manager
- Service Dashboard
- Appointments
- Work Orders
- Leave Approvals

#### Sales Manager
- Sales Dashboard
- Customers
- Bookings
- AR Aging
- Leave Approvals

#### System Admin
- Admin Console
- Users
- Roles
- Branches
- Reference Data
- Audit Logs

---

## 12. Deployment Blueprint V1

## 12.1 Stack Layout

### Containers / Services
- nginx
- webapp
- supabase kong
- supabase auth
- supabase rest
- supabase storage
- postgres
- supavisor
- minio
- backup job container
- optional monitoring containers (Prometheus/Grafana/Loki)

## 12.2 Environment Strategy
- `dev` = local developer setup
- `staging` = same single-server layout with test data
- `prod` = on-prem Ubuntu production

## 12.3 Deployment Directories
- `/srv/fookloi/app/`
- `/srv/fookloi/compose/`
- `/srv/fookloi/postgres/`
- `/srv/fookloi/minio/`
- `/srv/fookloi/backups/`
- `/srv/fookloi/nginx/`

## 12.4 Performance Rules for Target Hardware

1. Start with a modular monolith, not microservices.
2. Disable unnecessary Supabase services in MVP.
3. Use connection pooling.
4. Precompute dashboard aggregates.
5. Avoid excessive polling.
6. Keep large file uploads out of transactional tables.
7. Paginate all lists.
8. Add indexes before launch for hot filters.

## 12.5 Backup Policy
- nightly logical dump
- weekly full restore test in staging
- encrypted offsite copy if available
- attachment storage backup on schedule

## 12.6 Security Baseline
- HTTPS only
- VPN or private LAN access for internal admin endpoints
- MFA for privileged roles
- row-level security enabled
- encrypted disk / encrypted backup storage
- audit logs enabled
- secrets stored outside repo

---

## 13. Reporting and KPI Pack V1

## 13.1 Executive KPIs
- total bookings today / MTD
- booking-to-deposit verified median time
- expired reservations count
- payment verification backlog
- refund backlog and cycle time
- AR aging total by bucket
- work order backlog
- service SLA start compliance
- service SLA completion compliance

## 13.2 Dashboard Refresh Strategy
- operational widgets: near-real-time or short refresh interval
- heavy analytics: scheduled aggregates every 15 to 60 minutes
- AR aging snapshot: daily and on-demand refresh

---

## 14. Acceptance Criteria for Build Pack V1

This Build Pack is accepted when the team agrees that:

1. MVP scope is frozen.
2. RBAC roles and permissions are approved.
3. Core entities and schema layout are approved.
4. Status flow models are approved.
5. API surface is sufficient for first implementation sprint.
6. Screen map matches user expectations.
7. Deployment blueprint matches infrastructure reality.
8. First sprint backlog can begin without re-architecting.

---

## 15. Sprint 1 Backlog (Recommended)

## 15.1 Sprint 1 Goal
Prove the full vertical slice:
**Login → RBAC → Branch Scope → Customer → Booking → Payment → KPI Tile**

## 15.2 Sprint 1 Work Items

### Platform
- setup repo structure
- stand up Ubuntu staging stack
- configure self-hosted Supabase core services
- wire Nginx reverse proxy
- seed branches and role tables
- implement auth session flow
- implement user profile bootstrap

### Security
- define custom JWT claims
- implement RLS baseline for core and sales schemas
- add audit event middleware / trigger flow
- enforce MFA for privileged roles in staging

### Data
- create migration set v1 for core + sales minimal tables
- create indexes for booking list and customer search
- seed reference values

### Backend / API
- customer CRUD
- booking create / list / detail
- payment create
- payment verification endpoint
- executive KPI endpoint for bookings and deposits

### Frontend
- login screen
- shell layout with role-aware navigation
- customer list/detail screen
- booking create/detail screen
- payment entry screen
- executive KPI tile panel

### QA / Ops
- test branch isolation
- test role isolation
- test audit logging for payment verification
- measure p95 response time for list pages

## 15.3 Sprint 1 Exit Criteria
- user can log in
- user sees only permitted modules
- sales role can create customer and booking in allowed branch
- finance role can verify payment
- dashboard tile updates from source data
- unauthorized cross-branch access is blocked
- audit event exists for payment verification

---

## 16. Sprint 2 Backlog (Recommended)

- refund request + approval flow
- invoice records
- service appointment creation
- work order lifecycle
- service dashboard
- AR aging base query
- leave types and leave request workflow

---

## 17. Open Decisions Requiring Business Approval

1. Is customer data shared across branches or branch-owned with selective sharing?
2. Should GM roles have export rights by default?
3. Does Finance Manager or Accounting Manager own final refund processing authority?
4. Is quotation management part of V1 or V1.1?
5. Should leave approvals follow manager hierarchy only, or also HR/admin oversight?
6. Do service work orders need parts line items in V1, or only summary-level costing?
7. Will AR aging be invoice-based only, or also booking/deposit based where invoices are not yet finalized?

---

## 18. Recommended Immediate Next Step

After approving this Build Pack V1, produce these implementation artifacts in order:

1. SQL migration pack v1  
2. RLS policy pack v1  
3. Docker deployment pack v1  
4. Screen wireframe pack v1  
5. Sprint 1 technical task breakdown  
6. Seed data and role bootstrap script

---

## 19. Sign-Off Section

**Product:** ____________________  
**Engineering:** ____________________  
**Operations / Infra:** ____________________  
**Finance Representative:** ____________________  
**Service Representative:** ____________________  
**Sales Representative:** ____________________

