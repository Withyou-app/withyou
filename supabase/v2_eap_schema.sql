-- ════════════════════════════════════════════════════════════════════════
--  withyou+ v2 — B2B EAP 백엔드 스키마 (Supabase / PostgreSQL)
--  Supabase 대시보드 → SQL Editor 에 붙여넣고 실행하세요. (여러 번 실행해도 안전)
--
--  설계 원칙(스펙 §3.11 / §4.4 / §4.5):
--   • Credit 소유자 = 기업(Enterprise). 차감 = 세션 정상완료 / 선물 주문확정 시.
--   • 회사(Admin)는 개인 "대화 원문·리포트·안전신호·선물 내용"을 볼 수 없다(RLS로 강제).
--     Admin 은 기업 Credit·직원 목록·이용상태(집계)만 접근.
--   • 안전정책은 서버(Edge Function)에서 강제 — 이 스키마는 데이터 경계만 책임진다.
-- ════════════════════════════════════════════════════════════════════════

-- ── 0) 열거형(ENUM) ──────────────────────────────────────────────────────
do $$ begin
  create type public.member_role   as enum ('employee','admin','operator');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.persona_type  as enum ('구나','고미','리미');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.session_status as enum ('active','completed','abandoned');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.order_status   as enum ('pending','confirmed','shipped','cancelled');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.message_role   as enum ('user','assistant');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.ledger_reason  as enum ('session','gift','topup','adjustment');
exception when duplicate_object then null; end $$;

-- ── 1) 기업(Enterprise) + Credit Pool ────────────────────────────────────
create table if not exists public.enterprises (
  id             uuid primary key default gen_random_uuid(),
  name           text not null,
  credit_balance integer not null default 0,         -- Credit Pool 잔액(소유자=기업)
  gift_enabled   boolean not null default true,       -- 선물 기능 허용 여부
  settings       jsonb   not null default '{}'::jsonb, -- 허용 선물 카테고리 등
  created_at     timestamptz not null default now()
);

-- ── 2) 프로필 확장 (기존 profiles 에 소속/역할 추가) ──────────────────────
--  (기존 v1 schema.sql 의 profiles 테이블이 먼저 실행돼 있어야 함)
alter table public.profiles
  add column if not exists enterprise_id uuid references public.enterprises(id) on delete set null;
alter table public.profiles
  add column if not exists role public.member_role not null default 'employee';

-- ── 3) 초대(기업 초대링크) ───────────────────────────────────────────────
create table if not exists public.invites (
  code          text primary key,                      -- 초대 코드(링크의 /invite/{code})
  enterprise_id uuid not null references public.enterprises(id) on delete cascade,
  email         text,                                   -- 특정 메일 대상(선택)
  expires_at    timestamptz,
  used_by       uuid references auth.users(id) on delete set null,
  used_at       timestamptz,
  created_at    timestamptz not null default now()
);

-- ── 4) AI EAP 세션 / 메시지 / 리포트 / 안전 이벤트 ───────────────────────
create table if not exists public.sessions (
  id             uuid primary key default gen_random_uuid(),
  employee_id    uuid not null references auth.users(id) on delete cascade,
  enterprise_id  uuid references public.enterprises(id) on delete set null,
  persona        public.persona_type not null,
  status         public.session_status not null default 'active',
  credit_cost    integer not null default 1,            -- 세션 1회 비용(Credit)
  credit_charged boolean not null default false,        -- 차감 완료 여부
  started_at     timestamptz not null default now(),
  ended_at       timestamptz
);
create index if not exists idx_sessions_employee on public.sessions(employee_id, started_at desc);

create table if not exists public.messages (
  id         uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  employee_id uuid not null references auth.users(id) on delete cascade, -- RLS 단순화용 중복 보관
  role       public.message_role not null,
  content    text not null,                             -- 개인 대화 원문(회사 접근 불가)
  created_at timestamptz not null default now()
);
create index if not exists idx_messages_session on public.messages(session_id, created_at);

create table if not exists public.reports (
  id            uuid primary key default gen_random_uuid(),
  session_id    uuid unique references public.sessions(id) on delete cascade,
  employee_id   uuid not null references auth.users(id) on delete cascade,
  enterprise_id uuid references public.enterprises(id) on delete set null,
  emotions      text[] not null default '{}',
  summary       text not null default '',
  need_now      text not null default '',
  small_action  text not null default '',
  mission       text not null default '',
  created_at    timestamptz not null default now()
);
create index if not exists idx_reports_employee on public.reports(employee_id, created_at desc);

