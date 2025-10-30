# Firebase Storage 설정 가이드

## Firebase Storage 권한 오류 해결 방법

### 1. Firebase Console에서 Storage Rules 업데이트

1. [Firebase Console](https://console.firebase.google.com)에 접속
2. 프로젝트 선택
3. 왼쪽 메뉴에서 **Storage** 클릭
4. 상단 탭에서 **Rules** 클릭
5. 현재 프로젝트의 `storage.rules` 파일 내용을 복사하여 붙여넣기
6. **Publish** 버튼 클릭

### 2. Firebase CLI로 배포 (권장)

```bash
# Firebase CLI가 설치되어 있지 않다면
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 디렉토리에서 초기화 (이미 되어있다면 건너뛰기)
firebase init storage

# Storage rules 배포
firebase deploy --only storage
```

### 3. 현재 Storage Rules 요약

- **business_licenses/**: 인증된 사용자만 업로드 가능 (10MB 제한)
- **users/{userId}/avatar/**: 본인만 업로드 가능 (5MB 제한)
- **companies/{companyId}/images/**: 인증된 사용자만 업로드 가능 (10MB 제한)
- **companies/{companyId}/logo/**: 인증된 사용자만 업로드 가능 (2MB 제한)
- **posts/{postId}/images/**: 인증된 사용자만 업로드 가능 (10MB 제한)
- **inquiries/{inquiryId}/attachments/**: 인증된 사용자만 업로드 가능 (20MB 제한)

### 4. 주의사항

- Rules 배포 후 몇 분 정도 시간이 걸릴 수 있습니다
- 파일 업로드 시 사용자가 인증되어 있어야 합니다 (`request.auth != null`)
- 이미지 파일만 업로드 가능합니다 (JPEG, PNG, WebP, GIF)
- 파일 크기 제한을 준수해야 합니다

### 5. 테스트 방법

1. 앱에서 기업회원으로 회원가입 시도
2. 사업자등록증 이미지 업로드
3. 오류가 발생하지 않으면 정상적으로 설정된 것입니다

### 6. 추가 보안 설정 (선택사항)

더 강력한 보안을 원한다면:
- 특정 도메인에서만 접근 가능하도록 제한
- IP 주소 기반 접근 제어
- 시간 기반 접근 제어 추가