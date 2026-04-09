import { createClient } from '@/lib/supabase-server'
import { redirect } from 'next/navigation'

export default async function Dashboard() {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect('/auth/login')
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600">Welcome back, {user.email}</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900">Sales Today</h3>
            <p className="text-3xl font-bold text-green-600">RM 0</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900">Active Bookings</h3>
            <p className="text-3xl font-bold text-blue-600">0</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900">Service Orders</h3>
            <p className="text-3xl font-bold text-orange-600">0</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900">Pending Approvals</h3>
            <p className="text-3xl font-bold text-red-600">0</p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
            <div className="space-y-2">
              <a href="/sales/customers/new" className="block w-full text-left px-4 py-2 bg-blue-50 hover:bg-blue-100 rounded">
                Add New Customer
              </a>
              <a href="/sales/bookings/new" className="block w-full text-left px-4 py-2 bg-blue-50 hover:bg-blue-100 rounded">
                Create Booking
              </a>
              <a href="/service/appointments/new" className="block w-full text-left px-4 py-2 bg-blue-50 hover:bg-blue-100 rounded">
                Schedule Service
              </a>
              <a href="/inventory/products/new" className="block w-full text-left px-4 py-2 bg-blue-50 hover:bg-blue-100 rounded">
                Add Product
              </a>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
            <div className="text-gray-500 text-center py-8">
              No recent activity
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}