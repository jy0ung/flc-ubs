import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const modulePages = {
  finance: {
    title: 'Finance module workspace',
    description:
      'This area is scaffolded for invoicing, receivables, payment verification, and finance operations, but the feature pages still need to be implemented.',
    backHref: '/',
    backLabel: 'Back to home',
    nextSteps: [
      'Build invoice and accounts receivable list pages backed by the sales and accounting schema.',
      'Add finance KPI cards using real aggregates instead of placeholder values.',
      'Implement approval and reconciliation workflows for payments and refunds.',
    ],
    relatedLinks: [
      { href: '/dashboard', label: 'Open dashboard' },
      { href: '/sales', label: 'Open sales module' },
    ],
  },
  admin: {
    title: 'Admin workspace',
    description:
      'System administration, branch setup, user management, and configuration screens have not been built yet, so this route now provides a development-safe entry point.',
    backHref: '/',
    backLabel: 'Back to home',
    nextSteps: [
      'Add branch, role, and user management screens with Supabase-backed CRUD flows.',
      'Expose system settings and audit views required by operations managers.',
      'Add role-based navigation rules so only privileged users can reach admin screens.',
    ],
    relatedLinks: [
      { href: '/dashboard', label: 'Open dashboard' },
      { href: '/analytics', label: 'Open analytics module' },
    ],
  },
  analytics: {
    title: 'Analytics workspace',
    description:
      'Executive dashboards and reporting routes are planned, but this module is still at the scaffold stage and needs reporting views plus live metrics.',
    backHref: '/',
    backLabel: 'Back to home',
    nextSteps: [
      'Define the first KPI set for sales, service, inventory, and HR.',
      'Create reusable chart and summary card components for reporting.',
      'Connect analytics views to aggregated SQL functions or reporting endpoints.',
    ],
    relatedLinks: [
      { href: '/dashboard', label: 'Open dashboard' },
      { href: '/finance', label: 'Open finance module' },
    ],
  },
} as const

export default function ModulePage({ params }: { params: { module: string } }) {
  const page = modulePages[params.module as keyof typeof modulePages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}