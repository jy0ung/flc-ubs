import Link from 'next/link'

export default function Inventory() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Inventory Management</h1>
          <p className="text-gray-600">Track products and stock levels</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Link
            href="/inventory/products"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Products</h3>
            <p className="text-gray-600">Manage product catalog and pricing</p>
          </Link>

          <Link
            href="/inventory/stock"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Stock Levels</h3>
            <p className="text-gray-600">View current inventory levels</p>
          </Link>

          <Link
            href="/inventory/adjustments"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Stock Adjustments</h3>
            <p className="text-gray-600">Record stock movements and adjustments</p>
          </Link>
        </div>
      </div>
    </div>
  )
}