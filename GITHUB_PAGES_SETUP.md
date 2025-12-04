# GitHub Pages 활성화 가이드

## 1단계: GitHub 저장소에서 Pages 활성화

1. **GitHub 저장소로 이동**
   - https://github.com/JINI093/Jfactory

2. **Settings 메뉴 클릭**
   - 저장소 상단의 "Settings" 탭 클릭

3. **Pages 메뉴로 이동**
   - 왼쪽 사이드바에서 "Pages" 클릭

4. **Source 설정**
   - **Source** 섹션에서 **"GitHub Actions"** 선택
   - 저장 (Save 버튼 클릭)

## 2단계: 자동 배포 확인

코드가 이미 푸시되어 있으므로, GitHub Actions가 자동으로 실행됩니다:

1. **Actions 탭 확인**
   - 저장소 상단의 "Actions" 탭 클릭
   - "Deploy Admin to GitHub Pages" 워크플로우가 실행 중인지 확인
   - 약 2-3분 후 완료됩니다

2. **배포 완료 확인**
   - 워크플로우가 성공적으로 완료되면 초록색 체크 표시가 나타납니다

## 3단계: 관리자 페이지 접속

배포가 완료되면 다음 URL에서 관리자 페이지에 접속할 수 있습니다:

**https://jini093.github.io/Jfactory/admin/**

## 문제 해결

### 워크플로우가 실행되지 않는 경우

1. **Actions 탭에서 워크플로우 확인**
   - "Deploy Admin to GitHub Pages" 워크플로우가 있는지 확인
   - 없으면 main 브랜치에 다시 푸시:
   ```bash
   git push origin main
   ```

2. **수동 실행**
   - Actions 탭에서 "Deploy Admin to GitHub Pages" 워크플로우 클릭
   - "Run workflow" 버튼 클릭
   - 브랜치 선택 (main) 후 "Run workflow" 클릭

### 404 오류가 발생하는 경우

1. **Base URL 확인**
   - URL이 `https://jini093.github.io/Jfactory/admin/`인지 확인
   - `/admin/` 경로를 포함해야 합니다

2. **배포 상태 확인**
   - Settings → Pages에서 배포 상태 확인
   - "Your site is live at..." 메시지가 보이는지 확인

### Firebase 연결 오류

Firebase 설정이 올바른지 확인하세요. `lib/admin_main.dart`의 Firebase 설정이 웹 환경에서 작동하는지 확인이 필요합니다.

