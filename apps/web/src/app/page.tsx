import type { Route } from 'next'
import Link from 'next/link'
import {
  ArrowRight,
  BarChart3,
  Boxes,
  BriefcaseBusiness,
  CheckCircle2,
  CreditCard,
  Database,
  LayoutDashboard,
  type LucideIcon,
  ShieldCheck,
  Sparkles,
  Users,
  Wrench,
} from 'lucide-react'

type ModuleItem = {
  href: string
  title: string
  description: string
  status: string
  icon: LucideIcon
  panelClass: string
  iconClass: string
}

type PrincipleItem = {
  title: string
  description: string
  icon: LucideIcon
}

const moduleItems: readonly ModuleItem[] = [
  {
    href: '/dashboard',
    title: 'Executive dashboard',
    description: 'A command center for KPI visibility, alerts, and quick actions across the business.',
    status: 'Protected route ready',
    icon: LayoutDashboard,
    panelClass: 'border-blue-200 bg-blue-50/70 hover:border-blue-300 hover:bg-blue-50',
    iconClass: 'bg-blue-600/10 text-blue-700',
  },
  {
    href: '/sales',
    title: 'Sales operations',
    description: 'Customer, booking, and payment workflows designed for showroom and branch execution.',
    status: 'Scaffolded and navigable',
    icon: BriefcaseBusiness,
    panelClass: 'border-cyan-200 bg-cyan-50/70 hover:border-cyan-300 hover:bg-cyan-50',
    iconClass: 'bg-cyan-600/10 text-cyan-700',
  },
  {
    href: '/service',
    title: 'Service management',
    description: 'Appointment scheduling, work-order execution, and operational service tracking.',
    status: 'Workflow placeholders added',
    icon: Wrench,
    panelClass: 'border-violet-200 bg-violet-50/70 hover:border-violet-300 hover:bg-violet-50',
    iconClass: 'bg-violet-600/10 text-violet-700',
  },
  {
    href: '/finance',
    title: 'Finance controls',
    description: 'Invoice, payment verification, receivables, and operational finance workspace.',
    status: 'Ready for feature buildout',
    icon: CreditCard,
    panelClass: 'border-amber-200 bg-amber-50/80 hover:border-amber-300 hover:bg-amber-50',
    iconClass: 'bg-amber-500/15 text-amber-700',
  },
  {
    href: '/inventory',
    title: 'Inventory visibility',
    description: 'Product catalog, stock movements, and branch-level inventory control experience.',
    status: 'Inventory routes connected',
    icon: Boxes,
    panelClass: 'border-emerald-200 bg-emerald-50/70 hover:border-emerald-300 hover:bg-emerald-50',
    iconClass: 'bg-emerald-600/10 text-emerald-700',
  },
  {
    href: '/hr',
    title: 'HR workflows',
    description: 'Leave requests, approvals, and future workforce reporting built for branch operations.',
    status: 'Phase 1 workflow prepared',
    icon: Users,
    panelClass: 'border-rose-200 bg-rose-50/70 hover:border-rose-300 hover:bg-rose-50',
    iconClass: 'bg-rose-600/10 text-rose-700',
  },
  {
    href: '/analytics',
    title: 'Analytics workspace',
    description: 'A home for executive dashboards, trend reporting, and cross-functional visibility.',
    status: 'Placeholder route available',
    icon: BarChart3,
    panelClass: 'border-indigo-200 bg-indigo-50/70 hover:border-indigo-300 hover:bg-indigo-50',
    iconClass: 'bg-indigo-600/10 text-indigo-700',
  },
  {
    href: '/admin',
    title: 'Admin controls',
    description: 'User, branch, and system configuration surfaces for secure operational governance.',
    status: 'Admin shell ready',
    icon: ShieldCheck,
    panelClass: 'border-slate-200 bg-slate-100/80 hover:border-slate-300 hover:bg-slate-100',
    iconClass: 'bg-slate-700/10 text-slate-700',
  },
]

const principles: readonly PrincipleItem[] = [
  {
    title: 'Operational clarity first',
    description: 'The landing experience now prioritizes clear entry points, module status, and next actions instead of a generic link grid.',
    icon: Sparkles,
  },
  {
    title: 'Enterprise but approachable',
    description: 'A more polished visual hierarchy, stronger spacing, and better card states make the platform feel product-ready earlier.',
    icon: CheckCircle2,
  },
  {
    title: 'Built around the real platform',
    description: 'The UI communicates the actual stack and delivery stage: Next.js, Supabase, RLS, modular monolith, and branch-aware workflows.',
    icon: Database,
  },
]

