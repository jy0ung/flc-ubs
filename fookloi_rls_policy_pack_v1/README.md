# Fook Loi Unified Business Suite - RLS Policy Pack V1

This pack adds **Row Level Security (RLS)**, helper functions, grants, and policy definitions for the SQL Migration Pack V1.

## Files

- `000_grants_and_helpers.sql`
- `001_core_rls.sql`
- `002_sales_rls.sql`
- `003_service_rls.sql`
- `004_accounting_rls.sql`
- `005_hr_rls.sql`
- `006_audit_analytics_rls.sql`
- `999_full_pack.sql`

## Intended order

Apply in numeric order **after** the base SQL migration pack.

## Assumptions

- The base SQL migration pack V1 has already been applied.
- The deployment target is **self-hosted Supabase/PostgreSQL**.
- App users connect as `authenticated`; backend jobs may use `service_role`.
- `auth.users` and `auth.uid()` are available through Supabase.
- `core.user_branch_access` is the source of truth for branch/role membership.
- The app uses backend-generated signed URLs or trusted backend flows for file delivery. This pack secures `core.attachments` metadata, but does not add `storage.objects` bucket policies.

## Notes

- `service_role` bypasses RLS in Supabase and remains suitable for server-side jobs, snapshot refreshes, and ETL-style tasks.
- The analytics views are marked `security_invoker = true` so they respect the caller's RLS context instead of bypassing it.
- This pack intentionally favors **clear branch-based rules** over overly dynamic policy logic.
- Column-level restrictions are **not** enforced here; the application and RPC layer should still guard sensitive field updates.

## Recommended next step

After applying this pack, create and apply:

1. `seed bootstrap script`
2. `dashboard aggregation jobs`
3. `environment hardening checklist`
