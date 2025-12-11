# GitHub Pages 캐시 문제 해결 가이드

## 문제
GitHub Pages가 배포되었지만 홈페이지가 업데이트되지 않는 경우

## 해결 방법

### 1. 브라우저 캐시 클리어

1. **Chrome/Edge:**
   - `Ctrl + Shift + Delete` (Windows) 또는 `Cmd + Shift + Delete` (Mac)
   - "캐시된 이미지 및 파일" 선택
   - "데이터 삭제" 클릭

2. **강력 새로고침:**
   - `Ctrl + Shift + R` (Windows) 또는 `Cmd + Shift + R` (Mac)
   - 또는 `Ctrl + F5` (Windows)

3. **시크릿 모드에서 확인:**
   - 시크릿/프라이빗 브라우징 모드에서 페이지 열기

### 2. GitHub Pages 캐시 확인

1. **배포 상태 확인:**
   - https://github.com/JINI093/Jfactory/settings/pages
   - "Last deployed" 시간 확인
   - 최근에 배포되었다면 GitHub의 CDN 캐시 때문일 수 있습니다

2. **강제 재배포:**
   - GitHub Actions에서 워크플로우 수동 실행
   - 또는 코드에 작은 변경사항을 추가하고 푸시

### 3. 배포된 파일 확인

1. **gh-pages 브랜치 확인:**
   - https://github.com/JINI093/Jfactory/tree/gh-pages
   - 최신 파일이 배포되었는지 확인

2. **직접 파일 확인:**
   - https://jini093.github.io/Jfactory/index.html
   - https://jini093.github.io/Jfactory/deploy.txt (배포 시간 확인)

### 4. CDN 캐시 대기

GitHub Pages는 CDN을 사용하므로:
- 배포 후 최대 10-15분 정도 기다려야 할 수 있습니다
- 전 세계 서버에 캐시가 업데이트되는 데 시간이 걸립니다

### 5. 수동 캐시 무효화

URL에 쿼리 파라미터 추가:
- `https://jini093.github.io/Jfactory/?v=2`
- 또는 `https://jini093.github.io/Jfactory/?t=1234567890`

## 확인 사항

- [ ] 브라우저 캐시 클리어 완료
- [ ] 강력 새로고침 시도
- [ ] 시크릿 모드에서 확인
- [ ] GitHub Actions 배포 성공 확인
- [ ] gh-pages 브랜치에 최신 파일 확인
- [ ] 10-15분 대기 후 다시 확인

## 추가 도움

문제가 계속되면:
1. 브라우저 개발자 도구(F12) 열기
2. Network 탭에서 파일 로드 상태 확인
3. Console 탭에서 오류 메시지 확인
4. Application 탭에서 캐시 상태 확인

