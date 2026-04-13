import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const servicePages = {
  appointments: {
    title: 'Service appointments',
    description:
      'Appointment scheduling is planned in the service module, and this route now provides a proper scaffold instead of a 404.',
    backHref: '/service',
    backLabel: 'Back to service',
    nextSteps: [
      'Build an appointment board with daily and branch views.',
      'Create an appointment form for customer, vehicle, and time-slot data.',
      'Link appointments to downstream work orders and technician assignment.',
    ],
    relatedLinks: [
      { href: '/service', label: 'Service hub' },
      { href: '/service/appointments/new', label: 'Schedule appointment scaffold' },
    ],
  },
  'work-orders': {
    title: 'Service work orders',
    description:
      'Work order tracking is part of the MVP scope, but the page implementation still needs operational lists, statuses, and action flows.',
    backHref: '/service',
    backLabel: 'Back to service',
    nextSteps: [
      'Create a work-order queue grouped by status and priority.',
      'Add technician assignment, labour lines, and parts usage sections.',
      'Track service progress updates and completion timestamps.',
    ],
    relatedLinks: [
      { href: '/service', label: 'Service hub' },
      { href: '/inventory', label: 'Inventory module' },
    ],
  },
  dashboard: {
    title: 'Service dashboard',
    description:
      'This route is now ready for backlog, turnaround time, and technician utilization reporting once the first service features are implemented.',
    backHref: '/service',
    backLabel: 'Back to service',
    nextSteps: [
      'Define backlog, SLA, and throughput metrics for service operations.',
      'Create summary cards and trend charts for pending and completed work.',
      'Add drilldowns by branch, technician, and work-order status.',
    ],
    relatedLinks: [
      { href: '/dashboard', label: 'Main dashboard' },
      { href: '/service/appointments', label: 'Appointments route' },
    ],
  },
} as const

export default function ServiceFeaturePage({ params }: { params: { feature: string } }) {
  const page = servicePages[params.feature as keyof typeof servicePages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}