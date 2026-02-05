# 네이버 로그인 Callback URL 설정 가이드

## 문제
네이버 개발자 센터의 Callback URL이 공백으로 되어 있어 로그인이 실패합니다.

## 중요: Callback URL과 서비스 URL은 다릅니다
- **서비스 URL**: `http://localhost` 같은 웹 URL을 넣는 칸입니다.
- **Callback URL**: **앱 스킴**을 넣는 칸입니다. `http://localhost`를 넣으면 로그인 실패가 계속됩니다.

## 해결 방법

### Android Callback URL 설정

**현재 프로젝트 설정**:
- 패키지명: `vendor.app`

**네이버 개발자 센터에 등록할 Callback URL**:
```
vendor.app://oauth
```

또는

```
naverlogin://oauth
```

**설정 위치**:
1. 네이버 개발자 센터 접속: https://developers.naver.com/apps
2. "j-factory" 앱 선택
3. 플랫폼 설정 → Android 플랫폼 선택
4. "로그인 오픈 API 서비스 환경" 섹션
5. **Callback URL** 필드에 입력

### iOS Callback URL 설정

**현재 프로젝트 설정**:
- Bundle ID: `com.sungmin.vendorads`
- URL Scheme: `naverlogin`

**네이버 개발자 센터에 등록할 Callback URL**:
```
naverlogin://oauth
```

또는

```
com.sungmin.vendorads://oauth
```

**설정 위치**:
1. 네이버 개발자 센터 접속: https://developers.naver.com/apps
2. "j-factory" 앱 선택
3. 플랫폼 설정 → iOS 플랫폼 선택
4. "로그인 오픈 API 서비스 환경" 섹션
5. **Callback URL** 필드에 입력

## flutter_naver_login 패키지 Callback URL 형식

`flutter_naver_login` 패키지는 다음 형식의 Callback URL을 사용합니다:

### Android
- 형식: `{패키지명}://oauth`
- 예시: `vendor.app://oauth`

### iOS
- 형식: `{URL_Scheme}://oauth`
- 예시: `naverlogin://oauth`

## 단계별 설정 방법

### Step 1: Android Callback URL 설정

1. 네이버 개발자 센터 접속
2. 내 애플리케이션 → "j-factory" 선택
3. 플랫폼 설정 → Android 플랫폼
4. "로그인 오픈 API 서비스 환경" 섹션 찾기
5. Callback URL 필드에 다음 중 하나 입력:
   ```
   vendor.app://oauth
   ```
   또는
   ```
   naverlogin://oauth
   ```
6. 저장

### Step 2: iOS Callback URL 설정

1. 네이버 개발자 센터 접속
2. 내 애플리케이션 → "j-factory" 선택
3. 플랫폼 설정 → iOS 플랫폼
4. "로그인 오픈 API 서비스 환경" 섹션 찾기
5. Callback URL 필드에 다음 중 하나 입력:
   ```
   naverlogin://oauth
   ```
   또는
   ```
   com.sungmin.vendorads://oauth
   ```
6. 저장

### Step 3: 앱 재빌드 및 테스트

```bash
# 클린 빌드
flutter clean
flutter pub get

# 앱 재실행
flutter run
```

## 확인 사항

### Android 확인
- [ ] Callback URL이 `vendor.app://oauth` 또는 `naverlogin://oauth`로 설정되어 있는지
- [ ] 패키지명이 `vendor.app`과 일치하는지
- [ ] 서비스 URL도 등록되어 있는지 (최소한 `http://localhost`)

### iOS 확인
- [ ] Callback URL이 `naverlogin://oauth` 또는 `com.sungmin.vendorads://oauth`로 설정되어 있는지
- [ ] Bundle ID가 `com.sungmin.vendorads`와 일치하는지
- [ ] URL Scheme이 `naverlogin`으로 설정되어 있는지

## 참고사항

### 여러 Callback URL 등록
일부 경우 여러 개의 Callback URL을 등록할 수 있습니다:
- `vendor.app://oauth`
- `naverlogin://oauth`

두 개 모두 등록해도 됩니다.

### Callback URL 형식
- `{scheme}://oauth` 형식을 사용합니다
- `oauth`는 고정값입니다
- `{scheme}` 부분은 패키지명(Android) 또는 URL Scheme(iOS)을 사용합니다

## 문제 해결

### 여전히 오류가 발생하는 경우

1. **Callback URL 재확인**
   - 네이버 개발자 센터에서 저장이 제대로 되었는지 확인
   - 공백이나 오타가 없는지 확인

2. **앱 완전 삭제 후 재설치**
   ```bash
   # 기존 앱 삭제
   flutter clean
   
   # 재빌드 및 재설치
   flutter run
   ```

3. **다른 설정도 확인**
   - 패키지명/Bundle ID 일치 확인
   - Client ID/Secret 일치 확인
   - 서비스 URL 등록 확인
   - 테스트 아이디 등록 확인

## 추가 정보

- 네이버 로그인 개발 가이드: https://developers.naver.com/docs/login/overview/
- flutter_naver_login 패키지: https://pub.dev/packages/flutter_naver_login


