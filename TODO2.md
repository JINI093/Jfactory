# Flutter 기업 광고 홍보 앱 개발 TODO 리스트

## ⚠️ **중요: UI는 이미 100% 완성되어 있으므로 절대 수정하지 마세요!**
### 이 TODO는 백엔드 로직과 데이터 연동에만 집중합니다.

## 🔥 1단계: Firebase 프로젝트 설정 및 기본 구조 (1주)

### Firebase 설정
- [ ] Firebase 프로젝트 생성 (https://console.firebase.google.com)
- [ ] Flutter 프로젝트에 Firebase 추가
```bash
flutter pub add firebase_core firebase_auth firebase_firestore firebase_storage firebase_messaging
```
- [ ] Firebase CLI 설치 및 설정
```bash
npm install -g firebase-tools
firebase login
flutterfire configure
```
- [ ] `lib/firebase_options.dart` 파일 생성 확인
- [ ] `main.dart`에 Firebase 초기화 코드 추가
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 프로젝트 구조 생성
- [ ] 폴더 구조 생성
```
lib/
├── models/
├── services/
├── screens/
├── widgets/
├── utils/
└── constants/
```
- [ ] 상태관리 Provider 추가
```bash
flutter pub add provider
```

## 🗄️ 2단계: 데이터 레이어 구현 (1주)

### 도메인 엔티티 완성
- [ ] `lib/domain/entities/user_entity.dart` 구현
```dart
class UserEntity {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserType userType; // enum: individual, company
  final DateTime createdAt;
  // 기업 회원 추가 필드
  final String? companyName;
  final String? businessLicense;
}
```
- [ ] `lib/domain/entities/company_entity.dart` 구현
- [ ] `lib/domain/entities/payment_entity.dart` 구현
- [ ] `lib/domain/entities/` 폴더에 누락된 엔티티들 추가 (region, inquiry, post)

### 데이터 모델 완성 (기존 CategoryModel 스타일 유지)
- [ ] `lib/data/models/user_model.dart` 완성 (기존 CategoryModel 패턴 참고)
```dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserType userType;
  final DateTime createdAt;
  final String? companyName;
  final String? businessLicense;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.companyName,
    this.businessLicense,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      userType: UserType.values.firstWhere((e) => e.toString() == json['userType']),
      createdAt: DateTime.parse(json['createdAt']),
      companyName: json['companyName'],
      businessLicense: json['businessLicense'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType.toString(),
      'createdAt': createdAt.toIso8601String(),
      'companyName': companyName,
      'businessLicense': businessLicense,
    };
  }
}

enum UserType { individual, company }
```
- [ ] `lib/data/models/company_model.dart` 완성 (CategoryModel 스타일 참고)
```dart
class CompanyModel {
  final String id;
  final String companyName;
  final String ceoName;
  final String phone;
  final String address;
  final String detailAddress;
  final String category; // CategoryModel.title 값 사용
  final String subcategory; // CategoryModel.subcategories 값 사용
  final String? website;
  final String? greeting;
  final List<String> photos;
  final String? logo;
  final double adPayment; // 광고비
  final DateTime createdAt;
  final DateTime? adExpiryDate; // 광고 만료일

  CompanyModel({
    required this.id,
    required this.companyName,
    required this.ceoName,
    required this.phone,
    required this.address,
    required this.detailAddress,
    required this.category,
    required this.subcategory,
    this.website,
    this.greeting,
    required this.photos,
    this.logo,
    required this.adPayment,
    required this.createdAt,
    this.adExpiryDate,
  });

  // fromJson, toJson 메서드 추가
}
```
- [ ] `lib/data/models/payment_model.dart` 완성
- [ ] `lib/data/models/category_model.dart` 이미 완성됨 ✅
- [ ] 누락된 모델들 추가
  - [ ] `lib/data/models/region_model.dart` 생성 (CategoryModel 패턴 참고)
  - [ ] `lib/data/models/inquiry_model.dart` 생성
  - [ ] `lib/data/models/post_model.dart` 생성

### 지역 데이터 모델 생성 (CategoryModel 패턴 활용)
- [ ] `lib/data/models/region_model.dart` 생성
```dart
class RegionModel {
  final String title;
  final List<String> districts;

  RegionModel({
    required this.title,
    required this.districts,
  });
}

class RegionData {
  static final List<RegionModel> regions = [
    RegionModel(
      title: '서울특별시',
      districts: ['강남구', '서초구', '송파구', '강동구', '영등포구', '구로구', '금천구', '동작구', '관악구', '성동구', '광진구', '중랑구', '성북구', '강북구', '도봉구', '노원구', '은평구', '서대문구', '마포구', '양천구', '강서구', '종로구', '중구', '용산구'],
    ),
    RegionModel(
      title: '경기도',
      districts: ['수원시', '성남시', '안양시', '안산시', '과천시', '광명시', '구리시', '남양주시', '오산시', '시흥시', '군포시', '의왕시', '하남시', '용인시', '파주시', '이천시', '안성시', '김포시', '화성시', '광주시', '양주시', '포천시', '여주시', '연천군', '가평군', '양평군'],
    ),
    // 나머지 지역들 추가...
  ];

  static RegionModel? getRegionByTitle(String title) {
    try {
      return regions.firstWhere((region) => region.title == title);
    } catch (e) {
      return null;
    }
  }
}
```

### 데이터소스 구현
- [ ] `lib/data/datasources/firebase_auth_datasource.dart` 완성
- [ ] `lib/data/datasources/firestore_datasource.dart` 완성
- [ ] `lib/data/datasources/storage_datasource.dart` 완성

### 리포지토리 구현체 완성
- [ ] `lib/data/repositories/auth_repository_impl.dart` 완성
- [ ] `lib/data/repositories/company_repository_impl.dart` 완성 (CategoryModel과 연동)
- [ ] `lib/data/repositories/payment_repository_impl.dart` 완성

### Firebase Security Rules 설정
- [ ] Firestore 보안 규칙 설정
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /companies/{companyId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if false; // 카테고리는 읽기 전용
    }
  }
}
```

## 🔐 3단계: 도메인 레이어 구현 (1-2주)

### 리포지토리 인터페이스 완성
- [ ] `lib/domain/repositories/auth_repository.dart` 인터페이스 정의
- [ ] `lib/domain/repositories/company_repository.dart` 인터페이스 정의
- [ ] `lib/domain/repositories/payment_repository.dart` 인터페이스 정의

### 유스케이스 구현
- [ ] `lib/domain/usecases/auth/` 폴더에 유스케이스들 구현
  - [ ] `sign_in_with_google.dart`
  - [ ] `sign_in_with_apple.dart`
  - [ ] `sign_in_with_kakao.dart`
  - [ ] `sign_in_with_naver.dart`
  - [ ] `sign_up_user.dart`
  - [ ] `sign_out_user.dart`
- [ ] `lib/domain/usecases/company/` 폴더에 유스케이스들 구현
  - [ ] `get_companies.dart`
  - [ ] `get_company_by_id.dart`
  - [ ] `create_company.dart`
  - [ ] `update_company.dart`
- [ ] `lib/domain/usecases/payment/` 폴더에 유스케이스들 구현
  - [ ] `process_payment.dart`
  - [ ] `get_payment_history.dart`

### 소셜 로그인 패키지 추가 및 설정
- [ ] 소셜 로그인 패키지 설치
```bash
flutter pub add google_sign_in sign_in_with_apple kakao_flutter_sdk flutter_naver_login
```

### API 키 발급 및 설정
- [ ] Google Sign-In 설정 (Firebase Console)
- [ ] Apple Sign-In 설정 (Apple Developer)
- [ ] Kakao Developers에서 앱 등록 및 키 발급
- [ ] Naver Developers에서 앱 등록 및 키 발급

## 🎯 4단계: 프레젠테이션 레이어 - 인증 시스템 (1-2주)
### ⚠️ **UI 수정 금지: 기존 뷰 파일들의 UI는 건드리지 말고 데이터 연동 로직만 추가**

### 뷰모델 완성
- [ ] `lib/presentation/viewmodels/auth_viewmodel.dart` 완성
  - [ ] 소셜 로그인 상태 관리
  - [ ] 회원가입 플로우 관리
  - [ ] 폰 인증 상태 관리
- [ ] `lib/presentation/viewmodels/splash_viewmodel.dart` 완성
  - [ ] 자동 로그인 체크
  - [ ] 초기 라우팅 로직

### 프로바이더 설정
- [ ] `lib/presentation/providers/auth_providers.dart` 완성
- [ ] `lib/presentation/providers/app_providers.dart`에 인증 관련 프로바이더 추가

### 인증 관련 뷰 완성 (UI는 그대로 두고 데이터 로직만 연동)
- [ ] `lib/presentation/views/auth/login_view.dart` 백엔드 연동
  - [ ] 소셜 로그인 버튼들에 실제 로그인 로직 연결
  - [ ] 로딩 상태 처리 로직 추가
  - [ ] ⚠️ **UI 레이아웃은 절대 수정하지 말 것**
- [ ] `lib/presentation/views/auth/signup_view.dart` 백엔드 연동
  - [ ] 회원가입 폼 데이터 Firebase에 저장하는 로직 추가
  - [ ] 폰 인증 API 연동
  - [ ] 회원 정보 유효성 검사 로직 추가
  - [ ] ⚠️ **UI 레이아웃은 절대 수정하지 말 것**
- [ ] `lib/presentation/views/auth/widgets/` 폴더의 위젯들에 로직 추가
  - [ ] 기존 위젯들에 상태 관리 및 이벤트 핸들러만 추가
  - [ ] ⚠️ **UI 스타일링은 절대 수정하지 말 것**

### 스플래시 뷰 완성 (데이터 로직만 추가)
- [ ] `lib/presentation/views/splash/splash_view.dart` 백엔드 연동
  - [ ] 자동 로그인 체크 로직 추가
  - [ ] Firebase 초기화 상태 확인
  - [ ] ⚠️ **UI 애니메이션은 절대 수정하지 말 것**
- [ ] `lib/presentation/views/splash/widgets/` 폴더의 기존 위젯들에 상태 관리만 추가

## 🗺️ 6단계: 지도 및 커뮤니케이션 기능 (1-2주)
### ⚠️ **UI 수정 금지: 기존 뷰들의 디자인은 그대로 두고 기능만 추가**

### 네이버 지도 연동
- [ ] 네이버 클라우드 플랫폼에서 Maps API 키 발급
- [ ] `naver_map_plugin` 패키지 추가 및 설정
```bash
flutter pub add naver_map_plugin
```
- [ ] 기업 위치 표시 기능 구현
- [ ] 현재 위치에서 기업까지 거리 계산

### 카테고리 및 프로필 기능 (데이터 연동만)
- [ ] `lib/presentation/views/category/category_detail_view.dart` 백엔드 연동 완성
- [ ] `lib/presentation/views/profile/profile_view.dart` 백엔드 연동
  - [ ] 기존 UI에 사용자 정보 표시
  - [ ] ⚠️ **프로필 화면 UI는 절대 수정하지 말 것**

### 게시글 및 광고 기능 (데이터 연동만)
- [ ] `lib/presentation/views/post/premium_post_detail_view.dart` 백엔드 연동
  - [ ] 기존 UI에 실제 게시글 데이터 표시
  - [ ] ⚠️ **게시글 뷰 UI는 절대 수정하지 말 것**
- [ ] `lib/presentation/views/advertisement/advertisement_registration_view.dart` 백엔드 연동
  - [ ] 기존 폼에 실제 등록 로직 추가
  - [ ] ⚠️ **광고 등록 폼 UI는 절대 수정하지 말 것**

### 데이터 모델 추가
- [ ] `lib/data/models/inquiry_model.dart` 생성 (1:1 문의용)
- [ ] `lib/data/models/post_model.dart` 생성 (기업 게시글용)
- [ ] `lib/data/models/region_model.dart` 생성

### 유스케이스 추가
- [ ] `lib/domain/usecases/inquiry/` 폴더 생성 및 유스케이스 구현
- [ ] `lib/domain/usecases/post/` 폴더 생성 및 유스케이스 구현

### 이미지 업로드 기능 (Firebase Storage)
- [ ] 이미지 업로드 서비스 구현
```dart
Future<String> uploadImage(File imageFile) async {
  final ref = FirebaseStorage.instance.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}');
  await ref.putFile(imageFile);
  return await ref.getDownloadURL();
}
```

## 💳 7단계: 결제 시스템 (2-3주)

### 인앱 결제 설정
- [ ] `in_app_purchase` 패키지 추가
```bash
flutter pub add in_app_purchase
```
- [ ] Google Play Console에서 인앱 상품 등록
- [ ] App Store Connect에서 인앱 상품 등록

### 결제 관련 유스케이스 완성
- [ ] `lib/domain/usecases/payment/` 폴더의 유스케이스들 완성
- [ ] `lib/data/repositories/payment_repository_impl.dart` 결제 로직 구현

### 결제 뷰모델 및 뷰 구현
- [ ] 결제 관련 뷰모델 생성 (`lib/presentation/viewmodels/payment_viewmodel.dart`)
- [ ] 결제 화면 구현 (`lib/presentation/views/payment/payment_view.dart`)

### 광고 시스템
- [ ] 광고비에 따른 정렬 로직 구현
- [ ] 광고 만료 시간 관리 시스템
- [ ] 푸시 알림으로 광고 만료 안내

## 📱 8단계: 라우팅 및 내비게이션 완성 (1주)

### Go Router 설정
- [ ] `lib/core/router/app_router.dart` 완성
- [ ] `lib/core/router/route_names.dart`에 모든 라우트 이름 정의
- [ ] 인증 상태에 따른 라우팅 가드 구현
- [ ] 딥링크 및 쿼리 파라미터 처리

### 내비게이션 바 구현
- [ ] 하단 네비게이션 바 구현
- [ ] 탭별 상태 유지 로직

## 🔔 9단계: 푸시 알림 시스템 (1주)

### Firebase Messaging 설정
- [ ] FCM 토큰 관리 시스템 구현
- [ ] 백그라운드 메시지 처리
- [ ] 알림 권한 요청 구현

### 알림 발송 기능
- [ ] 새 문의 도착 알림
- [ ] 광고 만료 예정 알림
- [ ] 새 게시글 알림

## 🌐 10단계: 관리자 페이지 (Flutter Web) (2-3주)

### Web 프로젝트 설정
- [ ] 별도 Flutter Web 프로젝트 생성
```bash
flutter create admin_web --platforms web
```
- [ ] Firebase 연동 및 관리자 인증 구현

### 관리자 기능 구현
- [ ] 기업 정보 CRUD 페이지
- [ ] 사용자 관리 페이지
- [ ] 결제 내역 관리 페이지
- [ ] 문의 관리 페이지
- [ ] 대시보드 (통계 화면)

## 🚀 11단계: 최적화 및 배포 준비 (1-2주)

### 성능 최적화
- [ ] 이미지 캐싱 최적화 (`cached_network_image` - 이미 추가됨)
- [ ] 페이지네이션 구현
- [ ] lazy loading 적용
- [ ] 앱 사이즈 최적화

### 에러 처리 및 로깅
- [ ] `lib/core/errors/exceptions.dart` 완성
- [ ] `lib/core/errors/failures.dart` 완성
- [ ] 전역 에러 핸들링 구현

### 유틸리티 및 헬퍼 완성
- [ ] `lib/core/utils/extensions.dart` 완성
- [ ] `lib/core/utils/helpers.dart` 완성
- [ ] `lib/core/utils/validators.dart` 완성

### 배포 준비
- [ ] 앱 아이콘 및 스플래시 스크린 설정
```bash
flutter pub add flutter_launcher_icons flutter_native_splash
```
- [ ] Android 키스토어 생성 및 서명 설정
- [ ] iOS 배포 인증서 및 프로비저닝 프로필 설정
- [ ] 버전 관리 및 빌드 번호 설정

### 테스트
- [ ] 단위 테스트 작성
- [ ] 위젯 테스트 작성
- [ ] 통합 테스트 작성
- [ ] 실제 기기에서 테스트

## 📱 12단계: 스토어 배포 (1주)

### Google Play Store
- [ ] 스토어 리스팅 작성 (설명, 스크린샷, 아이콘)
- [ ] 개인정보 처리방침 페이지 작성
- [ ] AAB 파일 생성 및 업로드
- [ ] 내부 테스트 → 공개 테스트 → 프로덕션 단계별 배포

### Apple App Store
- [ ] App Store Connect에서 앱 정보 작성
- [ ] 스크린샷 및 앱 미리보기 영상 준비
- [ ] IPA 파일 생성 및 업로드
- [ ] 심사 제출

## 📋 추가 권장 작업

### 코드 품질 및 개발 도구
- [ ] Lint 규칙 설정 (`analysis_options.yaml`)
- [ ] 코드 문서화 (dartdoc)
- [ ] Git hooks 설정 (pre-commit)
- [ ] Makefile 생성 (빌드 자동화)

### 모니터링 및 분석
- [ ] Firebase Crashlytics 연동
```bash
flutter pub add firebase_crashlytics
```
- [ ] Firebase Analytics 연동
```bash
flutter pub add firebase_analytics
```
- [ ] Firebase Performance Monitoring 설정
```bash
flutter pub add firebase_performance
```

### 보안 강화
- [ ] 네트워크 보안 구성 (`network_security_config.xml`)
- [ ] API 키 난독화
- [ ] ProGuard/R8 설정 (Android)
- [ ] Certificate Pinning 구현

### 공통 위젯 구현
- [ ] `lib/presentation/views/shared/widgets/` 폴더에 공용 위젯들 추가
  - [ ] 로딩 인디케이터 위젯
  - [ ] 에러 표시 위젯  
  - [ ] 빈 상태 표시 위젯
  - [ ] 공용 버튼 위젯들
  - [ ] 공용 다이얼로그 위젯들

---

## 📝 Clean Architecture 기반 개발 순서 요약

1. **Firebase 설정** → 인프라 기반 마련
2. **데이터 레이어** → 모델, 데이터소스, 리포지토리 구현체
3. **도메인 레이어** → 엔티티, 리포지토리 인터페이스, 유스케이스  
4. **프레젠테이션 레이어 (인증)** → 뷰모델, 프로바이더, 인증 뷰
5. **프레젠테이션 레이어 (메인)** → 메인 기능 뷰모델 및 뷰
6. **부가 기능** → 지도, 문의, 게시글 등
7. **결제 시스템** → 수익 모델 구현
8. **라우팅** → 내비게이션 완성
9. **푸시 알림** → 사용자 참여도 향상
10. **관리자 페이지** → 운영 도구
11. **최적화** → 성능 및 에러 처리
12. **배포** → 스토어 출시

현재 폴더 구조가 Clean Architecture를 잘 따르고 있어서, 각 레이어별로 체계적으로 구현하면 유지보수성이 뛰어난 앱이 될 것입니다!