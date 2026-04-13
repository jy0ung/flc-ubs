import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const salesPages = {
  bookings: {
    title: 'Sales bookings',
    description:
      'The bookings workflow is linked from the sales hub, but the actual reservation and quotation screens have not been implemented yet.',
    backHref: '/sales',
    backLabel: 'Back to sales',
    nextSteps: [
      'Build a booking list with filters for status, branch, and sales owner.',
      'Add a create-booking form that maps to the sales.bookings schema.',
      'Surface related payments, reservations, and booking status history.',
    ],
    relatedLinks: [
      { href: '/sales', label: 'Sales hub' },
      { href: '/sales/bookings/new', label: 'Create booking scaffold' },
      { href: '/sales/customers', label: 'Customers list' },
    ],
  },
  payments: {
    title: 'Sales payments',
    description:
      'Payment intake and refund verification are defined in the schema, but the UI screens for daily finance operations still need to be built.',
    backHref: '/sales',
    backLabel: 'Back to sales',
    nextSteps: [
      'Create a payment ledger view with booking and verification details.',
      'Add payment capture forms with validation for amount, method, and reference number.',
      'Connect refund requests and approval statuses to the finance workflow.',
    ],
    relatedLinks: [
      { href: '/sales', label: 'Sales hub' },
      { href: '/finance', label: 'Finance module' },
    ],
  },
  dashboard: {
    title: 'Sales dashboard',
    description:
      'This dashboard route is now available for development and can be used to host sales KPIs, funnel metrics, and booking conversion summaries.',
    backHref: '/sales',
    backLabel: 'Back to sales',
    nextSteps: [
      'Define the first set of sales KPIs and branch-level drilldowns.',
      'Pull aggregate metrics from bookings, payments, and customer activity.',
      'Add visualizations for quotation-to-booking conversion and pending deposits.',
    ],
    relatedLinks: [
      { href: '/dashboard', label: 'Main dashboard' },
      { href: '/sales/customers', label: 'Customers list' },
    ],
  },
} as const

export default function SalesFeaturePage({ params }: { params: { feature: string } }) {
  const page = salesPages[params.feature as keyof typeof salesPages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}