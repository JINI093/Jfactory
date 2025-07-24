# 기업 광고 홍보 앱 PRD (Product Requirements Document)

## 1. 프로젝트 개요

### 1.1 프로젝트명
기업 광고 홍보 앱

### 1.2 프로젝트 목적
기업들이 광고비를 지불하고 자사를 홍보할 수 있는 플랫폼을 제공하며, 사용자들은 지역별/업종별 기업 정보를 쉽게 탐색할 수 있는 모바일 앱 개발

### 1.3 개발 환경
- 플랫폼: Flutter (iOS/Android)
- 백엔드: Firebase
- 관리자 페이지: Flutter Web
- 디자인: 기존 Figma 디자인 준수

### 1.4 브랜딩
- 주요 색상: 
  - Black: 
#000000
  - Primary: 
#3B456C
  - Secondary: 
#E6E9F2
- Gray Scale: Gray 50~800

## 2. 타겟 사용자

### 2.1 Primary Users
- 일반 사용자: 지역 기업 정보를 찾는 개인
- 기업 사용자: 자사를 홍보하고자 하는 기업

### 2.2 Secondary Users
- 관리자: 앱 운영 및 기업 정보 관리

## 3. 핵심 기능

### 3.1 사용자 기능
- 회원가입/로그인 (소셜 로그인 지원)
- 기업 정보 탐색 (광고비 순 정렬)
- 기업 상세 정보 조회
- 지도 연동을 통한 위치 확인
- 전화걸기 기능
- 즐겨찾기 기능
- 업종별/지역별 검색 및 필터링
- 1:1 문의 기능

### 3.2 기업 사용자 기능
- 기업 정보 등록/수정
- 게시글 작성 및 관리
- 광고비 결제 (인앱 결제)
- 문의 관리

### 3.3 관리자 기능 (Flutter Web)
- 기업 정보 CRUD
- 사용자 관리
- 결제 관리
- 문의 관리
- 푸시 알림 발송

## 4. 기술 스펙

### 4.1 개발 플랫폼
yaml
Flutter SDK: Latest Stable
Target Platforms: iOS 13+ / Android API 21+
State Management: Provider

### 4.2 주요 패키지
```yaml
# Firebase
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
firebase_firestore: ^4.13.6
firebase_storage: ^11.5.6
firebase_messaging: ^14.7.10

# Social Login
google_sign_in: ^6.1.6
sign_in_with_apple: ^5.0.0
kakao_flutter_sdk: ^1.7.0
flutter_naver_login: ^1.8.0

# Maps & Location
naver_map_plugin: ^0.9.7

# UI/UX
flutter_screenutil: ^5.9.0
cached_network_image: ^3.3.0
image_picker: ^1.0.4

# Payment
in_app_purchase: ^3.1.11
```

### 4.3 데이터베이스 구조 (Firebase Firestore)

collections/
├── users/
├── companies/
├── categories/
├── regions/
├── payments/
└── notifications/

## 5. 사용자 플로우

### 5.1 앱 진입 플로우

스플래시 → 메인페이지(로그인X) → 로그인 버튼 클릭 → 로그인 페이지 → 소셜로그인 → 메인페이지

### 5.2 회원가입 플로우

로그인 페이지 → 회원가입 → 이용약관 동의 → 회원정보 입력 → 핸드폰 인증 → 완료

### 5.3 회원정보 입력 항목
공통 정보
- 회원구분 선택 (기업/개인)
- 이메일
- 비밀번호 & 비밀번호 확인
- 이름
- 핸드폰 번호
- 핸드폰 인증

기업 회원 추가 정보
- 사업장명
- 사업자등록증 (파일 업로드)

### 5.4 기업 정보 데이터 구조
```
기업 기본정보:
- 기업명
- 기업대표명
- 홈페이지
- 기업전화번호
- 기업주소 & 상세주소
- 인사말
- 연혁
- 주요거래처
- 특징
- 회사 사진
- 회사 로고
- 사업자등록증

추가 기능:
- 기업 게시글
- 기업별 1:1 문의
```

## 6. 페이지 구조

### 6.1 앱 라우팅

/splash - 스플래시 페이지
/main - 메인 페이지 (기업 리스트)
/login - 로그인 페이지
/terms - 이용약관 동의 페이지
/signup - 회원가입 페이지
/phone-verification - 핸드폰 인증 페이지
/company-detail - 기업 상세 페이지
/company-register - 기업 정보 등록 페이지
/company-edit - 기업 정보 수정 페이지
/post-write - 게시글 작성 페이지
/payment - 결제 페이지
/inquiry - 1:1 문의 페이지
/favorites - 즐겨찾기 페이지
/search - 검색 페이지

### 6.2 소셜 로그인 지원 플랫폼
- Google
- Apple
- Kakao
- Naver

## 7. 비즈니스 모델

### 7.1 수익 모델
- 광고비 결제: 기업이 앱 내 결제를 통해 광고비 지불
- 광고 등급: 광고비에 따른 노출 순위 차별화

### 7.2 광고 시스템
- 높은 광고비 지급 기업 우선 노출
- 광고 레벨별 차등 혜택 제공
- 결제 기간에 따른 할인 혜택

## 8. 개발 로드맵

### Phase 1: 기본 구조 (1-2주)
- Firebase 설정 및 인증
- 기본 UI 테마 설정
- 네비게이션 구조
- 기업 목록 화면 (광고비 순 정렬)

### Phase 2: 기업 상세 기능 (2-3주)
- 기업 상세 페이지
- 지도 연동 (네이버/카카오)
- 전화걸기 기능
- 이미지 뷰어

### Phase 3: 사용자 기능 (1-2주)
- 회원가입/로그인
- 즐겨찾기 기능
- 검색/필터 기능
- 1:1 문의 기능

### Phase 4: 결제 및 광고 (2-3주)
- 인앱 결제 시스템
- 광고비 결제 처리
- 광고 레벨별 노출 로직

### Phase 5: 관리자 기능 (2-3주)
- Flutter Web 관리자 페이지
- 기업 정보 CRUD
- 문의 관리
- 결제 관리

### Phase 6: 알림 및 최적화 (1-2주)
- 푸시 알림 시스템
- 성능 최적화
- 테스트 및 배포

## 9. 보안 및 개인정보 처리

### 9.1 데이터 보안
- Firebase Security Rules 적용
- 사업자등록증 등 민감 정보 암호화
- 사용자 인증 및 권한 관리

### 9.2 개인정보 처리
- 개인정보 처리방침 준수
- GDPR 대응 (필요시)
- 데이터 최소 수집 원칙

## 10. 성능 및 최적화

### 10.1 성능 목표
- 앱 시작 시간 3초 이내
- 페이지 로딩 시간 2초 이내
- 이미지 로딩 최적화

### 10.2 최적화 전략
- 기업 목록 페이지네이션
- 이미지 캐싱 및 썸네일 생성
- 즐겨찾기 오프라인 캐싱
- Firebase Storage 최적화

## 11. 추가 고려사항

### 11.1 확장성
- 다국어 지원 (추후)
- 웹 버전 확장 (추후)
- API 외부 연동 (추후)

### 11.2 유지보수
- 코드 문서화
- 테스트 코드 작성
- CI/CD 파이프라인 구축

### 11.3 필요한 외부 서비스 연동
- 소셜 로그인 API 키 발급
- 지도 API 키 발급 (네이버/카카오 선택)
- Firebase 프로젝트 설정
- Apple Developer Program (iOS 배포)
- Google Play Console (Android 배포)

---

문서 버전: 1.0  
작성일: 2025년 7월  
최종 수정일: 2025년 7월