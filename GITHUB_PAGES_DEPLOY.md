# GitHub Pages 배포 가이드

## 배포 방법

### 1. GitHub 저장소 설정

1. GitHub 저장소로 이동: https://github.com/osjaeyoung/vendor_ads
2. **Settings** → **Pages** 메뉴로 이동
3. **Source**에서 **GitHub Actions** 선택
4. 저장

### 2. 자동 배포

워크플로우 파일이 생성되었으므로, `main` 또는 `master` 브랜치에 푸시하면 자동으로 배포됩니다:

```bash
git add .
git commit -m "Add GitHub Pages deployment"
git push origin main
```

### 3. 배포 확인

배포가 완료되면 다음 URL에서 확인할 수 있습니다:
- `https://osjaeyoung.github.io/vendor_ads/admin/`

### 4. 수동 배포 (필요시)

로컬에서 빌드하고 수동으로 배포하려면:

```bash
# Flutter 웹 빌드
flutter build web --target lib/admin_main.dart --base-href "/vendor_ads/"

# gh-pages 브랜치에 배포 (gh-pages 브랜치가 있는 경우)
git checkout gh-pages
git rm -rf admin
mkdir admin
cp -r build/web/* admin/
git add admin
git commit -m "Deploy admin page"
git push origin gh-pages
```

## 주의사항

1. **Base URL**: 현재 설정은 `/vendor_ads/` 경로를 사용합니다. 저장소 이름이 다르면 워크플로우 파일의 `--base-href` 값을 수정해야 합니다.

2. **Firebase 설정**: Firebase 설정이 올바르게 되어 있는지 확인하세요.

3. **환경 변수**: 필요한 경우 GitHub Secrets에 환경 변수를 추가하세요.

