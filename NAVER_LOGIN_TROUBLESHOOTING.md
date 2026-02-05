# 네이버 로그인 "서비스 설정에 오류가 있어" 오류 해결 가이드

## 오류 메시지
```
j-factory 서비스 설정에 오류가 있어 네이버 아이디로 로그인할 수 없습니다.
```

## 확인해야 할 사항 (우선순위 순)

### 1. 네이버 개발자 센터 접속 및 앱 확인
**URL**: https://developers.naver.com/apps/#/list

- [ ] "j-factory" 앱이 등록되어 있는지 확인
- [ ] 앱 상태가 **"서비스 중"**인지 확인 (개발 중/심사 중이면 안 됨)
- [ ] 앱 이름이 정확히 "j-factory"인지 확인

### 2. Android 플랫폼 설정 확인

#### 2-1. 패키지명 확인
1. **네이버 개발자 센터**에서 Android 플랫폼 설정 확인
2. **등록된 패키지명** 확인
3. **실제 앱의 패키지명** 확인:
   ```bash
   # Android Studio에서 확인하거나
   # android/app/build.gradle 파일에서 applicationId 확인
   ```
4. 두 값이 **정확히 일치**해야 합니다 (대소문자 구분)

#### 2-2. 서비스 URL 확인
- [ ] **서비스 URL**이 등록되어 있는지 확인
- 개발 환경: `http://localhost` 또는 실제 개발 서버 URL
- 운영 환경: 실제 서비스 URL
- **서비스 URL이 없으면 오류 발생**

#### 2-3. Client ID/Secret 확인
**현재 코드 설정** (`android/app/src/main/res/values/strings.xml`):
- Client ID: `6VBjy8uAYG4OQuVORB0s`
- Client Secret: `2IwucUmbaX`
- Client Name: `제작소`

**확인 사항**:
- [ ] 네이버 개발자 센터의 Android 플랫폼 Client ID가 `6VBjy8uAYG4OQuVORB0s`와 일치하는지
- [ ] 네이버 개발자 센터의 Android 플랫폼 Client Secret이 `2IwucUmbaX`와 일치하는지

### 3. iOS 플랫폼 설정 확인

#### 3-1. Bundle ID 확인
**실제 앱의 Bundle ID**: `com.sungmin.vendorads`

1. **네이버 개발자 센터**에서 iOS 플랫폼 설정 확인
2. **등록된 Bundle ID**가 `com.sungmin.vendorads`와 **정확히 일치**하는지 확인
3. 대소문자까지 정확히 일치해야 합니다

#### 3-2. URL Scheme 확인
**현재 설정** (`ios/Runner/Info.plist`):
- URL Scheme: `naverlogin`

**확인 사항**:
- [ ] 네이버 개발자 센터의 iOS 플랫폼 URL Scheme이 `naverlogin`과 일치하는지
- [ ] `Info.plist`의 `CFBundleURLTypes`에 `naverlogin` 스킴이 등록되어 있는지

#### 3-3. Client ID/Secret 확인
**현재 코드 설정** (`ios/Runner/Info.plist`):
- Client ID: `0Yn_U4Zvuccup1dIyQAi`
- Client Secret: `PYehz3hond`

**확인 사항**:
- [ ] 네이버 개발자 센터의 iOS 플랫폼 Client ID가 `0Yn_U4Zvuccup1dIyQAi`와 일치하는지
- [ ] 네이버 개발자 센터의 iOS 플랫폼 Client Secret이 `PYehz3hond`와 일치하는지

### 4. AndroidManifest.xml 확인

**파일 위치**: `android/app/src/main/AndroidManifest.xml`

**확인 사항**:
- [ ] 네이버 로그인 Activity가 등록되어 있는지:
  ```xml
  <activity
      android:name="com.nhn.android.naverlogin.ui.view.OAuthLoginActivity"
      android:theme="@android:style/Theme.Translucent.NoTitleBar" />
  ```
