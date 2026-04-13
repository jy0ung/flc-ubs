import { FeaturePlaceholder } from '@/components/feature-placeholder'

export default function CustomerDetailPage({ params }: { params: { id: string } }) {
  return (
    <FeaturePlaceholder
      title="Customer record"
      description={`Customer detail page scaffold for record ID ${params.id}. This route now resolves correctly and is ready for profile, contact history, and booking timeline development.`}
      backHref="/sales/customers"
      backLabel="Back to customers"
      nextSteps={[
        'Fetch and display the customer profile plus related contacts.',
        'Show linked bookings, payments, and communication history.',
        'Add edit actions with audit-friendly change tracking.',
      ]}
      relatedLinks={[
        { href: '/sales/customers', label: 'Customers list' },
        { href: '/sales/customers/new', label: 'Create customer scaffold' },
      ]}
    />
  )
}