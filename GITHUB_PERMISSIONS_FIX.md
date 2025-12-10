# GitHub Actions 권한 오류 해결 방법

## 문제
GitHub Actions에서 `github-actions[bot]`이 저장소에 푸시할 권한이 없어서 배포가 실패합니다.

## 해결 방법

### 1단계: 저장소 설정에서 권한 변경

1. **GitHub 저장소로 이동**
   - https://github.com/JINI093/Jfactory

2. **Settings 메뉴 클릭**
   - 저장소 상단의 "Settings" 탭 클릭

3. **Actions 메뉴로 이동**
   - 왼쪽 사이드바에서 "Actions" → "General" 클릭

4. **Workflow permissions 설정**
   - "Workflow permissions" 섹션 찾기
   - **"Read and write permissions"** 선택
   - "Allow GitHub Actions to create and approve pull requests" 체크박스는 선택 해제해도 됩니다
   - **"Save" 버튼 클릭**

### 2단계: 워크플로우 다시 실행

1. **Actions 탭으로 이동**
   - 저장소 상단의 "Actions" 탭 클릭

2. **워크플로우 수동 실행**
   - "Deploy Admin to GitHub Pages" 워크플로우 클릭
   - "Run workflow" 버튼 클릭
   - 브랜치 선택 (main) 후 "Run workflow" 클릭

### 3단계: 배포 확인

배포가 완료되면 (약 3-5분 소요):
- https://jini093.github.io/Jfactory/ (루트)
- https://jini093.github.io/Jfactory/admin/ (관리자 페이지)

## 참고

- 이 설정은 GitHub Actions가 gh-pages 브랜치에 푸시할 수 있도록 권한을 부여합니다.
- 보안상 "Read and write permissions"는 필요한 경우에만 사용하는 것이 좋습니다.
- 이 설정은 저장소 소유자만 변경할 수 있습니다.