const deliveryStats = [
  { label: 'Modules mapped', value: '8', note: 'Across sales, service, finance, inventory, HR, analytics, admin, and dashboard' },
  { label: 'Security model', value: 'RLS', note: 'Branch-based access model scaffolded in the database layer' },
  { label: 'Deployment target', value: 'Ubuntu', note: 'Designed for self-hosted Supabase and on-prem operations' },
]

const roadmap = [
  'Turn the sales and inventory flows from placeholder pages into real CRUD screens.',
  'Introduce shared design primitives for cards, forms, tables, and data states.',
  'Add live business metrics so the dashboard and landing page reflect real operational data.',
]

function SectionHeading({
  eyebrow,
  title,
  description,
}: {
  eyebrow: string
  title: string
  description: string
}) {
  return (
    <div className="max-w-3xl">
      <p className="text-sm font-semibold uppercase tracking-[0.28em] text-blue-600">{eyebrow}</p>
      <h2 className="mt-3 text-3xl font-bold tracking-tight text-slate-900 sm:text-4xl">{title}</h2>
      <p className="mt-4 text-lg leading-8 text-slate-600">{description}</p>
    </div>
  )
}

export default function Home() {
  return (
    <main className="relative overflow-hidden bg-slate-950 text-slate-100">
      <div className="absolute inset-0">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,_rgba(59,130,246,0.24),_transparent_34%),radial-gradient(circle_at_top_right,_rgba(245,158,11,0.16),_transparent_22%),linear-gradient(180deg,_#020617_0%,_#0f172a_44%,_#f8fafc_44%,_#f8fafc_100%)]" />
        <div className="absolute inset-x-0 top-0 h-[34rem] bg-[linear-gradient(rgba(148,163,184,0.14)_1px,transparent_1px),linear-gradient(90deg,rgba(148,163,184,0.14)_1px,transparent_1px)] bg-[size:36px_36px] [mask-image:linear-gradient(to_bottom,rgba(255,255,255,0.7),transparent)]" />
      </div>

      <div className="relative">
        <header className="mx-auto flex max-w-7xl items-center justify-between px-4 py-6 sm:px-6 lg:px-8">
          <Link href="/" className="flex items-center gap-3 text-white">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl border border-white/15 bg-white/10 text-sm font-bold shadow-lg shadow-blue-950/30 backdrop-blur">
              FLC
            </div>
            <div>
              <p className="text-sm font-semibold uppercase tracking-[0.24em] text-blue-200">Unified Business Suite</p>
              <p className="text-xs text-slate-400">Dealer operations platform</p>
            </div>
          </Link>

          <nav className="hidden items-center gap-8 text-sm text-slate-300 md:flex">
            <a href="#modules" className="hover:text-white">Modules</a>
            <a href="#experience" className="hover:text-white">Experience</a>
            <a href="#roadmap" className="hover:text-white">Roadmap</a>
          </nav>

          <Link
            href="/auth/login"
            className="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/10 px-4 py-2 text-sm font-medium text-white backdrop-blur transition hover:border-white/25 hover:bg-white/15"
          >
            Sign in
            <ArrowRight className="h-4 w-4" />
          </Link>
        </header>

        <section className="mx-auto max-w-7xl px-4 pb-20 pt-6 sm:px-6 lg:px-8 lg:pb-28 lg:pt-12">
          <div className="grid gap-12 lg:grid-cols-[1.08fr_0.92fr] lg:items-center">
            <div>
              <div className="inline-flex items-center gap-2 rounded-full border border-blue-400/20 bg-blue-400/10 px-4 py-2 text-sm font-medium text-blue-100 shadow-lg shadow-blue-950/20 backdrop-blur">
                <Sparkles className="h-4 w-4" />
                MVP foundation ready for UI and feature delivery
              </div>

              <h1 className="mt-8 max-w-4xl text-5xl font-bold tracking-tight text-white sm:text-6xl lg:text-7xl">
                One operating system for sales, service, inventory, finance, and branch execution.
              </h1>

              <p className="mt-6 max-w-3xl text-lg leading-8 text-slate-300 sm:text-xl">
                FLC UBS is evolving from scaffold to product. The landing page now sets a clearer first impression, exposes the real platform structure, and guides teams into the next modules to build.
              </p>

              <div className="mt-8 flex flex-wrap gap-4">
                <Link
                  href="/auth/login"
                  className="inline-flex items-center gap-2 rounded-full bg-white px-6 py-3 text-sm font-semibold text-slate-950 shadow-xl shadow-slate-950/20 transition hover:bg-slate-100"
                >
                  Open login
                  <ArrowRight className="h-4 w-4" />
                </Link>

                <a
                  href="#modules"
                  className="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/5 px-6 py-3 text-sm font-semibold text-white backdrop-blur transition hover:border-white/25 hover:bg-white/10"
                >
                  Explore modules
                </a>
              </div>

              <div className="mt-10 grid gap-4 sm:grid-cols-3">
                {deliveryStats.map((item) => (
                  <div
                    key={item.label}
                    className="rounded-2xl border border-white/10 bg-white/5 p-5 shadow-lg shadow-slate-950/20 backdrop-blur"
                  >
                    <p className="text-sm font-medium text-slate-400">{item.label}</p>
                    <p className="mt-2 text-3xl font-bold text-white">{item.value}</p>
                    <p className="mt-3 text-sm leading-6 text-slate-300">{item.note}</p>
                  </div>
                ))}
              </div>
            </div>

            <div className="relative">
              <div className="absolute -left-10 top-10 h-28 w-28 rounded-full bg-blue-500/20 blur-3xl" />
              <div className="absolute -right-6 bottom-6 h-28 w-28 rounded-full bg-amber-400/20 blur-3xl" />

              <div className="relative overflow-hidden rounded-[2rem] border border-white/10 bg-white/10 p-7 shadow-2xl shadow-slate-950/40 backdrop-blur-xl">
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <p className="text-sm font-semibold uppercase tracking-[0.24em] text-blue-200">Platform snapshot</p>
                    <h2 className="mt-3 text-2xl font-bold text-white">A clearer product story for internal stakeholders</h2>
                  </div>
                  <div className="rounded-2xl border border-emerald-400/20 bg-emerald-400/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-emerald-200">
                    In progress
                  </div>
                </div>

                <div className="mt-8 grid gap-4 sm:grid-cols-2">
                  <div className="rounded-2xl border border-white/10 bg-slate-950/30 p-5">
                    <p className="text-sm font-medium text-slate-400">Foundation status</p>
                    <p className="mt-2 text-2xl font-semibold text-white">Scaffold complete</p>
                    <p className="mt-3 text-sm leading-6 text-slate-300">
                      Next.js app, SQL packs, RLS policies, and module routing are in place for rapid iteration.
                    </p>
                  </div>

                  <div className="rounded-2xl border border-white/10 bg-slate-950/30 p-5">
                    <p className="text-sm font-medium text-slate-400">UI direction</p>
                    <p className="mt-2 text-2xl font-semibold text-white">Enterprise-ready</p>
                    <p className="mt-3 text-sm leading-6 text-slate-300">
                      The interface is shifting from raw scaffolding into a structured, polished product shell.
                    </p>
                  </div>
                </div>

                <div className="mt-6 rounded-2xl border border-white/10 bg-slate-950/30 p-6">
                  <div className="flex items-center gap-3">
                    <ShieldCheck className="h-5 w-5 text-blue-200" />
                    <p className="font-semibold text-white">What this landing page now communicates</p>
                  </div>

                  <ul className="mt-5 space-y-4 text-sm leading-6 text-slate-300">
                    <li className="flex gap-3">
                      <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-emerald-300" />
                      Clear entry points for each business module.
                    </li>
                    <li className="flex gap-3">
                      <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-emerald-300" />
                      Better hierarchy for product messaging and current delivery stage.
                    </li>
                    <li className="flex gap-3">
                      <CheckCircle2 className="mt-0.5 h-5 w-5 shrink-0 text-emerald-300" />
                      A reusable foundation for future design-system work.
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="modules" className="border-t border-slate-200/80 bg-slate-50 py-20 text-slate-900">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <SectionHeading
              eyebrow="Module navigation"
              title="A much stronger first-screen experience for navigating the suite"
              description="Instead of a plain list of links, the landing page now frames each module as part of one operating platform, with clearer status messaging and better visual affordance."
            />

            <div className="mt-12 grid gap-5 md:grid-cols-2 xl:grid-cols-4">
              {moduleItems.map((module) => {
                const Icon = module.icon

                return (
                  <Link
                    key={module.title}
                    href={module.href as Route}
                    className={`group flex h-full flex-col rounded-[1.75rem] border p-6 shadow-sm transition duration-300 hover:-translate-y-1 hover:shadow-xl ${module.panelClass}`}
                  >
                    <div className="flex items-start justify-between gap-4">
                      <div className={`flex h-12 w-12 items-center justify-center rounded-2xl ${module.iconClass}`}>
                        <Icon className="h-6 w-6" />
                      </div>
                      <span className="rounded-full bg-white/80 px-3 py-1 text-xs font-medium text-slate-600">
                        {module.status}
                      </span>
                    </div>

                    <div className="mt-6 flex flex-1 flex-col">
                      <h3 className="text-xl font-semibold text-slate-900">{module.title}</h3>
                      <p className="mt-3 flex-1 text-sm leading-6 text-slate-600">{module.description}</p>

                      <div className="mt-6 inline-flex items-center gap-2 text-sm font-semibold text-slate-900">
                        Open module
                        <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                      </div>
                    </div>
                  </Link>
                )
              })}
            </div>
          </div>
        </section>

        <section id="experience" className="border-t border-slate-200 bg-white py-20 text-slate-900">
          <div className="mx-auto grid max-w-7xl gap-12 px-4 sm:px-6 lg:grid-cols-[1fr_1.05fr] lg:px-8">
            <div>
              <SectionHeading
                eyebrow="UI / UX direction"
                title="Designing for confidence, structure, and faster decision-making"
                description="This first pass sets the tone for the rest of the product: cleaner hierarchy, stronger messaging, clearer navigation, and more product-like presentation for stakeholders and internal users."
              />

              <div className="mt-8 rounded-[1.75rem] border border-slate-200 bg-slate-50 p-6 shadow-sm">
                <div className="flex items-center gap-3">
                  <Database className="h-5 w-5 text-blue-600" />
                  <p className="font-semibold text-slate-900">Platform DNA</p>
                </div>
                <p className="mt-4 text-sm leading-7 text-slate-600">
                  FLC UBS is positioned as an operational ERP-style system for dealer workflows. The landing page should feel trustworthy, structured, and purposeful — not like an internal prototype.
                </p>
              </div>
            </div>

            <div className="grid gap-5">
              {principles.map((item) => {
                const Icon = item.icon

                return (
                  <div
                    key={item.title}
                    className="rounded-[1.75rem] border border-slate-200 bg-slate-50 p-6 shadow-sm transition hover:border-blue-200 hover:shadow-md"
                  >
                    <div className="flex items-start gap-4">
                      <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-600/10 text-blue-700">
                        <Icon className="h-6 w-6" />
                      </div>
                      <div>
                        <h3 className="text-lg font-semibold text-slate-900">{item.title}</h3>
                        <p className="mt-2 text-sm leading-6 text-slate-600">{item.description}</p>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        </section>

        <section id="roadmap" className="border-t border-slate-200 bg-slate-50 py-20 text-slate-900">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <SectionHeading
              eyebrow="Next design moves"
              title="Where the landing page work should lead next"
              description="This is the first UI/UX upgrade. The next iterations should turn this styling direction into reusable product patterns that scale across operational modules."
            />

            <div className="mt-12 grid gap-5 lg:grid-cols-3">
              {roadmap.map((item, index) => (
                <div key={item} className="rounded-[1.75rem] border border-slate-200 bg-white p-6 shadow-sm">
                  <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-900 text-sm font-bold text-white">
                    0{index + 1}
                  </div>
                  <p className="mt-5 text-base leading-7 text-slate-700">{item}</p>
                </div>
              ))}
            </div>

            <div className="mt-12 flex flex-wrap items-center justify-between gap-4 rounded-[1.75rem] border border-blue-200 bg-blue-50 px-6 py-5">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.24em] text-blue-700">Current focus</p>
                <p className="mt-2 text-lg font-semibold text-slate-900">Landing page upgraded. Next step: build shared UI primitives and the first real sales workflows.</p>
              </div>

              <Link
                href="/sales"
                className="inline-flex items-center gap-2 rounded-full bg-slate-900 px-5 py-3 text-sm font-semibold text-white transition hover:bg-slate-800"
              >
                Continue into sales
                <ArrowRight className="h-4 w-4" />
              </Link>
            </div>
          </div>
        </section>
      </div>
    </main>
  )
}