-- 안전 신호 — 회사 접근 불가. 서버(Edge Function)만 기록. 본인만 조회.
create table if not exists public.safety_events (
  id          uuid primary key default gen_random_uuid(),
  session_id  uuid references public.sessions(id) on delete set null,
  employee_id uuid not null references auth.users(id) on delete cascade,
  severity    smallint not null default 0,              -- 0 일상 ~ 5 즉시위험(§3.5)
  category    text not null default '',
  note        text not null default '',
  created_at  timestamptz not null default now()
);
create index if not exists idx_safety_employee on public.safety_events(employee_id, created_at desc);

-- ── 5) 선물 상품 카탈로그 / 주문 ─────────────────────────────────────────
create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  slug        text unique not null,                     -- hotchoco, cookie ...
  name        text not null,
  tagline     text not null default '',                 -- 카드 노출 감성 한 줄
  description text not null default '',                 -- 상세 설명
  credit_cost integer not null,
  asset       text not null default '',                 -- assets/gifts/<slug>.png
  url         text not null default '',                 -- 구매/상세 링크
  category    text not null default '',
  stock       integer,                                   -- null = 무제한
  active      boolean not null default true,
  sort        integer not null default 0
);

create table if not exists public.gift_orders (
  id            uuid primary key default gen_random_uuid(),
  employee_id   uuid not null references auth.users(id) on delete cascade,
  enterprise_id uuid references public.enterprises(id) on delete set null,
  product_id    uuid not null references public.products(id),
  qty           integer not null default 1,
  credit_cost   integer not null,                       -- 주문 시점 총 Credit
  status        public.order_status not null default 'pending',
  recipient     jsonb not null default '{}'::jsonb,      -- 배송지/연락처(감정기록과 분리 §3.12)
  created_at    timestamptz not null default now(),
  confirmed_at  timestamptz
);
create index if not exists idx_orders_employee on public.gift_orders(employee_id, created_at desc);

-- ── 6) Credit 거래내역(원장) ─────────────────────────────────────────────
create table if not exists public.credit_ledger (
  id            uuid primary key default gen_random_uuid(),
  enterprise_id uuid not null references public.enterprises(id) on delete cascade,
  employee_id   uuid references auth.users(id) on delete set null,
  delta         integer not null,                       -- 음수=차감, 양수=충전
  reason        public.ledger_reason not null,
  ref_id        uuid,                                    -- 세션/주문 id
  memo          text not null default '',
  created_at    timestamptz not null default now()
);
create index if not exists idx_ledger_enterprise on public.credit_ledger(enterprise_id, created_at desc);

-- ════════════════════════════════════════════════════════════════════════
--  7) 권한 판별 헬퍼 (SECURITY DEFINER — profiles 를 읽어 RLS 재귀 방지)
-- ════════════════════════════════════════════════════════════════════════
create or replace function public.current_enterprise_id()
returns uuid language sql stable security definer set search_path = public as $$
  select enterprise_id from public.profiles where id = auth.uid();
$$;

-- 주의: current_role 은 SQL 예약어이므로 current_member_role 로 명명.
create or replace function public.current_member_role()
returns public.member_role language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select role from public.profiles where id = auth.uid()) = 'admin', false);
$$;

create or replace function public.is_operator()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select role from public.profiles where id = auth.uid()) = 'operator', false);
$$;

-- ════════════════════════════════════════════════════════════════════════
--  8) RLS — 개인 데이터는 본인만, 회사(Admin)는 개인 내용 접근 불가
-- ════════════════════════════════════════════════════════════════════════
alter table public.enterprises   enable row level security;
alter table public.invites       enable row level security;
alter table public.sessions      enable row level security;
alter table public.messages      enable row level security;
alter table public.reports       enable row level security;
alter table public.safety_events enable row level security;
alter table public.products      enable row level security;
alter table public.gift_orders   enable row level security;
alter table public.credit_ledger enable row level security;

-- enterprises: 소속 직원은 자기 기업 조회 / operator 전체
drop policy if exists "enterprise read by member" on public.enterprises;
create policy "enterprise read by member" on public.enterprises for select
  using (id = public.current_enterprise_id() or public.is_operator());
drop policy if exists "enterprise manage by operator" on public.enterprises;
create policy "enterprise manage by operator" on public.enterprises for all
  using (public.is_operator()) with check (public.is_operator());

-- profiles: (본인 전체는 v1 정책 유지) + Admin 은 같은 기업 직원 "행" 조회 가능(목록/이용상태)
drop policy if exists "profiles admin reads same enterprise" on public.profiles;
create policy "profiles admin reads same enterprise" on public.profiles for select
  using (public.is_admin() and enterprise_id = public.current_enterprise_id());

-- invites: operator 관리 / 대상자 조회
drop policy if exists "invites by operator or admin" on public.invites;
create policy "invites by operator or admin" on public.invites for all
  using (public.is_operator() or (public.is_admin() and enterprise_id = public.current_enterprise_id()))
  with check (public.is_operator() or (public.is_admin() and enterprise_id = public.current_enterprise_id()));

