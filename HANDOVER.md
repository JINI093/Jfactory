# 제작소 (Vendor Ads) 인수인계 문서

## 📋 문서 목차
1. [프로젝트 개요](#1-프로젝트-개요)
2. [개발 환경 설정](#2-개발-환경-설정)
3. [Firebase 데이터베이스 스키마](#3-firebase-데이터베이스-스키마)
4. [주요 기능 및 플로우](#4-주요-기능-및-플로우)
5. [서비스 연동 정보](#5-서비스-연동-정보)
6. [배포 및 운영](#6-배포-및-운영)
7. [코드베이스 주요 파일](#7-코드베이스-주요-파일)
8. [트러블슈팅](#8-트러블슈팅)
9. [알아두면 좋은 정보](#9-알아두면-좋은-정보)

---

## 1. 프로젝트 개요

### 1.1 프로젝트 정보
- **프로젝트명**: 제작소 (Vendor Ads)
- **플랫폼**: Android, iOS, Web (관리자 페이지)
- **프레임워크**: Flutter 3.10.0+
- **백엔드**: Firebase (Firestore, Storage, Auth)
- **아키텍처**: Clean Architecture

### 1.2 주요 기능
- 사용자 인증 (이메일, Google, Kakao, Naver, Apple)
- 기업 정보 등록 및 관리
- 게시글 작성 및 관리 (기업 회원만)
- 카테고리별 기업 검색
- 지도 기반 기업 검색
- 광고 결제 시스템 (1일 3천원)
- 관리자 페이지 (웹)

### 1.3 사용자 유형
- **개인 회원**: 기업 정보 조회, 좋아요, 게시글 조회만 가능
- **기업 회원**: 기업 정보 등록/수정, 게시글 작성 가능
- **관리자**: 모든 기능 관리 (웹 페이지)

---

## 2. 개발 환경 설정

### 2.1 필수 요구사항
```bash
# Flutter SDK
Flutter >= 3.10.0
Dart >= 3.0.0 < 4.0.0

# 개발 도구
Android Studio / VS Code
Xcode (iOS 개발 시)
```

### 2.2 초기 설정

#### 1) 저장소 클론 및 의존성 설치
```bash
git clone <repository-url>
cd vendor_ads
flutter pub get
```

#### 2) 환경 변수 설정
`.env` 파일 생성 (프로젝트 루트):
```env
# Firebase (필요시)
FIREBASE_API_KEY=your_api_key

# 네이버 지도 (필요시)
Naver_Maps_Client_ID=your_client_id
```

#### 3) Firebase 설정
- **프로젝트**: `fir-test-96091`
- **Android**: `android/app/google-services.json` 확인
- **iOS**: `ios/Runner/GoogleService-Info.plist` 확인
- **Web**: `firebase_options.dart` 확인

#### 4) 소셜 로그인 설정

**Google 로그인**
- `google-services.json` 파일 확인
- Firebase Console에서 OAuth 클라이언트 ID 확인

**Kakao 로그인**
- 네이티브 앱 키: `a22df9f48c7bd192fa4cc21ee0e8f923`
- `lib/main.dart`에서 확인 가능

**Naver 로그인**
- Android Client ID: `6VBjy8uAYG4OQuVORB0s`
- Android Client Secret: `2IwucUmbaX`
- iOS Client ID: `0Yn_U4Zvuccup1dIyQAi`
- iOS Client Secret: `PYehz3hond`
- 네이버 개발자 센터 설정 확인 필수 (패키지명, Bundle ID, 서비스 URL)

**Apple 로그인**
- Apple Developer 설정 확인
- `Info.plist` 설정 확인

### 2.3 실행 방법
```bash
# 개발 모드
flutter run

# 특정 플랫폼
flutter run -d android
flutter run -d ios

# 관리자 페이지 (웹)
flutter run -d chrome --target lib/admin_main.dart
```

---

## 3. Firebase 데이터베이스 스키마

### 3.1 Firestore Collections

#### `users` Collection
```dart
{
  uid: String,                    // Firebase Auth UID
  email: String,
  name: String,
  phone: String,
  userType: String,                // 'individual' | 'company'
  createdAt: Timestamp,
  companyName: String?,            // 기업 회원인 경우
  businessLicense: String?,        // 사업자등록증 URL
  isApproved: Boolean,             // 기업 회원 승인 여부 (기본값: true)
  provider: String?,               // 가입 경로 ('email', 'google', 'kakao', 'naver', 'apple')
}
```

#### `companies` Collection
```dart
{
  id: String,                      // userId와 동일
  companyName: String,
  ceoName: String,
  phone: String,
  email: String?,
  address: String,
  detailAddress: String,
  category: String,                // 예: '기계제작', 'MALL'
  subcategory: String,             // 예: '가공1', '베어링/철강'
  subSubcategory: String?,         // 예: '선반/밀링'
  latitude: Double?,
  longitude: Double?,
  website: String?,
  homepage: String?,
  greeting: String?,
  history: String?,
  clients: List<String>?,          // 주요 거래처
  features: List<String>?,        // 특징
  photos: List<String>?,           // 회사 사진
  logo: String?,                   // 회사 로고
  businessLicense: String?,        // 사업자등록증
  adPayment: Double,               // 광고비 (기본값: 0)
  isPremium: Boolean,              // 프리미엄 광고 여부
  isVerified: Boolean,             // 인증 여부
  createdAt: Timestamp,
  updatedAt: Timestamp?,
  adExpiryDate: Timestamp?,        // 광고 만료일
}
```

#### `posts` Collection
```dart
{
  id: String,
  companyId: String,               // users collection의 uid
  title: String,
  content: String,
  equipmentName: String?,          // 장비명
  category: String?,
  subcategory: String?,
  subSubcategory: String?,
  manufacturer: String?,           // 제조사
  model: String?,                  // 모델명
  quantity: String?,               // 수량
  basicSpecs: String?,             // 기본 사양
  dimensionX: String?,
  dimensionY: String?,
  dimensionZ: String?,
  weight: String?,
  tableSize: String?,
  features: String?,               // 특징
  industry: String?,
  machiningCenter: String?,
  images: List<String>,            // 이미지 URL 리스트
  status: String,                  // 'draft' | 'published' | 'hidden' | 'deleted'
  isPremium: Boolean,              // 프리미엄 게시글 여부
  premiumExpiryDate: Timestamp?,
  viewCount: Int,                  // 조회수
  createdAt: Timestamp,
  updatedAt: Timestamp?,
}
```

#### `purchases` Collection
```dart
{
  id: String,
  userId: String,
  companyId: String,
  purchaseType: String,            // 'premiumAd' | 'basicAd'
  amount: Double,                  // 결제 금액
  status: String,                  // 'pending' | 'active' | 'expired'
  purchaseDate: Timestamp,
  expiryDate: Timestamp?,
  adName: String?,
  createdAt: Timestamp,
}
```

#### `inquiries` Collection
```dart
{
  id: String,
  userId: String,
  companyId: String?,
  title: String,
  content: String,
  answer: String?,                 // 관리자 답변
  answeredAt: Timestamp?,
  createdAt: Timestamp,
  updatedAt: Timestamp?,
}
```

#### `favorites` Collection
```dart
{
  id: String,
  userId: String,
  companyId: String,
  createdAt: Timestamp,
}
```

#### `faqs` Collection
```dart
{
  id: String,
  title: String,
  content: String,
  createdAt: Timestamp,
  updatedAt: Timestamp?,
}
```

### 3.2 Firebase Storage 구조
```
storage/
├── users/
│   └── {userId}/
│       └── profile.jpg
├── companies/
│   └── {companyId}/
│       ├── photos/
│       │   └── {photoId}.jpg
│       ├── logo.jpg
│       └── business_license.pdf
└── posts/
    └── {postId}/
        └── {imageId}.jpg
```

### 3.3 Firestore 인덱스
다음 쿼리를 사용하는 경우 인덱스가 필요할 수 있습니다:
- `companies`: `category`, `subcategory`, `subSubcategory` 필터링
- `posts`: `companyId`, `isPremium`, `createdAt` 정렬
- `inquiries`: `userId`, `createdAt` 정렬

Firebase Console에서 인덱스 생성 요청이 오면 자동으로 생성하거나 수동으로 생성해야 합니다.

---

## 4. 주요 기능 및 플로우

### 4.1 사용자 인증 플로우

#### 회원가입
1. 로그인 화면 → 회원가입
2. 이용약관 동의
3. 회원 정보 입력 (이메일, 비밀번호, 이름, 전화번호)
4. 핸드폰 본인인증 (Firebase Phone Auth)
5. 회원구분 선택 (개인/기업)
6. 기업 회원인 경우 기업 정보 입력
7. Firestore에 사용자 정보 저장 (`isApproved: true` 자동 설정)

#### 소셜 로그인
- Google, Kakao, Naver, Apple 로그인 지원
- 소셜 로그인 성공 후 Firestore에 사용자 정보 저장
- `provider` 필드에 가입 경로 저장

### 4.2 기업 정보 관리

#### 기업 정보 등록
- 경로: 마이페이지 → 기업정보 → 등록
- 필수 항목: 기업명, 대표자명, 전화번호, 주소, 카테고리
- 선택 항목: 홈페이지, 인사말, 연혁, 주요 거래처, 특징, 사진, 로고, 사업자등록증

#### 기업 정보 수정
- 기업 회원만 수정 가능
- 이미지 업로드는 Firebase Storage에 저장
- 수정 후 `updatedAt` 필드 업데이트

### 4.3 게시글 관리

#### 게시글 작성
- **권한**: 기업 회원만 작성 가능
- 일반 회원은 게시글 작성 불가 (라우터에서 차단)
- 경로: 마이페이지 → 게시글 등록
- 필수 항목: 제목, 내용, 카테고리
- 선택 항목: 장비명, 제조사, 모델, 사양, 이미지 등

#### 게시글 조회
- 게시글 클릭 시 조회수 자동 증가 (`FieldValue.increment(1)`)
- 프리미엄/일반 게시글 구분 표시

### 4.4 검색 및 필터링

#### 카테고리 필터
- 메인 카테고리 선택 (예: 기계제작, MALL)
- 하위 카테고리 선택 (예: 가공1, 베어링/철강)
- "기계제작(전체)" 선택 시 기계제작 카테고리 전체 표시 (MALL 제외)

#### 검색 기능
- 키워드 검색: 카테고리, 하위카테고리, 하위하위카테고리에서만 검색
- 홈 화면 복귀 시 검색 결과 자동 초기화

### 4.5 광고 및 결제

#### 광고 등록
- 경로: 마이페이지 → 광고 등록
- 기간 선택 (시작일 ~ 종료일)
- 가격: 1일 3천원
- 총 금액 = 선택 일수 × 3,000원

#### 결제 처리
- 인앱 결제 사용 (`in_app_purchase`)
- 결제 완료 후 `purchases` 컬렉션에 저장
- 광고 상태: `pending` → `active` → `expired`

### 4.6 관리자 페이지

#### 접근
- 웹 브라우저에서 접근
- 경로: `/admin` 또는 관리자 페이지 URL

#### 주요 기능
- **회원 관리**: 회원 목록, 승인 여부, 가입 경로 확인
- **게시글 관리**: 게시글 목록, 카테고리 필터, 기업명 검색
- **광고 관리**: 프리미엄 광고 가격 설정, 광고 목록 관리
- **문의 관리**: 1:1 문의 목록, 답변 작성
- **FAQ 관리**: FAQ 등록, 수정, 삭제

---

## 5. 서비스 연동 정보

### 5.1 Firebase 프로젝트
- **프로젝트 ID**: `fir-test-96091`
- **사용 서비스**:
  - Authentication
  - Firestore Database
  - Storage
  - Hosting (관리자 페이지)
  - Messaging

### 5.2 소셜 로그인 설정

#### Google
- Firebase Console → Authentication → Sign-in method → Google 활성화
- OAuth 클라이언트 ID 확인

#### Kakao
- Kakao Developers Console 설정
- 네이티브 앱 키: `a22df9f48c7bd192fa4cc21ee0e8f923`
- 패키지명 및 키해시 등록 필요

#### Naver
- 네이버 개발자 센터: https://developers.naver.com/apps
- 앱 이름: "j-factory"
- Android: 패키지명, 서비스 URL, Client ID/Secret 확인
- iOS: Bundle ID, URL Scheme, Client ID/Secret 확인
- **중요**: 서비스 URL이 없으면 로그인 오류 발생

#### Apple
- Apple Developer 설정
- Sign in with Apple 활성화

### 5.3 지도 서비스

#### Google Maps
- API 키: `AIzaSyAQaAqDNxtkH0D_tPv39VtqIzn9dgZnViA`
- `AndroidManifest.xml` 및 `Info.plist`에 설정됨

#### Naver Maps
- WebView를 통한 네이버 지도 표시
- Client ID 설정 필요 (현재 사용 안 함)

### 5.4 광고 서비스

#### Google AdMob
- 앱 ID: `ca-app-pub-8455118855307052~4986340938`
- 배너 광고 및 전면 광고 지원

---

## 6. 배포 및 운영

### 6.1 Android 빌드

#### APK 빌드
```bash
flutter build apk --release
```

#### App Bundle 빌드 (Google Play)
```bash
flutter build appbundle --release
```

#### 키스토어 정보
- 디버그 키스토어: `~/.android/debug.keystore`
- 프로덕션 키스토어: 별도 관리 필요

### 6.2 iOS 빌드

#### 빌드
```bash
flutter build ios --release
```

#### Bundle ID
- `com.sungmin.vendorads`

#### 인증서 및 프로비저닝 프로파일
- Apple Developer에서 관리
- Xcode에서 자동 서명 또는 수동 설정

### 6.3 웹 빌드 (관리자 페이지)

#### 빌드
```bash
flutter build web --target lib/admin_main.dart --base-href "/"
```

#### Firebase Hosting 배포
```bash
# Firebase CLI 로그인
firebase login

# 프로젝트 선택
firebase use fir-test-96091

# 배포
firebase deploy --only hosting
```

#### GitHub Actions 자동 배포
- `.github/workflows/deploy-admin.yml` 설정됨
- `main` 브랜치 푸시 시 자동 배포
- `FIREBASE_TOKEN` 시크릿 필요

### 6.4 환경별 설정

#### 개발 환경
- Firebase 프로젝트: `fir-test-96091`
- 디버그 모드

#### 프로덕션 환경
- 별도 Firebase 프로젝트 사용 권장
- 프로덕션 키스토어 사용
- AdMob 프로덕션 앱 ID 사용

---

## 7. 코드베이스 주요 파일

### 7.1 진입점
- **`lib/main.dart`**: 일반 사용자 앱 진입점
- **`lib/admin_main.dart`**: 관리자 페이지 웹 앱 진입점

### 7.2 라우팅
- **`lib/core/router/app_router.dart`**: GoRouter 설정
- **`lib/core/router/route_names.dart`**: 라우트 이름 상수

### 7.3 상태 관리
- **`lib/presentation/providers/app_providers.dart`**: 전역 Provider 설정
- **`lib/presentation/viewmodels/`**: 각 화면별 ViewModel

### 7.4 데이터 계층
- **`lib/data/datasources/firestore_datasource.dart`**: Firestore 데이터 소스
- **`lib/data/datasources/firebase_auth_datasource.dart`**: Firebase Auth 데이터 소스
- **`lib/data/repositories/`**: 리포지토리 구현

### 7.5 도메인 계층
- **`lib/domain/entities/`**: 엔티티 정의
- **`lib/domain/repositories/`**: 리포지토리 인터페이스
- **`lib/domain/usecases/`**: 유스케이스

### 7.6 주요 화면
- **`lib/presentation/views/auth/`**: 로그인, 회원가입
- **`lib/presentation/views/main/`**: 메인 화면
- **`lib/presentation/views/company/`**: 기업 관련 화면
- **`lib/presentation/views/admin/`**: 관리자 페이지

---

## 8. 트러블슈팅

### 8.1 네이버 로그인 오류
**증상**: "서비스설정에 오류가 있어" 오류

**해결 방법**:
1. 네이버 개발자 센터 접속: https://developers.naver.com/apps
2. "j-factory" 앱 선택
3. Android 플랫폼 설정 확인:
   - 패키지명 일치 확인
   - **서비스 URL 등록 확인** (가장 중요)
   - Client ID/Secret 일치 확인
4. iOS 플랫폼 설정 확인:
   - Bundle ID 일치 확인
   - URL Scheme 일치 확인
   - Client ID/Secret 일치 확인

자세한 내용: `NAVER_LOGIN_TROUBLESHOOTING.md` 참고

### 8.2 Firebase 인덱스 오류
**증상**: `[cloud_firestore/failed-precondition]` 오류

**해결 방법**:
1. Firebase Console → Firestore Database → Indexes
2. 오류 메시지에 표시된 인덱스 생성
3. 또는 코드에서 `orderBy` 제거 후 클라이언트 사이드 정렬

### 8.3 이미지 업로드 실패
**증상**: Firebase Storage 업로드 실패

**해결 방법**:
1. Firebase Storage 규칙 확인
2. 파일 크기 제한 확인
3. 네트워크 연결 확인
4. Firebase Storage 타임아웃 설정 확인 (`lib/main.dart`)

### 8.4 빌드 오류
**증상**: `CardThemeData` 오류 (웹 빌드)

**해결 방법**:
- Flutter 3.24.5 웹 빌드 호환성 문제
- `CardThemeData` 대신 `CardTheme` 사용
- 또는 Flutter 버전 업그레이드

---

## 9. 알아두면 좋은 정보

### 9.1 중요 설정값

#### 광고 가격
- **1일 3천원**으로 통일
- 관리자 페이지: `lib/presentation/views/admin/company_ad_management_view.dart`
- 결제 처리: `lib/domain/usecases/payment/process_payment.dart`
- 인앱 결제: `lib/services/in_app_purchase_service.dart`

#### 카테고리 변경 이력
- "공구 MALL" → "MALL"로 변경됨
- "베어링" → "베어링/철강"
- "철강" → "의류(작업복, 안전화, 방진복)"
- "기계제작(전체)"에서 "유공압", "모터" 제거 (MALL로 이동)

#### 사용자 권한
- **개인 회원**: 게시글 작성 불가, 조회만 가능
- **기업 회원**: 모든 기능 사용 가능
- 라우터에서 `postRegistration` 경로 차단됨

### 9.2 데이터 동기화
- Firestore는 실시간 동기화 지원
- `StreamBuilder` 사용 시 자동 업데이트
- 관리자 페이지에서 삭제 시 앱에 즉시 반영

### 9.3 이미지 처리
- Firebase Storage에 저장
- `cached_network_image`로 캐싱
- 이미지 URL은 Firestore에 저장

### 9.4 검색 기능
- 카테고리 기반 검색만 지원
- 키워드 검색은 카테고리 필드에서만 수행
- 홈 화면 복귀 시 자동 초기화

### 9.5 관리자 페이지
- 웹 전용 (`lib/admin_main.dart`)
- Firebase Hosting에 배포
- 반응형 디자인 (`flutter_screenutil`)

### 9.6 개발 시 주의사항
- Firebase 프로젝트는 `fir-test-96091` 사용
- `j-factory` 프로젝트는 사용하지 않음
- 모든 Firebase 설정은 `fir-test-96091`로 통일

---

## 10. 연락처 및 참고 자료

### 10.1 문서
- **개발 문서**: `DEVELOPMENT.md`
- **네이버 로그인 설정**: `NAVER_LOGIN_SETUP.md`
- **네이버 로그인 트러블슈팅**: `NAVER_LOGIN_TROUBLESHOOTING.md`

### 10.2 외부 링크
- [Flutter 공식 문서](https://flutter.dev/docs)
- [Firebase 문서](https://firebase.google.com/docs)
- [네이버 개발자 센터](https://developers.naver.com)
- [Kakao Developers](https://developers.kakao.com)

---

## 11. 체크리스트

### 인수인계 시 확인 사항
- [ ] 개발 환경 설정 완료
- [ ] Firebase 프로젝트 접근 권한 확인
- [ ] 소셜 로그인 설정 확인 (Google, Kakao, Naver, Apple)
- [ ] Android/iOS 빌드 테스트
- [ ] 관리자 페이지 배포 확인
- [ ] Firebase Storage 규칙 확인
- [ ] Firestore 보안 규칙 확인
- [ ] 환경 변수 파일 확인 (`.env`)
- [ ] 키스토어 및 인증서 관리 방법 확인
- [ ] GitHub 저장소 접근 권한 확인

---

**문서 작성일**: 2025년
**최종 업데이트**: 프로젝트 인수인계 시점

