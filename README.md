# withyou+

*An AI emotional-companion app — talk it out, get a mind report, feel a little lighter.*

withyou+(위드유)는 AI 친구와 대화를 나누는 Flutter 앱입니다. 대화가 끝나면 자동으로
**마음 리포트**(감정 태그·요약·지금 필요한 것·작은 행동 제안)가 만들어지고, 위로가
필요한 순간엔 대화 속에서 작은 **선물**을 추천받아 상세 화면까지 이어볼 수 있습니다.

## 핵심 기능

- **AI 감정친구와 대화**: 성격이 다른 페르소나 3종 중 골라 대화합니다.
  - **구나** — 다정하게 폭 안아주는 공감형
  - **리미** — 겉은 툭툭, 속은 챙기는 츤데레
  - **고미** — 담백하고 차분한 조언형
- **마음 리포트 자동 생성**: 대화 종료 시 감정 태그·사건 요약·지금 필요한 것·작은 행동·오늘의
  미션을 정리해 보여줍니다.
- **선물 추천**: 대화 맥락상 위로가 필요하다고 판단되면 AI가 자연스럽게 선물을 제안하고,
  상세 화면에서 확인·구매로 이어집니다.
- **대화 중간저장**: 앱을 껐다 켜도 진행 중이던 대화가 페르소나별로 이어집니다.
- **로컬/실서버 겸용**: 별도 설정 없이도 기기 로컬 저장으로 완전히 동작하고, 원하면
  Supabase를 붙여 계정·대화·리포트를 서버에 동기화할 수 있습니다.

## 스크린샷

<!-- screenshot: 홈 -->
<!-- screenshot: 채팅 -->
<!-- screenshot: 마음 리포트 -->
<!-- screenshot: 선물 상세 -->

## 기술 스택 / 아키텍처

- **Flutter** (Dart SDK `^3.11.4`)
- **AI**: Provider 전략 패턴으로 Gemini / OpenAI / Claude / 데모(Demo)를 `.env`의
  `AI_PROVIDER` 값 하나로 교체합니다(`lib/services/ai/`). 키가 없으면 자동으로
  데모 응답으로 동작해 누구나 바로 앱을 실행해볼 수 있습니다.
- **백엔드**: Supabase를 선택적으로 연결합니다(`lib/services/backend/`). `.env`의
  `BACKEND=local`(기본)이면 `shared_preferences` 기반 로컬 저장, `BACKEND=supabase`면
  인증·프로필·대화·리포트가 실서버에 저장됩니다. 서버 연결이 꺼져 있거나 실패해도 로컬
  흐름은 항상 살아 있습니다.
- **레이어 구조**: `screens/`(화면) · `services/`(ai, backend 등 도메인 로직) ·
  `models/`(데이터 모델) · `widgets/`(공용 컴포넌트) · `theme/`(컬러·폰트·타이포).
- **상태 관리**: 별도 상태관리 패키지 없이 싱글턴 + `ChangeNotifier` 조합을 씁니다
  (예: `ConversationStore.instance`). 서비스 개수가 많지 않고 화면 간 공유 상태가
  단순해, 러닝커브 없는 Flutter 표준 패턴만으로 충분하다고 판단했습니다.

## 시작하기

### 요구사항

- Flutter SDK `^3.11.4`

### 설치 및 실행

```bash
flutter pub get
cp .env.example .env   # 값을 채우지 않아도 데모/로컬 모드로 실행됩니다
flutter run
```

## 환경설정 (.env)

`.env.example`을 복사해 `.env`를 만들고 필요한 값만 채우세요. 비워두면 각각 데모/로컬
모드로 자동 대체됩니다.

| 키 | 설명 |
| --- | --- |
| `AI_PROVIDER` | `gemini` \| `openai` \| `claude` (기본값 `gemini`). 해당 제공자의 API 키가 비어 있으면 자동으로 데모 응답을 씁니다. |
| `GEMINI_API_KEY` / `GEMINI_MODEL` | Gemini 사용 시 API 키와 모델명. |
| `OPENAI_API_KEY` / `OPENAI_MODEL` | OpenAI 사용 시 API 키와 모델명. |
| `ANTHROPIC_API_KEY` / `ANTHROPIC_MODEL` | Claude 사용 시 API 키와 모델명. |
| `MAIL_HOST` / `MAIL_PORT` / `MAIL_USERNAME` / `MAIL_PASSWORD` / `MAIL_FROM_NAME` | 회원가입 인증 메일 발송(SMTP). `MAIL_USERNAME`/`MAIL_PASSWORD`가 비면 데모 모드로 동작합니다. |
| `BACKEND` | `local`(기본) \| `supabase`. |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | `BACKEND=supabase`일 때만 사용. 실서버 연동 절차는 [`docs/BACKEND_SETUP.md`](docs/BACKEND_SETUP.md) 참고. |

## 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점 — .env 로드, 각 서비스 초기화
├── app.dart                # MaterialApp, 라우트 테이블
├── routes/                 # 라우트 상수
├── screens/                 # 화면 (auth, onboarding, persona, chat, report, gift, mypage ...)
├── services/
│   ├── ai/                  # AI 제공자 전략 패턴 + 프롬프트 (ai_service.dart, ai_prompts.dart)
│   ├── backend/              # Supabase 연동 (supabase_service.dart)
│   └── ...                  # 대화/리포트/선물 등 로컬 저장 스토어
├── models/                  # 데이터 모델
├── widgets/                  # 공용 위젯
└── theme/                    # 컬러/폰트/타이포그래피

docs/                        # 백엔드·소셜 로그인 연동 가이드
supabase/schema.sql          # Supabase 테이블/RLS 스키마
```

## 라이선스

[MIT](LICENSE)