-- sessions / messages / reports / gift_orders / safety_events : 본인만(회사 차단)
drop policy if exists "sessions self only" on public.sessions;
create policy "sessions self only" on public.sessions for all
  using (employee_id = auth.uid()) with check (employee_id = auth.uid());

drop policy if exists "messages self only" on public.messages;
create policy "messages self only" on public.messages for all
  using (employee_id = auth.uid()) with check (employee_id = auth.uid());

drop policy if exists "reports self only" on public.reports;
create policy "reports self only" on public.reports for all
  using (employee_id = auth.uid()) with check (employee_id = auth.uid());

drop policy if exists "orders self only" on public.gift_orders;
create policy "orders self only" on public.gift_orders for all
  using (employee_id = auth.uid()) with check (employee_id = auth.uid());

-- 안전 이벤트: 본인 조회만. 기록(insert/update)은 서버(service_role)만 → 정책 없음.
drop policy if exists "safety read self" on public.safety_events;
create policy "safety read self" on public.safety_events for select
  using (employee_id = auth.uid());

-- products: 로그인 사용자 모두 조회 / operator 관리
drop policy if exists "products read all" on public.products;
create policy "products read all" on public.products for select
  using (auth.role() = 'authenticated');
drop policy if exists "products manage by operator" on public.products;
create policy "products manage by operator" on public.products for all
  using (public.is_operator()) with check (public.is_operator());

-- credit_ledger: 본인 내역 / Admin 은 자기 기업 집계(기업 Credit 은 회사 소유라 열람 허용)
drop policy if exists "ledger self or admin" on public.credit_ledger;
create policy "ledger self or admin" on public.credit_ledger for select
  using (
    employee_id = auth.uid()
    or (public.is_admin() and enterprise_id = public.current_enterprise_id())
    or public.is_operator()
  );

-- 역할 권한(GRANT) — RLS 와 별개로 테이블 접근 권한 필요
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on
  public.enterprises, public.invites, public.sessions, public.messages,
  public.reports, public.gift_orders, public.credit_ledger, public.products to authenticated;
-- 안전 이벤트는 조회만(기록은 서버 service_role 전용)
grant select on public.safety_events to authenticated;

-- ════════════════════════════════════════════════════════════════════════
--  9) Credit 차감 로직 (서버/Edge Function 에서 호출; SECURITY DEFINER)
--     §4.4 차감 시점: 세션 정상완료 / 주문 최종확정. 잔액 부족 시 예외.
-- ════════════════════════════════════════════════════════════════════════
create or replace function public.complete_session(p_session uuid)
returns void language plpgsql security definer set search_path = public as $$
declare s public.sessions; begin
  select * into s from public.sessions where id = p_session for update;
  if not found then raise exception 'session not found'; end if;
  if s.credit_charged then return; end if; -- 멱등
  update public.enterprises
     set credit_balance = credit_balance - s.credit_cost
   where id = s.enterprise_id and credit_balance >= s.credit_cost;
  if not found then raise exception 'INSUFFICIENT_ENTERPRISE_CREDIT'; end if; -- 기업 한도 초과
  update public.sessions
     set status = 'completed', credit_charged = true, ended_at = now()
   where id = p_session;
  insert into public.credit_ledger(enterprise_id, employee_id, delta, reason, ref_id, memo)
  values (s.enterprise_id, s.employee_id, -s.credit_cost, 'session', s.id, 'AI EAP 세션 완료');
end; $$;

create or replace function public.confirm_gift_order(p_order uuid)
returns void language plpgsql security definer set search_path = public as $$
declare o public.gift_orders; begin
  select * into o from public.gift_orders where id = p_order for update;
  if not found then raise exception 'order not found'; end if;
  if o.status = 'confirmed' then return; end if; -- 멱등
  update public.enterprises
     set credit_balance = credit_balance - o.credit_cost
   where id = o.enterprise_id and credit_balance >= o.credit_cost;
  if not found then raise exception 'INSUFFICIENT_ENTERPRISE_CREDIT'; end if;
  update public.gift_orders set status = 'confirmed', confirmed_at = now() where id = p_order;
  insert into public.credit_ledger(enterprise_id, employee_id, delta, reason, ref_id, memo)
  values (o.enterprise_id, o.employee_id, -o.credit_cost, 'gift', o.id, '선물 주문 확정');
end; $$;

-- 초대코드 사용 → 현재 사용자를 해당 기업 직원으로 연결
create or replace function public.redeem_invite(p_code text)
returns uuid language plpgsql security definer set search_path = public as $$
declare inv public.invites; begin
  select * into inv from public.invites where code = p_code for update;
  if not found then raise exception 'INVITE_NOT_FOUND'; end if;
  if inv.used_by is not null then raise exception 'INVITE_ALREADY_USED'; end if;
  if inv.expires_at is not null and inv.expires_at < now() then raise exception 'INVITE_EXPIRED'; end if;
  update public.profiles set enterprise_id = inv.enterprise_id where id = auth.uid();
  update public.invites set used_by = auth.uid(), used_at = now() where code = p_code;
  return inv.enterprise_id;
