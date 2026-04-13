import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const createPages = {
  customers: {
    title: 'Create customer',
    description:
      'The customer creation route exists now, making the sales workflow navigable while the actual form and validation logic are being developed.',
    backHref: '/sales/customers',
    backLabel: 'Back to customers',
    nextSteps: [
      'Build the customer form using the sales.customers schema fields.',
      'Add validation for customer code, contact data, and branch assignment.',
      'Submit records to Supabase and return users to the customer list with feedback.',
    ],
    relatedLinks: [
      { href: '/sales/customers', label: 'Customers list' },
      { href: '/sales', label: 'Sales hub' },
    ],
  },
  bookings: {
    title: 'Create booking',
    description:
      'This scaffold page marks the entry point for building a real booking creation flow connected to the booking, reservation, and payment tables.',
    backHref: '/sales/bookings',
    backLabel: 'Back to bookings',
    nextSteps: [
      'Capture customer, branch, model, and pricing inputs.',
      'Support draft and confirmed booking states from the first version.',
      'Generate booking numbers and write activity to status events.',
    ],
    relatedLinks: [
      { href: '/sales/bookings', label: 'Bookings route' },
      { href: '/sales/customers', label: 'Customers list' },
    ],
  },
} as const

export default function SalesCreatePage({ params }: { params: { feature: string } }) {
  const page = createPages[params.feature as keyof typeof createPages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}