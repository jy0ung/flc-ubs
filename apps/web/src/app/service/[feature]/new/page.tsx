import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const createPages = {
  appointments: {
    title: 'Schedule service appointment',
    description:
      'This route is prepared for the first appointment booking form so service staff can create new appointments without hitting missing pages.',
    backHref: '/service/appointments',
    backLabel: 'Back to appointments',
    nextSteps: [
      'Build form sections for customer, unit, service type, and requested time.',
      'Validate appointment availability before submit.',
      'Route successful creations into the work-order pipeline.',
    ],
    relatedLinks: [
      { href: '/service/appointments', label: 'Appointments route' },
      { href: '/service', label: 'Service hub' },
    ],
  },
} as const

export default function ServiceCreatePage({ params }: { params: { feature: string } }) {
  const page = createPages[params.feature as keyof typeof createPages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}