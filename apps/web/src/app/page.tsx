import Link from 'next/link'

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Fook Loi Unified Business Suite
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Modern business management for Fook Loi Corporation
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
          <Link
            href="/auth/login"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Login</h3>
            <p className="text-gray-600">Access your business management dashboard</p>
          </Link>

          <Link
            href="/dashboard"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Dashboard</h3>
            <p className="text-gray-600">View business operations and analytics</p>
          </Link>

          <Link
            href="/sales"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Sales</h3>
            <p className="text-gray-600">Manage customers, bookings, and payments</p>
          </Link>

          <Link
            href="/service"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Service</h3>
            <p className="text-gray-600">Handle appointments and work orders</p>
          </Link>

          <Link
            href="/finance"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Finance</h3>
            <p className="text-gray-600">Process invoices and manage payments</p>
          </Link>

          <Link
            href="/inventory"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Inventory</h3>
            <p className="text-gray-600">Track products and stock levels</p>
          </Link>

          <Link
            href="/hr"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">HR</h3>
            <p className="text-gray-600">Manage leave requests and approvals</p>
          </Link>

          <Link
            href="/admin"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Admin</h3>
            <p className="text-gray-600">System administration and settings</p>
          </Link>

          <Link
            href="/analytics"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Analytics</h3>
            <p className="text-gray-600">Executive dashboards and reporting</p>
          </Link>
        </div>
      </div>
    </main>
  )
}