# 실서버(Supabase) 연결 가이드

withyou+ 는 기본적으로 **로컬(shared_preferences)** 로 동작합니다. 아래 4단계를 마치고
`.env` 의 `BACKEND=supabase` 로 바꾸면 **인증·프로필·대화·리포트가 실서버에 저장**됩니다.
키를 넣지 않으면 앱은 지금처럼 로컬로 잘 동작합니다(코드 변경 불필요).

## 1. 프로젝트 생성
1. https://supabase.com 로그인 → **New project** 생성(무료 플랜 가능).
2. 리전은 가까운 곳(예: Seoul) 선택.

## 2. 스키마 실행
1. 대시보드 → **SQL Editor** → New query.
2. 리포지토리의 [`supabase/schema.sql`](../supabase/schema.sql) 내용을 붙여넣고 **Run**.
   - `profiles`, `user_state` 테이블과 RLS(본인 데이터만 접근) 정책이 생성됩니다.

## 3. 이메일 확인 끄기(권장)
앱은 자체 인증번호(Gmail SMTP) 흐름을 이미 갖고 있습니다. Supabase 의 이메일 확인과
중복되지 않도록:
- **Authentication → Providers → Email → "Confirm email" 을 Off**.
- 그러면 회원가입 즉시 세션이 생겨 바로 로그인됩니다.

## 4. 키 넣기
- 대시보드 → **Project Settings → API** 에서
  - **Project URL** → `.env` 의 `SUPABASE_URL`
  - **anon public** key → `.env` 의 `SUPABASE_ANON_KEY`
- 그리고 `.env` 에서 `BACKEND=supabase` 로 변경.

```
BACKEND=supabase
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...   # anon public key (service_role 키 아님!)
```

앱을 다시 실행하면 실서버로 동작합니다.

## 동작 방식 요약
- **인증**: 이메일/비밀번호는 Supabase Auth 사용. 프로필(호칭/자기소개/유머취향/마케팅
  동의)은 `profiles` 테이블에 저장.
- **데이터**: 대화(`chat_conversations`)·리포트(`mind_reports`)는 로컬 우선으로 저장하고
  `user_state` 테이블에 JSON 으로 백업/복원(기기 바꿔도 이어보기). 오프라인/실패해도
  로컬 흐름은 막지 않습니다.
- **AI/메일**: 기존과 동일(Gemini API, Gmail SMTP).

## 남은 후속 작업(선택)
- **소셜 로그인(카카오/구글/애플)**: 실서버 모드에서는 각 제공자 OAuth 설정이 필요합니다
  (Supabase Auth Providers). 현재는 이메일 로그인만 실서버로 연결되고, 소셜은 안내 메시지로
  대체됩니다.
- **회원 탈퇴의 완전 삭제**: 본인 프로필/상태 행과 세션은 앱에서 정리하지만, `auth.users`
  레코드 자체의 삭제는 관리자 권한이 필요합니다. 필요 시 아래 형태의 Edge Function 을
  추가해 호출하세요.

```ts
// supabase/functions/delete-user/index.ts (예시)
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
Deno.serve(async (req) => {
  const authClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: req.headers.get("Authorization")! } },
  });
  const { data: { user } } = await authClient.auth.getUser();
  if (!user) return new Response("unauthorized", { status: 401 });
  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  await admin.auth.admin.deleteUser(user.id);
  return new Response("ok");
});
```
