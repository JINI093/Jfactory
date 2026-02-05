# 네이버 로그인 설정 확인 체크리스트

## 현재 프로젝트 설정값

### Android 설정
- **패키지명**: `vendor.app` ✅ (build.gradle.kts에서 확인)
- **Client ID**: `6VBjy8uAYG4OQuVORB0s`
- **Client Secret**: `2IwucUmbaX`
- **Client Name**: `제작소`
- **설정 파일**: `android/app/src/main/res/values/strings.xml`
- **AndroidManifest.xml**: 네이버 로그인 Activity 및 Meta-data 설정됨 ✅

### iOS 설정
- **Bundle ID**: `com.sungmin.vendorads`
- **URL Scheme**: `naverlogin`
- **Client ID**: `0Yn_U4Zvuccup1dIyQAi`
- **Client Secret**: `PYehz3hond`
- **Client Name**: `제작소`
- **설정 파일**: `ios/Runner/Info.plist`
- **CFBundleURLTypes**: `naverlogin` 스킴 등록됨 ✅

---

## 1. 네이버 개발자 센터 설정 확인

### 1-1. Android/iOS 패키지명 확인

#### Android 패키지명 확인

**현재 설정값**:
- **실제 앱의 패키지명**: `vendor.app`
- **확인 위치**: `android/app/build.gradle.kts` (line 27: `applicationId = "vendor.app"`)

**확인 사항**:
- [ ] 네이버 개발자 센터의 Android 플랫폼에 등록된 패키지명
- [ ] 실제 앱의 `applicationId`: `vendor.app`
- [ ] 두 값이 **정확히 일치**하는지 (대소문자 구분)

#### iOS Bundle ID 확인
- **현재 설정**: `com.sungmin.vendorads`
- **확인 위치**: `ios/Runner.xcodeproj/project.pbxproj` (PRODUCT_BUNDLE_IDENTIFIER)

**확인 사항**:
- [ ] 네이버 개발자 센터의 iOS 플랫폼에 등록된 Bundle ID
- [ ] 실제 앱의 Bundle ID: `com.sungmin.vendorads`
- [ ] 두 값이 **정확히 일치**하는지

### 1-2. iOS URL Scheme 확인

**현재 설정**:
- **Info.plist**: `naverlogin`
- **NidUrlScheme**: `naverlogin`
- **CFBundleURLTypes**: `naverlogin` 등록됨 ✅

**확인 사항**:
- [ ] 네이버 개발자 센터의 iOS 플랫폼 URL Scheme
- [ ] 실제 앱의 URL Scheme: `naverlogin`
- [ ] 두 값이 **정확히 일치**하는지

### 1-3. Callback URL 확인

**flutter_naver_login 패키지 요구사항**:
- Android: 패키지명 기반 자동 처리
- iOS: URL Scheme 기반 자동 처리

**확인 사항**:
- [ ] Android: 패키지명이 정확히 등록되어 있는지
- [ ] iOS: URL Scheme이 정확히 등록되어 있는지
- [ ] 네이버 개발자 센터에 Callback URL이 올바르게 설정되어 있는지

### 1-4. 서비스 URL 확인 (중요!)

**Android 플랫폼 필수 설정**:
- [ ] 서비스 URL이 등록되어 있는지 확인
- 최소한 `http://localhost`라도 등록 필요
- 서비스 URL이 없으면 "서비스 설정에 오류가 있습니다" 오류 발생

**확인 위치**:
- 네이버 개발자 센터 → 내 애플리케이션 → j-factory → 플랫폼 설정 → Android → 서비스 URL

---

## 2. 클라이언트 ID 및 Secret 확인

### 2-1. Android 설정 확인

**프로젝트 설정값**:
```
Client ID: 6VBjy8uAYG4OQuVORB0s
Client Secret: 2IwucUmbaX
```

**확인 사항**:
- [ ] 네이버 개발자 센터의 Android 플랫폼 Client ID
- [ ] 실제 코드의 Client ID: `6VBjy8uAYG4OQuVORB0s`
- [ ] 두 값이 **정확히 일치**하는지 (공백, 오타 없이)
- [ ] 네이버 개발자 센터의 Android 플랫폼 Client Secret
- [ ] 실제 코드의 Client Secret: `2IwucUmbaX`
- [ ] 두 값이 **정확히 일치**하는지

**설정 파일 위치**:
- `android/app/src/main/res/values/strings.xml`
- `android/app/src/main/AndroidManifest.xml` (Meta-data로 참조)

### 2-2. iOS 설정 확인

**프로젝트 설정값**:
```
Client ID: 0Yn_U4Zvuccup1dIyQAi
Client Secret: PYehz3hond
```

**확인 사항**:
- [ ] 네이버 개발자 센터의 iOS 플랫폼 Client ID
- [ ] 실제 코드의 Client ID: `0Yn_U4Zvuccup1dIyQAi`
- [ ] 두 값이 **정확히 일치**하는지 (공백, 오타 없이)
- [ ] 네이버 개발자 센터의 iOS 플랫폼 Client Secret
- [ ] 실제 코드의 Client Secret: `PYehz3hond`
- [ ] 두 값이 **정확히 일치**하는지

