-- Enable PostGIS for location queries
create extension if not exists postgis;

-- Usage: location geography(POINT)
-- Index: create index on profiles using gist(location);

-- Profiles Table
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text unique,
  full_name text,
  avatar_url text,
  bio text,
  birthdate date,
  location geography(POINT),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Matches Table
create table public.matches (
  id uuid default gen_random_uuid() primary key,
  user_a_id uuid references public.profiles(id) not null,
  user_b_id uuid references public.profiles(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  constraint unique_match unique (user_a_id, user_b_id)
);

-- Swipes Table
create table public.swipes (
  id uuid default gen_random_uuid() primary key,
  swiper_id uuid references public.profiles(id) not null,
  swiped_id uuid references public.profiles(id) not null,
  is_like boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies
alter table public.profiles enable row level security;
alter table public.matches enable row level security;
alter table public.swipes enable row level security;

-- Policy: Public profiles are viewable by everyone (authenticated)
create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  to authenticated
  using (true);

-- Policy: Users can insert their own profile
create policy "Users can insert their own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- Policy: Users can update their own profile
create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

-- (Further policies needed for matches and swipes based on matching logic)
