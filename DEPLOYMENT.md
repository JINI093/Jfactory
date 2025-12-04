# GitHub Pages 배포 가이드

## 배포 단계

### 1. GitHub 저장소 설정

1. GitHub 저장소로 이동: https://github.com/osjaeyoung/vendor_ads
2. **Settings** → **Pages** 메뉴로 이동
3. **Source**에서 **GitHub Actions** 선택
4. 저장

### 2. 코드 푸시 및 자동 배포

현재 브랜치가 `develop`이므로, 다음 명령어로 푸시하면 자동으로 배포됩니다:

```bash
git add .
git commit -m "Add GitHub Pages deployment workflow"
git push origin develop
```

또는 `main` 브랜치로 푸시:

```bash
git checkout main
git merge develop
git push origin main
```

### 3. 배포 확인

배포가 완료되면 (약 2-3분 소요) 다음 URL에서 확인할 수 있습니다:
- `https://osjaeyoung.github.io/vendor_ads/admin/`

### 4. 배포 상태 확인

1. GitHub 저장소의 **Actions** 탭에서 배포 진행 상황 확인
2. 배포가 완료되면 초록색 체크 표시가 나타납니다

## 문제 해결

### Base URL 오류가 발생하는 경우

저장소 이름이 `vendor_ads`가 아닌 경우, `.github/workflows/deploy-admin.yml` 파일의 다음 줄을 수정하세요:

```yaml
run: flutter build web --target lib/admin_main.dart --base-href "/저장소이름/"
```

그리고 `destination_dir`도 필요시 수정:

```yaml
destination_dir: ./admin
```

### Firebase 연결 오류

Firebase 설정이 올바른지 확인하세요. `lib/admin_main.dart`의 Firebase 설정이 웹 환경에서 작동하는지 확인이 필요합니다.

## 수동 배포 (필요시)

로컬에서 빌드하고 수동으로 배포하려면:

```bash
# Flutter 웹 빌드
flutter build web --target lib/admin_main.dart --base-href "/vendor_ads/"

# gh-pages 브랜치 생성 및 배포
git checkout --orphan gh-pages
git rm -rf .
mkdir admin
cp -r build/web/* admin/
git add admin
git commit -m "Deploy admin page"
git push origin gh-pages --force
```

