-- Kurdistan Tourism mobile data model
-- Run this in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name_ckb text not null,
  name_ar text not null default '',
  name_en text not null default '',
  description_ckb text not null default '',
  description_ar text not null default '',
  description_en text not null default '',
  category text not null default 'nature',
  governorate text not null default '',
  district text not null default '',
  latitude double precision not null,
  longitude double precision not null,
  image_urls text[] not null default '{}',
  video_url text not null default '',
  featured boolean not null default false,
  is_active boolean not null default true,
  rating numeric(2,1) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists places_category_idx on public.places(category);
create index if not exists places_governorate_idx on public.places(governorate);
create index if not exists places_active_idx on public.places(is_active);

create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, place_id)
);

create table if not exists public.trip_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  start_date date,
  end_date date,
  budget numeric(12,2),
  created_at timestamptz not null default now()
);

create table if not exists public.trip_plan_places (
  trip_id uuid not null references public.trip_plans(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  day_number integer not null default 1,
  sort_order integer not null default 0,
  primary key (trip_id, place_id)
);

alter table public.places enable row level security;
alter table public.favorites enable row level security;
alter table public.trip_plans enable row level security;
alter table public.trip_plan_places enable row level security;

-- Public tourism data is readable by everyone; only authenticated admins
-- should write it. Admin policy can later be replaced by a profiles/roles table.
drop policy if exists "places_public_read" on public.places;
create policy "places_public_read" on public.places for select using (is_active = true);

drop policy if exists "favorites_owner" on public.favorites;
create policy "favorites_owner" on public.favorites for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "trip_owner" on public.trip_plans;
create policy "trip_owner" on public.trip_plans for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "trip_places_owner" on public.trip_plan_places;
create policy "trip_places_owner" on public.trip_plan_places for all using (
  exists (select 1 from public.trip_plans t where t.id = trip_id and t.user_id = auth.uid())
) with check (
  exists (select 1 from public.trip_plans t where t.id = trip_id and t.user_id = auth.uid())
);

-- Example real place. Add the rest from the same structure.
insert into public.places (slug, name_ckb, name_ar, name_en, category, governorate, district, latitude, longitude, featured)
values ('erbil-citadel', 'قەڵای هەولێر', 'قلعة أربيل', 'Erbil Citadel', 'historical', 'Erbil', 'Erbil', 36.1911, 44.0092, true)
on conflict (slug) do update set
  name_ckb = excluded.name_ckb,
  name_ar = excluded.name_ar,
  name_en = excluded.name_en,
  latitude = excluded.latitude,
  longitude = excluded.longitude,
  featured = excluded.featured,
  updated_at = now();
