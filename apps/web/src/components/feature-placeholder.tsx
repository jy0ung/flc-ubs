import type { Route } from 'next'
import Link from 'next/link'

type PlaceholderLink = {
  href: string
  label: string
}

interface FeaturePlaceholderProps {
  eyebrow?: string
  title: string
  description: string
  status?: string
  backHref?: string
  backLabel?: string
  nextSteps?: readonly string[]
  relatedLinks?: readonly PlaceholderLink[]
}

export function FeaturePlaceholder({
  eyebrow = 'Feature scaffold',
  title,
  description,
  status = 'Ready for implementation',
  backHref = '/',
  backLabel = 'Back to home',
  nextSteps = [],
  relatedLinks = [],
}: FeaturePlaceholderProps) {
  return (
    <main className="min-h-screen bg-slate-50">
      <div className="mx-auto flex max-w-4xl flex-col gap-6 px-4 py-10 sm:px-6 lg:px-8">
        <div>
          <Link
            href={backHref as Route}
            className="inline-flex items-center text-sm font-medium text-blue-600 hover:text-blue-700"
          >
            ← {backLabel}
          </Link>
        </div>

        <section className="rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
          <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-sm font-semibold uppercase tracking-[0.2em] text-blue-600">
                {eyebrow}
              </p>
              <h1 className="mt-2 text-3xl font-bold text-slate-900">{title}</h1>
              <p className="mt-3 max-w-2xl text-base text-slate-600">{description}</p>
            </div>

            <span className="inline-flex w-fit rounded-full bg-amber-100 px-3 py-1 text-sm font-medium text-amber-800">
              {status}
            </span>
          </div>

          <div className="grid gap-6 lg:grid-cols-[1.5fr_1fr]">
            <div className="rounded-xl border border-slate-200 bg-slate-50 p-5">
              <h2 className="text-lg font-semibold text-slate-900">Suggested next development steps</h2>
              {nextSteps.length > 0 ? (
                <ol className="mt-4 space-y-3 text-sm text-slate-700">
                  {nextSteps.map((step) => (
                    <li key={step} className="flex gap-3">
                      <span className="mt-0.5 inline-flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold text-white">
                        •
                      </span>
                      <span>{step}</span>
                    </li>
                  ))}
                </ol>
              ) : (
                <p className="mt-4 text-sm text-slate-600">
                  This route is wired up and ready for the first real feature implementation.
                </p>
              )}
            </div>

            <div className="rounded-xl border border-slate-200 p-5">
              <h2 className="text-lg font-semibold text-slate-900">Related routes</h2>
              {relatedLinks.length > 0 ? (
                <div className="mt-4 flex flex-col gap-3">
                  {relatedLinks.map((link) => (
                    <Link
                      key={link.href}
                      href={link.href as Route}
                      className="rounded-lg border border-slate-200 px-4 py-3 text-sm font-medium text-slate-700 transition-colors hover:border-blue-200 hover:bg-blue-50 hover:text-blue-700"
                    >
                      {link.label}
                    </Link>
                  ))}
                </div>
              ) : (
                <p className="mt-4 text-sm text-slate-600">Add connected workflows here as the module grows.</p>
              )}
            </div>
          </div>
        </section>
      </div>
    </main>
  )
}