end; $$;

-- ════════════════════════════════════════════════════════════════════════
-- 10) 회사용 집계 — 개인 내용 없이 "이용 상태"만 (§4.5 Admin)
--     RLS(세션=본인만) 를 우회해 집계만 내보내므로 SECURITY DEFINER 함수로 구현하고,
--     내부에서 Admin/Operator 권한 + 본인 기업으로 범위를 제한한다.
-- ════════════════════════════════════════════════════════════════════════
create or replace function public.enterprise_usage()
returns table (active_employees bigint, total_sessions bigint, completed_sessions bigint)
language plpgsql stable security definer set search_path = public as $$
declare ent uuid; begin
  if not (public.is_admin() or public.is_operator()) then
    raise exception 'FORBIDDEN';
  end if;
  ent := public.current_enterprise_id();
  return query
    select count(distinct s.employee_id),
           count(s.id),
           count(s.id) filter (where s.status = 'completed')
      from public.sessions s
     where s.enterprise_id = ent;
end; $$;

-- ── 11) 선물 카탈로그 시드 (앱 v2 카탈로그와 동일) ────────────────────────
insert into public.products (slug, name, tagline, description, credit_cost, asset, url, category, sort) values
  ('hotchoco','핫초코','오늘 달콤한 한잔의 여유는 어떨까요?','뜨거운 물이나 우유에 타서 마시는 스틱형 핫초코예요.',9,'assets/gifts/hotchoco.png','','음료',1),
  ('decaf_tea','디카페인 티백','은은한 향과 함께 짐들을 잠시 내려놓아볼까요?','카페인 없이 우려 마시는 캐모마일 허브차 티백이에요.',9,'assets/gifts/decaf_tea.png','https://www.imarket.co.kr/p/FD0906','음료',2),
  ('dripbag_coffee','드립백 커피','커피한잔의 여유를 보내봐요','컵에 걸고 뜨거운 물을 부어 내리는 드립백 커피예요.',10,'assets/gifts/dripbag_coffee.png','https://www.somesomemilmil.com/shop_view/?idx=118','음료',3),
  ('cookie','쿠키','바삭한 한입과 함께 잠시 쉬어가요','캐러멜과 시나몬 풍미의 바삭한 로투스 비스코프예요.',4,'assets/gifts/cookie.png','https://www.ssg.com/item/itemView.ssg?itemId=1000529666055','간식',4),
  ('chocolate','초콜릿','열심히 한 하루에 달콤한 선물','부드러운 우유 맛의 가나 마일드 초콜릿이에요.',3,'assets/gifts/chocolate.png','https://m.lottesweetmall.com/product/%EA%B0%80%EB%82%98-%EB%A7%88%EC%9D%BC%EB%93%9C-34g/60/category/77/display/1/','간식',5),
  ('nuts','견과류','바쁜 하루에도 날 챙기는 루틴','견과류와 건포도를 한 봉씩 담은 하루견과예요.',12,'assets/gifts/nuts.png','https://m.nutsholic.co.kr/product/오리지널/907/','간식',6),
  ('memo_pad','메모지','당신의 시선에서 언제든 기억될 수 있게','짧은 메모나 페이지 표시에 사용하는 메모지예요.',5,'assets/gifts/memo_pad.png','https://www.alpha.co.kr/product/productView.do?productCode=2192434','문구',7),
  ('keyring','키링','평범했던 하루를 작은 친구와 함께','가방이나 열쇠에 달아 사용하는 아크릴 키링이에요.',5,'assets/gifts/keyring.png','https://www.10x10.co.kr/shopping/category_prd.asp?itemid=5076674','소품',8),
  ('wrist_guard','손목 보호대','오늘도 고생 많았어요','손목을 감싸 보호하는 손목보호대예요.',6,'assets/gifts/wrist_guard.png','https://gglindaclip.cafe24.com/m/product/detail.html?product_no=22','건강',9),
  ('hot_pack','핫팩','추운 출근길, 작은 온기를 챙겨가요','주머니에 넣어 손을 데우는 미니 일회용 핫팩이에요.',4,'assets/gifts/hot_pack.png','https://www.designever.co.kr/goods/goods_view.php?goodsNo=1210755011','건강',10)
on conflict (slug) do update set
  name=excluded.name, tagline=excluded.tagline, description=excluded.description,
  credit_cost=excluded.credit_cost, asset=excluded.asset, url=excluded.url,
  category=excluded.category, sort=excluded.sort;

-- 끝. (핫초코 url 은 링크 확보 후 UPDATE 하세요)
