-- ====================================================================
-- TogetherRide Supabase Database Schema
-- Run this script in your Supabase Project's SQL Editor:
-- https://supabase.com/dashboard/project/zmuxmtumlbnkpfnkzlfc/sql
-- ====================================================================

-- 1. Create Profiles Table (extends auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  name text not null,
  role text not null check (role in ('passenger', 'driver')),
  phone text not null,
  rating text not null default '5.0',
  is_verified boolean not null default false,
  vehicle_number text default '',
  vehicle_model text default '',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on profiles
alter table public.profiles enable row level security;

-- RLS Policies for profiles
-- NOTE: No INSERT policy needed — profile creation is handled by the
-- handle_new_user() trigger below (SECURITY DEFINER bypasses RLS).
create policy "Allow public read access to profiles"
  on public.profiles for select
  using (true);

create policy "Allow users to update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Trigger to automatically create a profile record when a new user signs up via auth
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, role, phone, rating, is_verified, vehicle_number, vehicle_model)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'passenger'),
    coalesce(new.raw_user_meta_data->>'phone', ''),
    '5.0',
    false,
    coalesce(new.raw_user_meta_data->>'vehicle_number', ''),
    coalesce(new.raw_user_meta_data->>'vehicle_model', '')
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. Create Rides Table
create table public.rides (
  ride_id uuid primary key default gen_random_uuid(),
  driver_id uuid references public.profiles(id) on delete set null,
  driver_name text not null,
  vehicle_info text not null,
  origin text not null,
  destination text not null,
  fare double precision not null,
  eta text not null,
  seats_available integer not null,
  status text not null check (status in ('matching', 'requested', 'active', 'completed')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on rides
alter table public.rides enable row level security;

-- Create Policies for rides
create policy "Allow anyone to view rides"
  on public.rides for select
  using (true);

create policy "Allow authenticated users to create rides"
  on public.rides for insert
  with check (auth.role() = 'authenticated');

create policy "Allow drivers/users to update ride details"
  on public.rides for update
  using (auth.role() = 'authenticated');
