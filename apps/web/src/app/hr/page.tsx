import Link from 'next/link'

export default function HR() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">HR Management</h1>
          <p className="text-gray-600">Manage leave requests and approvals</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <Link
            href="/hr/leave-requests"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Leave Requests</h3>
            <p className="text-gray-600">Submit and manage leave requests</p>
          </Link>

          <Link
            href="/hr/leave-approvals"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Leave Approvals</h3>
            <p className="text-gray-600">Approve or reject leave requests</p>
          </Link>

          <Link
            href="/hr/dashboard"
            className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold text-gray-900 mb-2">HR Dashboard</h3>
            <p className="text-gray-600">View leave balances and reports</p>
          </Link>
        </div>
      </div>
    </div>
  )
}