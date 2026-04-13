import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const hrPages = {
  'leave-requests': {
    title: 'Leave requests',
    description:
      'The leave request route is now scaffolded and ready for the first HR workflow implementation instead of returning a missing page.',
    backHref: '/hr',
    backLabel: 'Back to HR',
    nextSteps: [
      'Create a request list for employees and managers.',
      'Add a submission form with dates, leave types, and notes.',
      'Track balances and request statuses through the approval flow.',
    ],
    relatedLinks: [
      { href: '/hr', label: 'HR hub' },
      { href: '/hr/leave-approvals', label: 'Leave approvals route' },
    ],
  },
  'leave-approvals': {
    title: 'Leave approvals',
    description:
      'Approval screens are planned for HR Phase 1, and this route now acts as the development placeholder for manager review workflows.',
    backHref: '/hr',
    backLabel: 'Back to HR',
    nextSteps: [
      'Build a manager queue of pending leave approvals.',
      'Show employee balances, overlaps, and supporting notes.',
      'Add approve and reject actions with audit logging.',
    ],
    relatedLinks: [
      { href: '/hr', label: 'HR hub' },
      { href: '/hr/leave-requests', label: 'Leave requests route' },
    ],
  },
  dashboard: {
    title: 'HR dashboard',
    description:
      'This dashboard route is in place for leave utilization, approval backlog, and workforce summaries once HR workflows are implemented.',
    backHref: '/hr',
    backLabel: 'Back to HR',
    nextSteps: [
      'Define leave balance, absenteeism, and approval SLA metrics.',
      'Add summary cards for pending approvals and upcoming absences.',
      'Connect charts to aggregated HR queries or reporting views.',
    ],
    relatedLinks: [
      { href: '/dashboard', label: 'Main dashboard' },
      { href: '/hr/leave-requests', label: 'Leave requests route' },
    ],
  },
} as const

export default function HRFeaturePage({ params }: { params: { feature: string } }) {
  const page = hrPages[params.feature as keyof typeof hrPages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}