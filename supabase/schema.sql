-- withyou+ 실서버(Supabase) 스키마
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 실행하세요.
-- 인증(auth.users)은 Supabase 가 관리하고, 아래 두 테이블에 프로필/상태를 저장합니다.
-- 모든 접근은 RLS 로 "본인 데이터만" 허용됩니다.

-- 1) 사용자 프로필 -----------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text,
  name       text default '',
  bio        text default '',
  humor      text default '',
  gift_taste text default '',
  allergy    text default '',
  scent      text default '',
  marketing  boolean default false,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "profiles are self-only" on public.profiles;
create policy "profiles are self-only"
  on public.profiles for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- 2) 사용자별 상태(대화/리포트 등 JSON 백업) -------------------------------
-- 앱은 로컬(shared_preferences) 우선으로 동작하고, 이 테이블에 키별 JSON 을
-- 백업/복원합니다(예: key='chat_conversations', key='mind_reports').
create table if not exists public.user_state (
  user_id    uuid not null references auth.users (id) on delete cascade,
  key        text not null,
  value      jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

alter table public.user_state enable row level security;

drop policy if exists "user_state is self-only" on public.user_state;
create policy "user_state is self-only"
  on public.user_state for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 3) updated_at 자동 갱신 트리거 --------------------------------------------
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end; $$;

drop trigger if exists trg_profiles_touch on public.profiles;
create trigger trg_profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_user_state_touch on public.user_state;
create trigger trg_user_state_touch before update on public.user_state
  for each row execute function public.touch_updated_at();
