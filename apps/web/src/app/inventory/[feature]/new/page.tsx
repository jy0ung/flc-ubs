import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const createPages = {
  products: {
    title: 'Create product',
    description:
      'This route is ready for the first real product maintenance form tied to the inventory product schema.',
    backHref: '/inventory/products',
    backLabel: 'Back to products',
    nextSteps: [
      'Add fields for SKU, naming, pricing, and stock status.',
      'Support branch availability defaults and product categorization.',
      'Save product data to Supabase and refresh the product list.',
    ],
    relatedLinks: [
      { href: '/inventory/products', label: 'Products route' },
      { href: '/inventory', label: 'Inventory hub' },
    ],
  },
} as const

export default function InventoryCreatePage({ params }: { params: { feature: string } }) {
  const page = createPages[params.feature as keyof typeof createPages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}