import Link from 'next/link'

export default function Sales() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Sales Management</h1>
          <p className="text-gray-600">Manage customers, bookings, and payments</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Link
            href="/sales/customers"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Customers</h3>
            <p className="text-gray-600">Manage customer records and contacts</p>
          </Link>

          <Link
            href="/sales/bookings"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Bookings</h3>
            <p className="text-gray-600">Handle reservations and quotations</p>
          </Link>

          <Link
            href="/sales/payments"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Payments</h3>
            <p className="text-gray-600">Process payments and refunds</p>
          </Link>

          <Link
            href="/sales/dashboard"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Sales Dashboard</h3>
            <p className="text-gray-600">View sales performance and metrics</p>
          </Link>
        </div>
      </div>
    </div>
  )
}