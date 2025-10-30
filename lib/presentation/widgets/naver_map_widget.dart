import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/location_service.dart';
import '../../domain/entities/company_entity.dart';

class NaverMapWidget extends StatefulWidget {
  final List<CompanyEntity> companies;
  final Function(CompanyEntity)? onCompanyTapped;

  const NaverMapWidget({
    super.key,
    required this.companies,
    this.onCompanyTapped,
  });

  @override
  State<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoading = true;
  bool _mapLoadingError = false;
  String? _mapImageUrl;
  
  // 네이버 로그인 API 설정 (Static Map도 동일한 키 사용) - 현재 사용하지 않음
  // static String get _naverClientId => dotenv.env['Naver_client_ID'] ?? '6VBjy8uAYG4OQuVORB0s';
  // static String get _naverClientSecret => dotenv.env['Naver_client_secect'] ?? '2IwucUmbaX';

  @override
  void initState() {
    super.initState();
    debugPrint('🗺️ NaverMapWidget 초기화 시작');
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      debugPrint('🗺️ [1/4] 위치 정보 가져오기 시작');
      
      final position = await _locationService.getCurrentLocation();
      
      if (position != null) {
        _currentPosition = position;
        debugPrint('✅ [1/4] 현재 위치 획득: ${position.latitude}, ${position.longitude}');
      } else {
        debugPrint('⚠️ [1/4] 위치 정보 없음, 기본 위치 사용');
        _currentPosition = Position(
          latitude: 37.5665,
          longitude: 126.9780,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
      
      debugPrint('🗺️ [2/4] 지도 이미지 URL 생성 시작');
      await _generateMapImageUrl();
      debugPrint('✅ [2/4] 지도 이미지 URL 생성 완료');
      
    } catch (e, stackTrace) {
      debugPrint('❌ [ERROR] 지도 초기화 중 에러 발생');
      debugPrint('❌ 에러 타입: ${e.runtimeType}');
      debugPrint('❌ 에러 메시지: $e');
      debugPrint('❌ 스택 트레이스: $stackTrace');
      
      // 기본 위치로 폴백
      _currentPosition = Position(
        latitude: 37.5665,
        longitude: 126.9780,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      
      try {
        debugPrint('🔄 기본 위치로 지도 이미지 URL 재생성 시도');
        await _generateMapImageUrl();
      } catch (e2) {
        debugPrint('❌ 기본 위치로도 지도 생성 실패: $e2');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _mapLoadingError = true;
          });
        }
        return;
      }
    }
  }

  Future<void> _generateMapImageUrl() async {
    try {
      final lat = _currentPosition?.latitude ?? 37.5665;
      final lng = _currentPosition?.longitude ?? 126.9780;
      
      debugPrint('🗺️ [2/4] 위치 정보: lat=$lat, lng=$lng');
      
      // Google Static Map API URL 생성
      const width = 353;
      const height = 159;
      const zoom = 14;
      
      // 마커 정보 생성 (현재 위치) - 현재 사용하지 않음
      // final markers = 'type:t|size:mid|pos:$lng $lat|label:';
      
      // 회사 마커들 추가 (Google Maps 형식)
      String companyMarkers = '';
      int validCompanyCount = 0;
      
      debugPrint('🗺️ [2/4] 전체 회사 수: ${widget.companies.length}');
      
      // 테스트용 가짜 회사 데이터 (실제 데이터가 없을 때)
      List<CompanyEntity> testCompanies = [];
      if (widget.companies.isEmpty) {
        debugPrint('🗺️ [2/4] 실제 회사 데이터가 없어서 테스트 데이터 사용');
        testCompanies = [
          // 현재 위치 주변 테스트 회사들
          CompanyEntity(
            id: 'test1',
            companyName: '스타벅스 강남점',
            ceoName: '김사장',
            phone: '02-123-4567',
            address: '서울시 강남구',
            detailAddress: '테헤란로 123',
            category: '음식점',
            subcategory: '카페',
            latitude: lat + 0.01, // 현재 위치에서 약 1km 북쪽
            longitude: lng + 0.01,
            photos: [],
            adPayment: 50000, // 프리미엄
            isVerified: true,
            createdAt: DateTime.now(),
          ),
          CompanyEntity(
            id: 'test2', 
            companyName: '맥도날드',
            ceoName: '이대표',
            phone: '02-234-5678',
            address: '서울시 강남구',
            detailAddress: '역삼동 456',
            category: '음식점',
            subcategory: '패스트푸드',
            latitude: lat - 0.005, // 현재 위치에서 약 500m 남쪽
            longitude: lng + 0.005,
            photos: [],
            adPayment: 0, // 일반
            isVerified: true,
            createdAt: DateTime.now(),
          ),
          CompanyEntity(
            id: 'test3',
            companyName: '롯데리아',
            ceoName: '박사장',
            phone: '02-345-6789',
            address: '서울시 강남구',
            detailAddress: '삼성동 789',
            category: '음식점',
            subcategory: '패스트푸드',
            latitude: lat + 0.003,
            longitude: lng - 0.008,
            photos: [],
            adPayment: 30000, // 프리미엄
            isVerified: true,
            createdAt: DateTime.now(),
          ),
        ];
      }
      
      final companiesToShow = widget.companies.isNotEmpty ? widget.companies : testCompanies;
      debugPrint('🗺️ [2/4] 표시할 회사 수: ${companiesToShow.length}');
      
      for (int i = 0; i < companiesToShow.length && i < 15; i++) {
        final company = companiesToShow[i];
        debugPrint('🗺️ [2/4] 회사 $i: ${company.companyName}, 위도: ${company.latitude}, 경도: ${company.longitude}, 광고결제: ${company.adPayment}');
        
        if (company.latitude != null && company.longitude != null) {
          // 프리미엄 업체와 일반 업체 구분
          final markerColor = company.adPayment > 0 ? 'blue' : 'green';
          final markerSize = company.adPayment > 0 ? 'mid' : 'small';
          final markerLabel = company.adPayment > 0 ? 'P' : (validCompanyCount + 1).toString();
          
          companyMarkers += '&markers=color:$markerColor%7Csize:$markerSize%7Clabel:$markerLabel%7C${company.latitude},${company.longitude}';
          validCompanyCount++;
          
          debugPrint('🗺️ [2/4] ✅ 마커 추가: ${company.companyName} (${company.latitude}, ${company.longitude}) - ${company.adPayment > 0 ? 'Premium' : 'Regular'}');
        } else {
          debugPrint('🗺️ [2/4] ❌ 위치 정보 없음: ${company.companyName}');
        }
      }
      
      debugPrint('🗺️ [2/4] 유효한 회사 마커 $validCompanyCount개 추가 완료');
      
      // Google Static Maps API 사용 (더 안정적)
      final googleApiKey = dotenv.env['Google_Maps_API'] ?? 'AIzaSyAQaAqDNxtkH0D_tPv39VtqIzn9dgZnViA';
      
      // 현재 위치 마커 (빨간색, 큰 사이즈)
      final currentLocationMarker = '&markers=color:red%7Csize:mid%7Clabel:ME%7C$lat,$lng';
      
      _mapImageUrl = 'https://maps.googleapis.com/maps/api/staticmap'
          '?center=$lat,$lng'
          '&zoom=$zoom'
          '&size=${width}x$height'
          '$currentLocationMarker'
          '$companyMarkers'
          '&maptype=roadmap'
          '&key=$googleApiKey';
      
      debugPrint('🗺️ [2/4] 최종 지도 URL (${_mapImageUrl!.length}자): ${_mapImageUrl!.substring(0, _mapImageUrl!.length > 200 ? 200 : _mapImageUrl!.length)}...');
      
      debugPrint('🗺️ [2/4] 인증 포함 지도 URL: $_mapImageUrl');
      
      // 지도 이미지가 유효한지 확인
      debugPrint('🗺️ [3/4] 지도 이미지 유효성 검사 시작');
      await _validateMapImage();
      
    } catch (e, stackTrace) {
      debugPrint('❌ [ERROR] 지도 이미지 URL 생성 중 에러 발생');
      debugPrint('❌ 에러 타입: ${e.runtimeType}');
      debugPrint('❌ 에러 메시지: $e');
      debugPrint('❌ 스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  Future<void> _validateMapImage() async {
    if (_mapImageUrl == null) {
      debugPrint('❌ [3/4] 지도 URL이 null입니다');
      return;
    }
    
    try {
      debugPrint('🔍 [3/4] 지도 이미지 유효성 검사 시작');
      debugPrint('🔍 [3/4] 검사할 URL: $_mapImageUrl');
      
      // Google Static Maps API는 인증 헤더가 필요 없음 (URL에 key 포함)
      final response = await http.head(Uri.parse(_mapImageUrl!));
      
      debugPrint('🔍 [3/4] HTTP 응답 코드: ${response.statusCode}');
      debugPrint('🔍 [3/4] HTTP 헤더: ${response.headers}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ [3/4] 지도 이미지 유효성 검사 성공');
        debugPrint('✅ [4/4] 지도 위젯 초기화 완료');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _mapLoadingError = false;
          });
        }
      } else {
        debugPrint('⚠️ [3/4] 지도 이미지 응답 에러: ${response.statusCode}');
        debugPrint('⚠️ [3/4] 응답 본문: ${response.body}');
        
        // 에러여도 일단 이미지를 표시해보자
        if (mounted) {
          setState(() {
            _isLoading = false;
            _mapLoadingError = false; // false로 설정하여 이미지 표시 시도
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [ERROR] 지도 이미지 유효성 검사 중 에러 발생');
      debugPrint('❌ 에러 타입: ${e.runtimeType}');
      debugPrint('❌ 에러 메시지: $e');
      debugPrint('❌ 스택 트레이스: $stackTrace');
      
      // 에러가 발생해도 이미지 로드를 시도해보자
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mapLoadingError = false; // false로 설정하여 이미지 표시 시도
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 159.h, // 지도 이미지 높이와 동일하게 설정
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_mapLoadingError || _mapImageUrl == null) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        _buildMapImage(),
        _buildControls(),
        _buildLocationInfo(),
      ],
    );
  }

  Widget _buildMapImage() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.network(
        _mapImageUrl!,
        // Google Static Maps API는 특별한 헤더 필요 없음
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 8.h),
                  Text(
                    '지도 이미지 로딩 중...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ 지도 이미지 로드 에러: $error');
          return Container(
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '지도 이미지 로드 실패',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationInfo() {
    final lat = _currentPosition?.latitude ?? 37.5665;
    final lng = _currentPosition?.longitude ?? 126.9780;
    
    return Positioned(
      bottom: 8.h,
      left: 8.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🗺️ Google 지도',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              '지도 준비 중...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 24.sp, // 작은 높이에 맞게 아이콘 크기 축소
              color: Colors.orange[400],
            ),
            SizedBox(height: 8.h),
            Text(
              '지도를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 12.sp, // 폰트 크기 축소
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Google Maps API 설정을 확인해주세요',
              style: TextStyle(
                fontSize: 10.sp, // 폰트 크기 축소
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _mapLoadingError = false;
                      _isLoading = true;
                      _mapImageUrl = null;
                    });
                    _initializeMap();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), // 패딩 축소
                    textStyle: TextStyle(fontSize: 10.sp), // 텍스트 크기 축소
                  ),
                  child: const Text('다시 시도'),
                ),
                SizedBox(width: 4.w),
                ElevatedButton.icon(
                  onPressed: _openNaverMap,
                  icon: const Icon(Icons.open_in_new, size: 12),
                  label: const Text('지도앱'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    textStyle: TextStyle(fontSize: 10.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      top: 4.h, // 상단 여백 축소
      right: 4.w, // 우측 여백 축소
      child: Row( // Column에서 Row로 변경하여 가로 배치
        children: [
          _buildControlButton(
            icon: Icons.refresh,
            onTap: () {
              setState(() {
                _isLoading = true;
                _mapLoadingError = false;
                _mapImageUrl = null;
              });
              _initializeMap();
            },
            tooltip: '새로고침',
          ),
          SizedBox(width: 4.w), // 가로 간격
          _buildControlButton(
            icon: Icons.open_in_new,
            onTap: _openNaverMap,
            tooltip: '지도앱에서 보기',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              icon,
              size: 20.sp,
              color: const Color(0xFF1E3A5F),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNaverMap() async {
    final lat = _currentPosition?.latitude ?? 37.5665;
    final lng = _currentPosition?.longitude ?? 126.9780;
    
    // 네이버지도 앱에서 열기
    final naverMapUrl = 'nmap://place?lat=$lat&lng=$lng&name=현재위치';
    final webUrl = 'https://map.naver.com/v5/search/현재위치/$lng,$lat';
    
    try {
      if (await canLaunchUrl(Uri.parse(naverMapUrl))) {
        await launchUrl(Uri.parse(naverMapUrl));
      } else {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ 네이버지도 열기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지도를 열 수 없습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

}