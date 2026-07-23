# 소셜 로그인 연동 가이드 (카카오 / 구글 / 애플)

현재 상태: 로그인 화면에 3개 버튼이 붙어 있고, 탭하면 `AuthService.signInWithSocial(provider)`가
**프로토타입용 로컬 세션**을 만든 뒤 호칭이 없으면 온보딩(호칭 필수)→앱으로 진입한다.
아래 절차대로 각 SDK를 붙이고 `signInWithSocial` 내부만 교체하면 실제 OAuth로 전환된다.

전환 지점(한 곳): `lib/services/auth_service.dart` 의 `signInWithSocial()`.
성공 시 얻은 이메일/이름으로 `_currentUser`와 세션을 세팅하는 구조는 그대로 재사용한다.

---

## 1) 구글 — `google_sign_in`
1. `flutter pub add google_sign_in`
2. Google Cloud Console에서 OAuth 클라이언트 생성
   - Android: 패키지명 `com.withyou.withyou` + SHA-1 등록 → `android/app/google-services.json`
   - iOS: iOS 클라이언트 + `ios/Runner/Info.plist`에 `REVERSED_CLIENT_ID` URL Scheme
3. 코드:
   ```dart
   final account = await GoogleSignIn(scopes: ['email']).signIn();
   if (account == null) return const AuthResult.failure('취소되었어요');
   // account.email, account.displayName 로 세션 세팅
   ```

## 2) 애플 — `sign_in_with_apple`
1. `flutter pub add sign_in_with_apple`
2. Apple Developer: App ID에 "Sign in with Apple" 캐퍼빌리티, iOS는 Xcode Signing & Capabilities 추가
   - Android/기타 플랫폼은 Service ID + 리다이렉트(웹 플로우) 필요
3. 코드:
   ```dart
   final cred = await SignInWithApple.getAppleIDCredential(
     scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
   );
   // cred.email(최초 1회만 제공), cred.givenName 등으로 세션 세팅
   ```
   주의: 애플은 이메일/이름을 최초 1회만 준다 → 첫 로그인 시 로컬/서버에 저장 필요.

## 3) 카카오 — `kakao_flutter_sdk_user`
1. `flutter pub add kakao_flutter_sdk_user`
2. Kakao Developers에서 앱 생성 → 네이티브 앱 키 발급, 플랫폼(Android 패키지/키해시, iOS 번들ID) 등록,
   카카오 로그인 활성화 + 동의항목(이메일 등) 설정
3. `main()`에서 초기화: `KakaoSdk.init(nativeAppKey: '<카카오 네이티브 앱 키>');`
   - Android: `AndroidManifest.xml`에 카카오 로그인 리다이렉트 액티비티/스킴 추가
   - iOS: `Info.plist`에 `LSApplicationQueriesSchemes`, URL Scheme 추가
4. 코드:
   ```dart
   final installed = await isKakaoTalkInstalled();
   final token = installed
       ? await UserApi.instance.loginWithKakaoTalk()
       : await UserApi.instance.loginWithKakaoAccount();
   final me = await UserApi.instance.me();
   // me.kakaoAccount?.email, me.kakaoAccount?.profile?.nickname 로 세션 세팅
   ```

---

## 서버(선택)
로컬 인증 대신 실제 백엔드를 쓸 경우, 각 SDK가 준 토큰을 서버로 보내 검증/세션 발급하도록
`AuthService`를 서버 호출로 교체하면 된다(공개 API 형태 유지 시 화면 코드 변경 불필요).

## 필요한 것 (사용자 준비)
- 구글: OAuth 클라이언트 + SHA-1 + `google-services.json`
- 애플: Apple Developer 멤버십, App ID/Service ID 설정
- 카카오: 네이티브 앱 키, 키해시/번들ID 등록

키를 주시면 위 3개를 실제 연동 코드로 바로 붙여드릴 수 있습니다.
