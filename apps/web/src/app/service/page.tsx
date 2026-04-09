import Link from 'next/link'

export default function Service() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Service Management</h1>
          <p className="text-gray-600">Handle appointments and work orders</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Link
            href="/service/appointments"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Appointments</h3>
            <p className="text-gray-600">Schedule and manage service appointments</p>
          </Link>

          <Link
            href="/service/work-orders"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Work Orders</h3>
            <p className="text-gray-600">Track service work orders and status</p>
          </Link>

          <Link
            href="/service/dashboard"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Service Dashboard</h3>
            <p className="text-gray-600">View service performance and backlog</p>
          </Link>
        </div>
      </div>
    </div>
  )
}