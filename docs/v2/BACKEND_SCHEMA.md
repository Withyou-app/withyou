# withyou+ v2 — 백엔드 스키마 (B2B EAP)

> 적용 파일: [`supabase/v2_eap_schema.sql`](../../supabase/v2_eap_schema.sql)
> 전제: v1 `supabase/schema.sql`(profiles / user_state)이 **먼저** 실행돼 있어야 함.

## 적용 방법
1. Supabase 대시보드 → **SQL Editor**
2. 먼저 `supabase/schema.sql` 실행(이미 돼 있으면 생략)
3. `supabase/v2_eap_schema.sql` 붙여넣고 실행 (여러 번 실행해도 안전 — 멱등 설계)
4. `.env` 에 `BACKEND=supabase`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` 설정

## 엔티티 (ERD 요약)
```
enterprises (기업, Credit Pool 소유)
  └─ profiles(employee/admin/operator)   ← auth.users 확장(enterprise_id, role)
  └─ invites (초대링크 code → 기업 매핑)
  └─ credit_ledger (Credit 거래내역)

profiles(employee)
  └─ sessions (AI EAP 대화 세션: persona, status, credit_cost)
        └─ messages (대화 원문)          ← 회사 접근 불가
        └─ reports  (마음 리포트)          ← 회사 접근 불가
        └─ safety_events (안전 신호)       ← 회사 접근 불가, 서버만 기록
  └─ gift_orders (선물 주문: product, recipient 배송지)

products (선물 카탈로그, 앱 v2와 동일하게 시드됨)
```

## 프라이버시 모델 (§3.11 / §4.5) — RLS로 강제
| 데이터 | 본인(Employee) | 회사(Admin) | Operator |
|---|:---:|:---:|:---:|
| 대화 원문 messages | ✅ | ❌ | ❌(정책상 미노출) |
| 마음 리포트 reports | ✅ | ❌ | ❌ |
| 안전 신호 safety_events | 조회만 | ❌ | 서버/운영 |
| 선물 주문·배송지 | ✅ | ❌ | ❌ |
| 세션 "내용" | ✅ | ❌ | ❌ |
| 세션 "집계"(건수) | — | ✅ `enterprise_usage()` | ✅ |
| 기업 Credit·원장 | 본인분 | ✅(기업분) | ✅ |
| 직원 목록·이용상태 | — | ✅(같은 기업) | ✅ |
| 상품 카탈로그 | ✅ | ✅ | 관리 |

→ **회사는 개인 대화/리포트/안전신호/선물내용을 "행 단위로" 읽을 수 없음.** 집계는 `enterprise_usage()` 함수로만(내용 없이 건수).

## Credit 흐름 (§4.4) — 소유자=기업, 차감 시점 고정
- **AI 세션 완료** → `complete_session(session_id)` : 기업 잔액 차감 + 원장 기록 (멱등)
- **선물 주문 확정** → `confirm_gift_order(order_id)` : 기업 잔액 차감 + 원장 기록 (멱등)
- 잔액 부족 → `INSUFFICIENT_ENTERPRISE_CREDIT` 예외 → 앱은 "기업 제공 한도 초과" 안내(직원 추가결제 불가, MVP)
- 초대 수락 → `redeem_invite(code)` : 현재 사용자를 기업 직원으로 연결

> 이 함수들은 **서버(Edge Function)에서 호출**하는 것을 전제로 `SECURITY DEFINER`로 작성됨(잔액 원자적 갱신).

## 역할(role)
- `employee` 기본값. `admin`/`operator`는 수동 또는 Operator 콘솔에서 승격(초기엔 SQL `update profiles set role='admin' where ...`).

## 다음 단계 (키 받은 뒤)
1. **Edge Function `chat`** — 입력검사 → 페르소나 모델(Claude) 호출 → 출력검사 → 메시지 저장 → 세션완료 시 `complete_session`. (ANTHROPIC_API_KEY는 **서버에만**)
2. **Flutter 배선** — v2 채팅 화면을 이 Edge Function에 연결, 크레딧 배지/차감 반영, 리포트 저장.
3. 안전정책(§3) 프롬프트/검사 분리 반영 — [[ai_prompts]] 재작성.

## 확인 필요
- 세션 1회 `credit_cost` 기본 1 — 실제 정책 값 확정 필요.
- 핫초코 `url` 비어 있음(링크 확보 후 `update products set url=... where slug='hotchoco'`).
