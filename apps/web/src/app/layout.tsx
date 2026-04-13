import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: {
    default: 'FLC UBS — Fook Loi Unified Business Suite',
    template: '%s · FLC UBS',
  },
  description:
    'Unified dealer operations platform for sales, service, inventory, finance, HR, and branch management.',
  applicationName: 'FLC UBS',
  keywords: [
    'FLC UBS',
    'Fook Loi',
    'dealer management',
    'sales operations',
    'inventory management',
    'service operations',
    'ERP',
  ],
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}