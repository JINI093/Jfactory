# 제작소 (Vendor Ads) 개발 문서

## 📋 목차
1. [프로젝트 개요](#프로젝트-개요)
2. [기술 스택](#기술-스택)
3. [프로젝트 구조](#프로젝트-구조)
4. [아키텍처](#아키텍처)
5. [주요 기능](#주요-기능)
6. [개발 환경 설정](#개발-환경-설정)
7. [빌드 및 배포](#빌드-및-배포)

---

## 프로젝트 개요

**제작소 (Vendor Ads)**는 기업 광고 및 홍보를 위한 Flutter 기반 모바일 애플리케이션입니다. 기업들이 제품과 서비스를 등록하고 홍보할 수 있으며, 사용자들은 카테고리별로 기업을 검색하고 정보를 확인할 수 있습니다.

### 주요 특징
- 기업 정보 등록 및 관리
- 게시글 작성 및 관리
- 소셜 로그인 (이메일, Google, Kakao, Naver, Apple)
- 지도 기반 기업 검색
- 광고 결제 시스템
- 관리자 페이지 (웹)

---

## 기술 스택

### 프레임워크 및 언어
- **Flutter**: `>=3.10.0`
- **Dart**: `>=3.0.0 <4.0.0`

### 상태 관리
- **Provider**: `^6.1.1` - 상태 관리 및 의존성 주입

### UI/UX
- **flutter_screenutil**: `^5.9.0` - 반응형 디자인
- **cached_network_image**: `^3.3.0` - 이미지 캐싱
- **image_picker**: `^1.0.4` - 이미지 선택

### 백엔드 및 인증
- **Firebase Core**: `^4.0.0` - Firebase 초기화
- **Firebase Auth**: `^6.0.0` - 사용자 인증
- **Cloud Firestore**: `^6.0.0` - NoSQL 데이터베이스
- **Firebase Storage**: `^13.0.0` - 파일 저장소
- **Firebase Messaging**: `^16.0.0` - 푸시 알림

### 소셜 로그인
- **google_sign_in**: `^6.1.6` - Google 로그인
- **kakao_flutter_sdk_user**: `^1.9.5` - Kakao 로그인
- **flutter_naver_login**: `^2.0.0` - Naver 로그인
- **sign_in_with_apple**: `^6.1.2` - Apple 로그인

### 네비게이션
- **go_router**: `^12.1.3` - 선언적 라우팅

### 지도 및 위치
- **google_maps_flutter**: `^2.9.0` - Google Maps
- **geolocator**: `^10.1.0` - 위치 정보
- **geocoding**: `^2.1.1` - 주소 변환
- **webview_flutter**: `^4.4.2` - WebView (Naver Maps)

### 결제
- **in_app_purchase**: `^3.1.11` - 인앱 결제

### 광고
- **google_mobile_ads**: `^5.1.0` - Google AdMob

### 유틸리티
- **flutter_dotenv**: `^5.1.0` - 환경 변수 관리
- **http**: `^1.1.0` - HTTP 통신
- **url_launcher**: `^6.2.4` - URL 실행

### 개발 도구
- **flutter_lints**: `^3.0.0` - 린터
- **build_runner**: `^2.4.7` - 코드 생성
- **flutter_launcher_icons**: `^0.13.1` - 앱 아이콘 생성

---

## 프로젝트 구조

프로젝트는 **Clean Architecture** 패턴을 따르며, 다음과 같은 계층 구조로 구성되어 있습니다:

```
lib/
├── main.dart                    # 앱 진입점
├── admin_main.dart              # 관리자 페이지 진입점
├── firebase_options.dart        # Firebase 설정
│
├── core/                        # 핵심 기능
│   ├── constants/               # 상수 정의
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   └── app_strings.dart
│   ├── errors/                  # 에러 처리
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── router/                   # 라우팅
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── services/                 # 공통 서비스
│   │   └── image_upload_service.dart
│   ├── theme/                    # 테마
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── utils/                    # 유틸리티
│       ├── extensions.dart
│       ├── helpers.dart
│       └── validators.dart
│
├── domain/                       # 도메인 계층 (비즈니스 로직)
│   ├── entities/                 # 엔티티
│   │   ├── company_entity.dart
│   │   ├── favorite_entity.dart
│   │   ├── inquiry_entity.dart
│   │   ├── payment_entity.dart
│   │   ├── post_entity.dart
│   │   ├── purchase_entity.dart
│   │   ├── region_entity.dart
│   │   └── user_entity.dart
│   ├── repositories/             # 리포지토리 인터페이스
│   │   ├── auth_repository.dart
│   │   ├── company_repository.dart
│   │   ├── favorite_repository.dart
│   │   ├── inquiry_repository.dart
│   │   ├── payment_repository.dart
│   │   ├── post_repository.dart
│   │   └── purchase_repository.dart
│   └── usecases/                 # 유스케이스
│       ├── auth/
│       ├── company/
│       ├── favorite/
│       ├── inquiry/
│       ├── payment/
│       └── post/
│
├── data/                         # 데이터 계층
│   ├── datasources/              # 데이터 소스
│   │   ├── firebase_auth_datasource.dart
│   │   ├── firestore_datasource.dart
│   │   └── storage_datasource.dart
│   ├── models/                   # 데이터 모델
│   │   ├── category_model.dart
│   │   ├── company_model.dart
│   │   ├── favorite_model.dart
│   │   ├── inquiry_model.dart
│   │   ├── payment_model.dart
│   │   ├── post_model.dart
│   │   ├── purchase_model.dart
│   │   ├── region_model.dart
│   │   └── user_model.dart
│   └── repositories/             # 리포지토리 구현
│       ├── auth_repository_impl.dart
│       ├── company_repository_impl.dart
│       ├── favorite_repository_impl.dart
│       ├── inquiry_repository_impl.dart
│       ├── payment_repository_impl.dart
│       ├── post_repository_impl.dart
│       └── purchase_repository_impl.dart
│
├── presentation/                 # 프레젠테이션 계층 (UI)
│   ├── providers/                # Provider 설정
│   │   ├── app_providers.dart
│   │   ├── auth_providers.dart
│   │   └── company_providers.dart
│   ├── viewmodels/               # 뷰모델
│   │   ├── auth_viewmodel.dart
│   │   ├── company_viewmodel.dart
│   │   ├── favorite_viewmodel.dart
│   │   ├── main_viewmodel.dart
│   │   ├── payment_viewmodel.dart
│   │   └── splash_viewmodel.dart
│   ├── views/                    # 화면
│   │   ├── admin/                 # 관리자 페이지
│   │   ├── advertisement/         # 광고 등록
│   │   ├── auth/                  # 인증
│   │   ├── category/              # 카테고리
│   │   ├── company/               # 기업
│   │   ├── favorites/             # 즐겨찾기
│   │   ├── filter/                 # 필터
│   │   ├── inquiry/                # 문의
│   │   ├── main/                   # 메인
│   │   ├── map/                    # 지도
│   │   ├── post/                   # 게시글
│   │   ├── profile/                # 프로필
│   │   ├── purchase/               # 결제
│   │   ├── shared/                 # 공통 위젯
│   │   └── splash/                 # 스플래시
│   └── widgets/                   # 재사용 가능한 위젯
│       ├── admob_banner_widget.dart
│       ├── google_map_widget.dart
│       └── naver_map_widget.dart
│
├── services/                      # 서비스
│   ├── in_app_purchase_service.dart
│   └── location_service.dart
│
└── utils/                        # 유틸리티
    └── kakao_key_hash_helper.dart
```

---

## 아키텍처

### Clean Architecture 패턴

프로젝트는 **Clean Architecture**를 기반으로 3개의 주요 계층으로 구성됩니다:

#### 1. Domain Layer (도메인 계층)
- **Entities**: 비즈니스 로직의 핵심 객체
- **Repositories**: 데이터 접근을 위한 인터페이스 정의
- **Use Cases**: 특정 비즈니스 로직을 수행하는 단위

**특징**:
- 외부 의존성 없음
- 순수 Dart 코드
- 비즈니스 규칙 캡슐화

#### 2. Data Layer (데이터 계층)
- **Data Sources**: Firebase, Storage 등 외부 데이터 소스와의 통신
- **Models**: 데이터 모델 (JSON 직렬화/역직렬화)
- **Repository Implementations**: Domain의 Repository 인터페이스 구현

**특징**:
- Domain 계층에 의존
- Firebase, Storage 등 외부 서비스와 통신
- 데이터 변환 및 캐싱 처리

#### 3. Presentation Layer (프레젠테이션 계층)
- **Views**: 사용자 인터페이스 (화면)
- **ViewModels**: UI 상태 관리 및 비즈니스 로직 호출
- **Widgets**: 재사용 가능한 UI 컴포넌트

**특징**:
- Domain과 Data 계층에 의존
- Provider를 통한 상태 관리
- 사용자 인터랙션 처리

### 데이터 흐름

```
UI (View) 
  ↓
ViewModel 
  ↓
UseCase 
  ↓
Repository (Interface)
  ↓
Repository Implementation
  ↓
Data Source
  ↓
Firebase/Storage
```

### 상태 관리

**Provider 패턴**을 사용하여 상태를 관리합니다:

- **AuthViewModel**: 사용자 인증 상태
- **CompanyViewModel**: 기업 정보 및 필터링
- **MainViewModel**: 메인 화면 상태
- **FavoriteViewModel**: 즐겨찾기 상태
- **PaymentViewModel**: 결제 상태

---

## 주요 기능

### 1. 사용자 인증
- 이메일/비밀번호 로그인
- 소셜 로그인 (Google, Kakao, Naver, Apple)
- 회원가입 (개인/기업)
- 핸드폰 본인인증
- 비밀번호 재설정

### 2. 기업 관리
- 기업 정보 등록 및 수정
- 카테고리별 기업 검색
- 기업 상세 정보 조회
- 지도 기반 기업 검색
- 즐겨찾기 기능

### 3. 게시글 관리
- 게시글 작성 (기업 회원만)
- 게시글 조회 및 수정
- 프리미엄/일반 게시글 구분
- 조회수 추적

### 4. 광고 및 결제
- 광고 등록 (기간 선택)
- 인앱 결제
- 결제 내역 조회
- 광고 상태 관리

### 5. 문의 및 FAQ
- 1:1 문의 작성
- FAQ 조회
- 관리자 답변 확인

### 6. 관리자 페이지 (웹)
- 회원 관리
- 게시글 관리
- 광고 관리
- 문의 관리
- FAQ 관리

---

## 개발 환경 설정

### 필수 요구사항
- Flutter SDK: `>=3.10.0`
- Dart SDK: `>=3.0.0 <4.0.0`
- Android Studio / VS Code
- Xcode (iOS 개발 시)

### 초기 설정

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd vendor_ads
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **환경 변수 설정**
   - `.env` 파일 생성
   - 필요한 API 키 및 설정 추가

4. **Firebase 설정**
   - `firebase_options.dart` 확인
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

5. **소셜 로그인 설정**
   - Google: `google-services.json` 확인
   - Kakao: 네이티브 앱 키 설정
   - Naver: 네이버 개발자 센터 설정
   - Apple: Apple Developer 설정

### 실행

```bash
# 개발 모드 실행
flutter run

# 특정 플랫폼 실행
flutter run -d android
flutter run -d ios

# 웹 실행 (관리자 페이지)
flutter run -d chrome --target lib/admin_main.dart
```

---

## 빌드 및 배포

### Android 빌드

```bash
# APK 빌드
flutter build apk --release

# App Bundle 빌드 (Google Play)
flutter build appbundle --release
```

### iOS 빌드

```bash
# iOS 빌드
flutter build ios --release
```

### 웹 빌드 (관리자 페이지)

```bash
# 웹 빌드
flutter build web --target lib/admin_main.dart --base-href "/"

# Firebase Hosting 배포
firebase deploy --only hosting
```

### Firebase Hosting 설정

1. **firebase.json** 확인
2. **Firebase CLI 로그인**
   ```bash
   firebase login
   ```
3. **프로젝트 선택**
   ```bash
   firebase use fir-test-96091
   ```
4. **배포**
   ```bash
   firebase deploy --only hosting
   ```

---

## 주요 파일 설명

### 진입점
- **main.dart**: 일반 사용자 앱 진입점
- **admin_main.dart**: 관리자 페이지 웹 앱 진입점

### 라우팅
- **app_router.dart**: GoRouter를 사용한 라우팅 설정
- **route_names.dart**: 라우트 이름 상수 정의

### Firebase 설정
- **firebase_options.dart**: 플랫폼별 Firebase 설정

### 상태 관리
- **app_providers.dart**: 전역 Provider 설정
- **auth_providers.dart**: 인증 관련 Provider
- **company_providers.dart**: 기업 관련 Provider

---

## 개발 가이드라인

### 코드 스타일
- Dart 공식 스타일 가이드 준수
- `flutter_lints` 규칙 준수
- 의미 있는 변수명 사용

### 아키텍처 원칙
- Clean Architecture 패턴 준수
- 계층 간 의존성 방향 준수 (Domain ← Data ← Presentation)
- 인터페이스 기반 프로그래밍

### 에러 처리
- `try-catch`를 통한 예외 처리
- 사용자 친화적인 에러 메시지
- 로깅을 통한 디버깅 지원

### 테스트
- Unit Test 작성 권장
- Widget Test 작성 권장
- Integration Test 작성 권장

---

## 참고 자료

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Firebase 문서](https://firebase.google.com/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Provider 패턴](https://pub.dev/packages/provider)

---

## 라이선스

이 프로젝트는 비공개 프로젝트입니다.

---