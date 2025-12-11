# Firebase App Hosting 비활성화 가이드

현재 Firebase App Hosting이 활성화되어 있어서 자동 빌드가 실패하고 있습니다. 
Firebase Hosting (정적 호스팅)만 사용하도록 App Hosting을 비활성화해야 합니다.

## Firebase Console에서 App Hosting 비활성화

### 1단계: Firebase Console 접속

1. **Firebase Console 접속**
   - https://console.firebase.google.com/
   - `fir-test-96091` 프로젝트 선택

### 2단계: App Hosting 확인 및 비활성화

1. **좌측 메뉴에서 "App Hosting" 클릭**
   - App Hosting이 활성화되어 있다면 목록에 표시됩니다

2. **App Hosting 앱 삭제 (있는 경우)**
   - App Hosting 앱이 있다면 삭제합니다
   - "설정" → "앱 삭제" 또는 "Delete app"

3. **GitHub 연결 해제 (있는 경우)**
   - App Hosting 설정에서 GitHub 저장소 연결이 있다면 해제합니다

### 3단계: Firebase Hosting만 사용 확인

1. **좌측 메뉴에서 "Hosting" 클릭**
   - Hosting이 활성화되어 있는지 확인
   - 활성화되어 있지 않다면 "시작하기" 클릭하여 활성화

2. **Hosting 사이트 확인**
   - 기본 사이트가 생성되어 있는지 확인
   - 사이트 URL: `https://fir-test-96091.web.app`

### 4단계: GitHub Actions 재실행

1. **GitHub 저장소로 이동**
   - https://github.com/JINI093/Jfactory

2. **Actions 탭**
   - "Deploy Admin to Firebase Hosting" 워크플로우 선택
   - "Run workflow" 클릭하여 수동 실행

3. **배포 확인**
   - 약 2-3분 후 배포 완료 확인
   - Firebase Console → Hosting에서 배포 상태 확인

## 문제 해결

### App Hosting이 계속 빌드를 시도하는 경우

1. **Firebase Console → App Hosting**
   - 모든 App Hosting 앱이 삭제되었는지 확인
   - GitHub 연결이 해제되었는지 확인

2. **Firebase Console → 프로젝트 설정 → 통합**
   - GitHub 통합이 있다면 해제

3. **잠시 대기**
   - App Hosting 빌드가 완전히 중지될 때까지 5-10분 대기

### 여전히 App Hosting 빌드가 실행되는 경우

Firebase Console에서 직접 문의하거나, Firebase 지원팀에 문의하세요.

## 참고

- **Firebase Hosting**: 정적 사이트 호스팅 (Flutter 웹 앱에 적합)
- **Firebase App Hosting**: 동적 서버리스 앱 호스팅 (Node.js, Python 등)
- Flutter 웹 앱은 정적 파일이므로 Firebase Hosting만 사용하면 됩니다

