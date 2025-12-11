# Firebase Hosting 배포 설정 가이드

## 1단계: Firebase CLI 토큰 생성

1. **로컬에서 Firebase CLI 설치 및 로그인**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Firebase 토큰 생성**
   ```bash
   firebase login:ci
   ```
   이 명령어를 실행하면 토큰이 생성됩니다. 이 토큰을 복사하세요.

3. **GitHub Secrets에 추가**
   - GitHub 저장소: https://github.com/JINI093/Jfactory
   - Settings → Secrets and variables → Actions
   - "New repository secret" 클릭
   - Name: `FIREBASE_TOKEN`
   - Value: 위에서 복사한 토큰을 붙여넣기
   - "Add secret" 클릭

## 2단계: Firebase Hosting 초기화 (로컬에서)

로컬에서 한 번만 실행하면 됩니다:

```bash
# Firebase CLI 설치 (이미 설치되어 있다면 생략)
npm install -g firebase-tools

# Firebase 로그인
firebase login

# Firebase 프로젝트 확인
firebase use fir-test-96091

# Firebase Hosting 초기화 (이미 설정되어 있다면 생략)
firebase init hosting
```

## 3단계: 자동 배포 확인

코드가 푸시되면 자동으로 Firebase Hosting에 배포됩니다:

1. **GitHub Actions 확인**
   - https://github.com/JINI093/Jfactory/actions
   - "Deploy Admin to Firebase Hosting" 워크플로우 실행 확인

2. **배포 완료 대기**
   - 약 2-3분 소요
   - 완료되면 초록색 체크 표시

3. **접속 확인**
   - Firebase Console → Hosting에서 배포 URL 확인
   - 또는 `https://fir-test-96091.web.app` 또는 `https://fir-test-96091.firebaseapp.com`

## 4단계: 커스텀 도메인 설정 (선택사항)

1. **Firebase Console → Hosting**
   - "도메인 추가" 클릭
   - 원하는 도메인 입력
   - DNS 설정 안내에 따라 도메인 설정

## 문제 해결

### Firebase Service Account 오류

- JSON 파일의 전체 내용이 올바르게 복사되었는지 확인
- GitHub Secrets에 `FIREBASE_SERVICE_ACCOUNT` 이름이 정확한지 확인

### 배포 권한 오류

- Firebase Console → 프로젝트 설정 → 사용자 및 권한
- 현재 계정에 "Firebase Admin" 권한이 있는지 확인

### 빌드 오류

- GitHub Actions 로그 확인
- Flutter 버전 호환성 확인

## 수동 배포 (필요시)

로컬에서 수동으로 배포하려면:

```bash
# Flutter 웹 빌드
flutter build web --target lib/admin_main.dart --base-href "/"

# Firebase 배포
firebase deploy --only hosting
```

## 참고

- Firebase Hosting은 무료로 제공됩니다
- 자동 HTTPS 지원
- 글로벌 CDN 제공
- 커스텀 도메인 지원

