# Architecture decisions

## Astro + Cloudflare
Astro is the public web framework. Cloudflare adapter enables on-demand routes. The project uses server output; editorial routes opt into prerendering when content is available at build time.

## Supabase
Supabase PostgreSQL is the source of truth for artist, battle, achievement, discography, media and editorial records. Schema changes are SQL migrations committed to Git.

## React islands
React is reserved for components with meaningful client-side interaction. Astro components render content-first pages.

## No admin in initial release
The initial release is read-only for public users. Admin/auth flows are deferred, while schema and RLS are prepared for them.

## Domain strategy
The root domain hosts the portal. Artist subdomains resolve to artist records through a server-side hostname lookup. Canonical URLs must be explicit and duplicate content avoided.