- [ ] Meta-data가 올바르게 설정되어 있는지:
  ```xml
  <meta-data
      android:name="com.naver.sdk.clientId"
      android:value="@string/naver_client_id" />
  <meta-data
      android:name="com.naver.sdk.clientSecret"
      android:value="@string/naver_client_secret" />
  ```

### 5. Info.plist 확인 (iOS)

**파일 위치**: `ios/Runner/Info.plist`

**확인 사항**:
- [ ] `NAVER_CLIENT_ID`가 설정되어 있는지
- [ ] `NAVER_CLIENT_SECRET`이 설정되어 있는지
- [ ] `NidUrlScheme`이 `naverlogin`으로 설정되어 있는지
- [ ] `CFBundleURLTypes`에 `naverlogin` 스킴이 등록되어 있는지

### 6. 앱 재빌드 및 재설치

설정을 변경한 후:
1. **앱 완전 삭제** (기존 앱 제거)
2. **클린 빌드**:
   ```bash
   flutter clean
   flutter pub get
   ```
3. **앱 재빌드 및 재설치**:
   ```bash
   flutter run
   ```

## 일반적인 오류 원인

### 1. 패키지명/Bundle ID 불일치
- **가장 흔한 원인**
- 네이버 개발자 센터에 등록된 값과 실제 앱의 값이 다름
- 대소문자까지 정확히 일치해야 함

### 2. 서비스 URL 미등록
- Android 플랫폼에 서비스 URL이 등록되지 않음
- 최소한 `http://localhost`라도 등록 필요

### 3. 앱 상태 문제
- 앱이 "개발 중" 또는 "심사 중" 상태
- "서비스 중" 상태로 변경 필요

### 4. Client ID/Secret 불일치
- 네이버 개발자 센터의 값과 코드의 값이 다름
- Android와 iOS가 서로 다른 Client ID를 사용하는 경우 확인 필요

### 5. 플랫폼 미등록
- Android 또는 iOS 플랫폼이 등록되지 않음
- 사용하는 플랫폼(Android/iOS)이 모두 등록되어 있어야 함

## 단계별 해결 방법

### Step 1: 네이버 개발자 센터 확인
1. https://developers.naver.com/apps/#/list 접속
2. "j-factory" 앱 선택
3. **애플리케이션 정보** 탭에서 앱 상태 확인
4. **플랫폼 설정** 탭에서 Android/iOS 설정 확인

### Step 2: 패키지명/Bundle ID 확인
- **Android**: 네이버 개발자 센터의 패키지명과 `android/app/build.gradle`의 `applicationId` 비교
- **iOS**: 네이버 개발자 센터의 Bundle ID와 `ios/Runner.xcodeproj/project.pbxproj`의 `PRODUCT_BUNDLE_IDENTIFIER` 비교

### Step 3: 서비스 URL 등록
- Android 플랫폼 설정에서 **서비스 URL** 추가
- 개발 환경: `http://localhost`
- 운영 환경: 실제 서비스 URL

### Step 4: Client ID/Secret 재확인
- 네이버 개발자 센터에서 **새로운 Client ID/Secret 생성** (필요시)
- 코드의 값과 일치하도록 수정

### Step 5: 앱 재빌드
```bash
flutter clean
flutter pub get
flutter run
```

## 추가 확인 사항

### 네이버 로그인 API 사용량 확인
- 네이버 개발자 센터에서 API 사용량 확인
- 일일 사용량 제한 초과 여부 확인

### 네트워크 연결 확인
- 인터넷 연결 상태 확인
- 방화벽이나 VPN으로 인한 차단 여부 확인

### 디버그 로그 확인
앱 실행 시 콘솔에 출력되는 로그 확인:
```
🔥 Starting Naver login process...
🔥 Naver login result received: ...
🔥 Naver account info: ...
```

## 문의 및 지원

위의 방법으로도 해결되지 않으면:
1. 네이버 개발자 센터 고객지원 문의
2. 네이버 로그인 개발자 포럼: https://developers.naver.com/forum

## 참고 자료
- 네이버 로그인 개발 가이드: https://developers.naver.com/docs/login/overview/
- flutter_naver_login 패키지: https://pub.dev/packages/flutter_naver_login

