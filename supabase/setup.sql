-- BEBOP Timeline Maker · Supabase 초기 설정 (bebop-tools 프로젝트, Mock-up Data와 같은 곳)
-- Supabase 대시보드 → SQL Editor → 붙여넣고 Run (한 번만)
-- is_bebop() 함수는 Mock-up Data 설정 때 이미 만들어져 있지만, 없을 때를 대비해 다시 정의해요.

create or replace function public.is_bebop() returns boolean
language sql stable as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) like '%@bebop.kr'
$$;

-- 타임라인 아카이브 (한 행 = 프로젝트 하나, state = 편집 상태 전체 JSON 문자열)
create table if not exists public.timelines (
  id          text primary key,
  client      text not null default '',
  project     text not null default '',
  start_date  text,
  end_date    text,
  backup      boolean not null default false,   -- 자동 백업으로만 저장된 것
  weeks       numeric not null default 0,
  phases      int  not null default 0,
  updated     bigint not null default 0,        -- ms (Date.now())
  state       text not null,
  saved_by    text,
  saved_at    timestamptz not null default now()
);

alter table public.timelines enable row level security;

drop policy if exists "bebop only" on public.timelines;
create policy "bebop only" on public.timelines
  for all to authenticated
  using (public.is_bebop()) with check (public.is_bebop());
