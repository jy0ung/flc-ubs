# FLC UBS Web Application

Next.js 14 web application for the Fook Loi Unified Business Suite.

## Features

- **Authentication**: Supabase-based user authentication
- **Sales Management**: Customer management, bookings, payments
- **Service Management**: Appointments and work orders
- **Inventory Management**: Product catalog and stock tracking
- **HR Management**: Leave requests and approvals
- **Dashboard**: Executive overview and analytics

## Tech Stack

- **Framework**: Next.js 14 with App Router
- **Styling**: Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Auth)
- **Language**: TypeScript
- **Icons**: Lucide React

## Getting Started

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Configure environment**:
   Copy `.env.example` to `.env.local` and fill in your Supabase credentials.

3. **Run development server**:
   ```bash
   npm run dev
   ```

4. **Build for production**:
   ```bash
   npm run build
   npm start
   ```

## Project Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── auth/              # Authentication pages
│   ├── dashboard/         # Main dashboard
│   ├── sales/             # Sales management
│   ├── service/           # Service management
│   ├── inventory/         # Inventory management
│   ├── hr/                # HR management
│   ├── layout.tsx         # Root layout
│   ├── page.tsx           # Home page
│   └── globals.css        # Global styles
├── lib/                   # Utility libraries
│   ├── supabase.ts        # Client-side Supabase client
│   └── supabase-server.ts # Server-side Supabase client
└── middleware.ts          # Authentication middleware
```

## Database Setup

Before running the application, ensure you have:

1. Applied the SQL migration pack (`fookloi_sql_migration_pack_v1/`)
2. Applied the RLS policy pack (`fookloi_rls_policy_pack_v1/`)
3. Configured Supabase with the correct URL and keys

## Development Notes

- Uses Row Level Security (RLS) for data access control
- Branch-based data isolation
- JWT-based role authentication
- Responsive design with Tailwind CSS