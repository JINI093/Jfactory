# 네이버 로그인 설정 가이드

"서비스설정에 오류가 있습니다" 오류가 발생하는 경우, 네이버 개발자 센터에서 앱 설정을 확인해야 합니다.

## 1. 네이버 개발자 센터 접속
https://developers.naver.com/apps/#/list

## 2. 앱 등록 확인

### Android 설정
1. **애플리케이션 등록** → **Android 플랫폼 추가**
2. **패키지명** 확인:
   - `android/app/build.gradle`에서 `applicationId` 확인
   - 예: `com.example.vendor_ads`
3. **서비스 URL** 등록:
   - 개발: `http://localhost`
   - 운영: 실제 서비스 URL
   - **주의**: 서비스 URL은 웹 URL, **Callback URL은 앱 스킴**입니다.
4. **Client ID** 및 **Client Secret** 확인:
   - `android/app/src/main/res/values/strings.xml`의 값과 일치해야 함
   - 현재 설정:
     - Client ID: `6VBjy8uAYG4OQuVORB0s`
     - Client Secret: `2IwucUmbaX`

### iOS 설정
1. **애플리케이션 등록** → **iOS 플랫폼 추가**
2. **Bundle ID** 확인:
   - Xcode에서 확인하거나 `ios/Runner.xcodeproj` 확인
   - 예: `com.example.vendorAds`
3. **URL Scheme** 확인:
   - `ios/Runner/Info.plist`의 `NidUrlScheme`과 일치해야 함
   - 현재: `naverlogin`
4. **Client ID** 및 **Client Secret** 확인:
   - `ios/Runner/Info.plist`의 값과 일치해야 함
   - 현재 설정:
     - Client ID: `0Yn_U4Zvuccup1dIyQAi`
     - Client Secret: `PYehz3hond`

## 3. 확인 사항

### 필수 확인 항목
- [ ] Android/iOS 플랫폼이 모두 등록되어 있는지
- [ ] 패키지명/Bundle ID가 정확히 일치하는지
- [ ] 서비스 URL이 등록되어 있는지
- [ ] Client ID/Secret이 코드와 일치하는지
- [ ] 앱 상태가 "서비스 중"인지

### Android 추가 확인
- [ ] `AndroidManifest.xml`에 네이버 로그인 Activity가 등록되어 있는지
- [ ] `strings.xml`에 Client ID/Secret이 올바르게 설정되어 있는지

### iOS 추가 확인
- [ ] `Info.plist`에 `NidClientID`, `NidClientSecret`, `NidUrlScheme`이 설정되어 있는지
- [ ] `CFBundleURLTypes`에 `naverlogin` 스킴이 등록되어 있는지

## 4. 문제 해결

### "서비스설정에 오류가 있습니다" 오류
1. 네이버 개발자 센터에서 앱 설정 확인
2. 패키지명/Bundle ID 재확인
3. 서비스 URL 등록 확인
4. 앱 재빌드 및 재설치

### 로그인은 되지만 Firebase 연동 실패
- 네이버 로그인은 성공했지만 Firebase Auth 연동이 실패하는 경우
- 이메일/비밀번호 방식으로 변환하는 로직 확인 필요

## 5. 테스트

### Android 테스트
```bash
flutter run
```

### iOS 테스트
```bash
flutter run
```

로그인 시도 후 콘솔에 출력되는 디버그 메시지를 확인하세요.

## 6. 참고 자료
- 네이버 로그인 개발 가이드: https://developers.naver.com/docs/login/overview/
- flutter_naver_login 패키지: https://pub.dev/packages/flutter_naver_login