**설정 파일 위치**:
- `ios/Runner/Info.plist` (NAVER_CLIENT_ID, NAVER_CLIENT_SECRET, NidClientID, NidClientSecret)

---

## 3. 테스트 계정 등록 여부

### 3-1. 테스트 아이디 확인

**중요**: 네이버 로그인은 '애플리케이션 검수'를 받기 전에는 아무 계정으로나 로그인할 수 없습니다.

**확인 위치**:
- 네이버 개발자 센터 → 내 애플리케이션 → j-factory → 멤버 관리 → 테스트 아이디

**확인 사항**:
- [ ] 관리자 본인 계정이 자동으로 등록되어 있는지
- [ ] 테스트할 다른 계정이 등록되어 있는지
- [ ] 로그인하려는 계정이 테스트 아이디로 등록되어 있는지

**테스트 아이디 추가 방법**:
1. 네이버 개발자 센터 접속
2. 내 애플리케이션 → j-factory 선택
3. 멤버 관리 → 테스트 아이디 메뉴
4. 테스트할 네이버 ID 추가

---

## 4. API 권한 설정

### 4-1. 필수 권한 확인

**네이버 로그인에서 사용하는 정보**:
- 회원 이름 (name)
- 이메일 (email)
- 전화번호 (mobile)

**확인 위치**:
- 네이버 개발자 센터 → 내 애플리케이션 → j-factory → API 설정 → 로그인 오픈 API 서비스 환경

**확인 사항**:
- [ ] 회원 이름 권한이 '필수' 또는 '추가'로 체크되어 있는지
- [ ] 이메일 권한이 '필수' 또는 '추가'로 체크되어 있는지
- [ ] 전화번호 권한이 '필수' 또는 '추가'로 체크되어 있는지
- [ ] 코드에서 요청하는 정보와 설정이 일치하는지

**현재 코드에서 요청하는 정보**:
```dart
// lib/data/datasources/firebase_auth_datasource.dart
final String email = account.email ?? '${account.id}@naver.local';
final String name = account.name ?? account.nickname ?? 'Naver User';
final String phone = account.mobile ?? '';
```

---

## 5. 추가 확인 사항

### 5-1. 앱 상태 확인
- [ ] 앱 상태가 "개발중" 또는 "서비스 중"인지 확인
- "개발중" 상태에서도 사용 가능하지만, 설정이 정확해야 함

### 5-2. 플랫폼 등록 확인
- [ ] Android 플랫폼이 등록되어 있는지
- [ ] iOS 플랫폼이 등록되어 있는지
- [ ] 사용하는 플랫폼이 모두 등록되어 있는지

### 5-3. 앱 이름 확인
- [ ] 네이버 개발자 센터의 앱 이름: "j-factory"
- [ ] 오류 메시지에 표시되는 앱 이름과 일치하는지

---

## 확인 순서

1. **먼저 확인**: Android 패키지명 (`vendor.app`) - 네이버 개발자 센터와 일치하는지 확인
2. **서비스 URL 등록**: Android 플랫폼에 서비스 URL이 등록되어 있는지 확인 (가장 중요!)
3. **Client ID/Secret**: 네이버 개발자 센터와 코드의 값이 일치하는지 확인
4. **테스트 아이디**: 로그인하려는 계정이 테스트 아이디로 등록되어 있는지 확인
5. **API 권한**: 필요한 권한(이름, 이메일, 전화번호)이 체크되어 있는지 확인
6. **Bundle ID/URL Scheme**: iOS 설정이 일치하는지 확인

---

## 문제 해결 단계

### Step 1: Android 패키지명 확인
**현재 설정값**: `vendor.app`

**확인 방법**:
- 네이버 개발자 센터 → 내 애플리케이션 → j-factory → 플랫폼 설정 → Android
- 등록된 패키지명이 `vendor.app`과 정확히 일치하는지 확인

### Step 2: 네이버 개발자 센터 접속
1. https://developers.naver.com/apps 접속
2. "j-factory" 앱 선택
3. 플랫폼 설정 탭 확인

### Step 3: 각 항목 확인
- Android 패키지명 일치 확인
- 서비스 URL 등록 확인 (필수!)
- Client ID/Secret 일치 확인
- 테스트 아이디 등록 확인
- API 권한 확인

### Step 4: 설정 변경 후
```bash
# 앱 재빌드
flutter clean
flutter pub get
flutter run
```

---

## 참고 자료
- 네이버 로그인 개발 가이드: https://developers.naver.com/docs/login/overview/
- flutter_naver_login 패키지: https://pub.dev/packages/flutter_naver_login
- 네이버 로그인 트러블슈팅: `NAVER_LOGIN_TROUBLESHOOTING.md`

