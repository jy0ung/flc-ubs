import { notFound } from 'next/navigation'

import { FeaturePlaceholder } from '@/components/feature-placeholder'

const inventoryPages = {
  products: {
    title: 'Inventory products',
    description:
      'The product catalog route is now scaffolded so users can navigate into inventory product management without hitting a missing page.',
    backHref: '/inventory',
    backLabel: 'Back to inventory',
    nextSteps: [
      'Build a product list using inv.products with search and category filters.',
      'Add pricing, stock status, and branch-aware availability indicators.',
      'Create product maintenance forms and validations.',
    ],
    relatedLinks: [
      { href: '/inventory', label: 'Inventory hub' },
      { href: '/inventory/products/new', label: 'Create product scaffold' },
    ],
  },
  stock: {
    title: 'Inventory stock levels',
    description:
      'Stock visibility is part of the schema design, and this route is now in place for future branch-level inventory views.',
    backHref: '/inventory',
    backLabel: 'Back to inventory',
    nextSteps: [
      'Display branch stock levels with reorder and shortage indicators.',
      'Join products with stock_levels to produce operational tables.',
      'Add filters for branch, status, and low-stock thresholds.',
    ],
    relatedLinks: [
      { href: '/inventory', label: 'Inventory hub' },
      { href: '/inventory/adjustments', label: 'Adjustments route' },
    ],
  },
  adjustments: {
    title: 'Inventory adjustments',
    description:
      'Adjustment and movement pages are now scaffolded so the inventory module has a working navigation path for future stock control workflows.',
    backHref: '/inventory',
    backLabel: 'Back to inventory',
    nextSteps: [
      'Build an adjustment ledger with approval status and branch filters.',
      'Add create and approval actions aligned with the RLS policy pack.',
      'Expose stock movement history for auditability.',
    ],
    relatedLinks: [
      { href: '/inventory', label: 'Inventory hub' },
      { href: '/inventory/stock', label: 'Stock levels route' },
    ],
  },
} as const

export default function InventoryFeaturePage({ params }: { params: { feature: string } }) {
  const page = inventoryPages[params.feature as keyof typeof inventoryPages]

  if (!page) {
    notFound()
  }

  return <FeaturePlaceholder {...page} />
}