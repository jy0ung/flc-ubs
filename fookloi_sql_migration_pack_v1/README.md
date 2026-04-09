# Fook Loi Unified Business Suite - SQL Migration Pack V1

This pack is designed for a self-hosted Supabase / PostgreSQL deployment.

## Files

- `000_extensions_and_schemas.sql`
- `001_core_tables.sql`
- `002_sales_tables.sql`
- `003_service_tables.sql`
- `004_accounting_tables.sql`
- `005_hr_tables.sql`
- `006_audit_and_analytics.sql`
- `007_indexes.sql`
- `008_functions_and_triggers.sql`
- `009_seed_baseline.sql`
- `999_full_pack.sql`

## Intended order

Apply in numeric order.

## Notes

- This pack assumes Supabase auth users live in `auth.users`.
- This pack creates schema, tables, helper functions, views, indexes, and baseline seed data.
- This pack does **not** include RLS policies yet. RLS should be applied in a separate `RLS policy pack v1`.
- All timestamps use `timestamptz`.
- UUID primary keys default to `gen_random_uuid()`.
- Amount fields use `numeric(14,2)` unless otherwise stated.
- File attachments are stored via Supabase Storage / object storage, with metadata tracked in `core.attachments`.

## Recommended next step

After applying this pack, create and apply:

1. `RLS policy pack v1`
2. `seed bootstrap script`
3. `dashboard aggregation jobs`

