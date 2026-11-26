-- Batalhas de Rima: initial editorial schema.
-- Public visitors can read published records only. No public write policies.
create extension if not exists pgcrypto;
create type public.publication_status as enum ('draft', 'published', 'archived');
create type public.achievement_placement as enum ('first', 'second', 'third', 'mvp', 'award', 'other');

create table public.artists (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  name text not null,
  full_name text,
  short_bio text,
  biography text,
  origin_city text,
  origin_state text,
  country_code char(2) not null default 'BR',
  hero_media_path text,
  status public.publication_status not null default 'draft',
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.artist_domains (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.artists(id) on delete cascade,
  hostname text not null unique,
  is_primary boolean not null default false,
  verified_at timestamptz,
  created_at timestamptz not null default now()
);
create unique index artist_domains_one_primary on public.artist_domains(artist_id) where is_primary;

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text,
  website_url text,
  status public.publication_status not null default 'draft',
  created_at timestamptz not null default now()
);

create table public.competitions (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete set null,
  slug text not null unique,
  name text not null,
  description text,
  status public.publication_status not null default 'draft',
  created_at timestamptz not null default now()
);

create table public.competition_editions (
  id uuid primary key default gen_random_uuid(),
  competition_id uuid not null references public.competitions(id) on delete cascade,
  edition_label text not null,
  edition_year integer,
  starts_at date,
  ends_at date,
  city text,
  region text,
  country_code char(2) not null default 'BR',
  status public.publication_status not null default 'draft',
  unique (competition_id, edition_label)
);

create table public.battles (
  id uuid primary key default gen_random_uuid(),
  edition_id uuid references public.competition_editions(id) on delete set null,
  title text not null,
  stage text,
  occurred_at timestamptz,
  venue text,
  city text,
  country_code char(2) not null default 'BR',
  video_url text,
  source_notes text,
  status public.publication_status not null default 'draft',
  created_at timestamptz not null default now()
);

create table public.battle_participants (
  id uuid primary key default gen_random_uuid(),
  battle_id uuid not null references public.battles(id) on delete cascade,
  artist_id uuid not null references public.artists(id) on delete cascade,
  opponent_artist_id uuid references public.artists(id) on delete set null,
  result text,
  is_winner boolean,
  created_at timestamptz not null default now(),
  unique (battle_id, artist_id)
);

create table public.achievements (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.artists(id) on delete cascade,
  edition_id uuid references public.competition_editions(id) on delete set null,
  battle_id uuid references public.battles(id) on delete set null,
  title text not null,
  placement public.achievement_placement not null default 'other',
  achievement_year integer,
  category text,
  description text,
  verification_status text not null default 'pending'
    check (verification_status in ('pending', 'verified', 'disputed')),
  status public.publication_status not null default 'draft',
  created_at timestamptz not null default now()
);

create table public.albums (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid not null references public.artists(id) on delete cascade,
  slug text not null,
  title text not null,
  release_date date,
  cover_path text,
  label text,
  description text,
  external_links jsonb not null default '{}'::jsonb,
  status public.publication_status not null default 'draft',
  unique (artist_id, slug)
);

create table public.tracks (
  id uuid primary key default gen_random_uuid(),
  album_id uuid not null references public.albums(id) on delete cascade,
  title text not null,
  track_number integer,
  duration_seconds integer,
  external_links jsonb not null default '{}'::jsonb,
  unique (album_id, track_number)
);

create table public.media_assets (
  id uuid primary key default gen_random_uuid(),
  artist_id uuid references public.artists(id) on delete cascade,
  storage_path text not null unique,
  media_type text not null check (media_type in ('image', 'video', 'audio', 'document')),
  alt_text text,
  caption text,
  photographer_credit text,
  rights_status text not null default 'unknown'
    check (rights_status in ('unknown', 'licensed', 'authorized', 'public_domain', 'restricted')),
  width integer,
  height integer,
  status public.publication_status not null default 'draft',
  created_at timestamptz not null default now()
);

create table public.articles (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  summary text,
  body_md text not null default '',
  author_name text,
  published_at timestamptz,
  status public.publication_status not null default 'draft',
  created_at timestamptz not null default now()
);

create table public.article_sources (
  id uuid primary key default gen_random_uuid(),
  article_id uuid not null references public.articles(id) on delete cascade,
  title text not null,
  source_url text not null,
  publisher text,
  published_at timestamptz,
  accessed_at timestamptz not null default now(),
  source_type text not null default 'secondary'
    check (source_type in ('primary', 'secondary', 'official', 'interview'))
);

create index artists_status_slug_idx on public.artists(status, slug);
create index battles_edition_date_idx on public.battles(edition_id, occurred_at desc);
create index achievements_artist_year_idx on public.achievements(artist_id, achievement_year desc);
create index albums_artist_release_idx on public.albums(artist_id, release_date desc);
create index articles_status_date_idx on public.articles(status, published_at desc);

alter table public.artists enable row level security;
alter table public.artist_domains enable row level security;
alter table public.organizations enable row level security;
alter table public.competitions enable row level security;
alter table public.competition_editions enable row level security;
alter table public.battles enable row level security;
alter table public.battle_participants enable row level security;
alter table public.achievements enable row level security;
alter table public.albums enable row level security;
alter table public.tracks enable row level security;
alter table public.media_assets enable row level security;
alter table public.articles enable row level security;
alter table public.article_sources enable row level security;

create policy "published artists are readable" on public.artists
  for select to anon, authenticated using (status = 'published');
create policy "published domains are readable" on public.artist_domains
  for select to anon, authenticated using (
    exists (select 1 from public.artists a where a.id = artist_id and a.status = 'published')
  );
create policy "published organizations are readable" on public.organizations
  for select to anon, authenticated using (status = 'published');
create policy "published competitions are readable" on public.competitions
  for select to anon, authenticated using (status = 'published');
create policy "published editions are readable" on public.competition_editions
  for select to anon, authenticated using (
    status = 'published' and exists (
      select 1 from public.competitions c where c.id = competition_id and c.status = 'published'
    )
  );
create policy "published battles are readable" on public.battles
  for select to anon, authenticated using (status = 'published');
create policy "participants of published battles are readable" on public.battle_participants
  for select to anon, authenticated using (
    exists (select 1 from public.battles b where b.id = battle_id and b.status = 'published')
  );
create policy "published achievements are readable" on public.achievements
  for select to anon, authenticated using (status = 'published');
create policy "published albums are readable" on public.albums
  for select to anon, authenticated using (status = 'published');
create policy "tracks of published albums are readable" on public.tracks
  for select to anon, authenticated using (
    exists (select 1 from public.albums a where a.id = album_id and a.status = 'published')
  );
create policy "published media are readable" on public.media_assets
  for select to anon, authenticated using (status = 'published');
create policy "published articles are readable" on public.articles
  for select to anon, authenticated using (status = 'published');
create policy "sources of published articles are readable" on public.article_sources
  for select to anon, authenticated using (
    exists (select 1 from public.articles a where a.id = article_id and a.status = 'published')
  );
-- No public INSERT, UPDATE or DELETE policies are intentionally created.
