import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/location_service.dart';
import '../../../domain/entities/company_entity.dart';

class FullscreenMapView extends StatefulWidget {
  final List<CompanyEntity> companies;
  final Function(CompanyEntity)? onCompanyTapped;
  final Position? currentPosition;

  const FullscreenMapView({
    super.key,
    required this.companies,
    this.onCompanyTapped,
    this.currentPosition,
  });

  @override
  State<FullscreenMapView> createState() => _FullscreenMapViewState();
}

class _FullscreenMapViewState extends State<FullscreenMapView> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentPosition;
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (_currentPosition == null) {
      try {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          _currentPosition = position;
        }
      } catch (e) {
        debugPrint('위치 초기화 실패: $e');
      }
    }
    
    await _setupMarkers();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setupMarkers() async {
    Set<Marker> markers = {};

    // 현재 위치 마커 추가
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: '내 위치'),
        ),
      );
    }

    // 회사 마커들 추가
    for (int i = 0; i < widget.companies.length; i++) {
      final company = widget.companies[i];
      
      if (company.latitude != null && company.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId('company_${company.id}'),
            position: LatLng(company.latitude!, company.longitude!),
            icon: company.adPayment > 0 
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: company.companyName,
              snippet: company.subcategory,
            ),
            onTap: () => _onMarkerTapped(company),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMarkerTapped(CompanyEntity company) {
    debugPrint('마커 탭됨: ${company.companyName}');
    
    if (widget.onCompanyTapped != null) {
      widget.onCompanyTapped!(company);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${company.companyName} - ${company.subcategory}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 20.sp,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            '지도',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _buildFullscreenMap(),
    );
  }

  Widget _buildFullscreenMap() {
    // Google Maps API 키 설정 후 안정성을 위해 임시로 플레이스홀더 표시
    return Container(
      color: Colors.grey[900],
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  color: Colors.white,
                  size: 64.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Google Maps 준비중',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'API 키: 설정 완료',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                ),
                if (widget.companies.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    '주변 업체 ${widget.companies.length}개',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 플로팅 액션 버튼들
          Positioned(
            bottom: 100.h,
            right: 16.w,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "location",
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[700],
                  onPressed: _moveToCurrentLocation,
                  child: Icon(Icons.my_location, size: 20.sp),
                ),
                SizedBox(height: 8.h),
                FloatingActionButton(
                  heroTag: "maptype",
                  mini: true,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[700],
                  onPressed: _showMapTypeInfo,
                  child: Icon(Icons.layers, size: 20.sp),
                ),
              ],
            ),
          ),
          
          // 업체 정보
          if (widget.companies.isNotEmpty)
            Positioned(
              top: 100.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business,
                      color: Colors.blue[700],
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '업체 ${widget.companies.length}개',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoogleMapFullscreen() {
    double lat = _currentPosition?.latitude ?? 37.5665;
    double lng = _currentPosition?.longitude ?? 126.9780;

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: 12.0,
          ),
          markers: _markers,
          onTap: _onMapTapped,
          myLocationEnabled: _currentPosition != null,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
        ),
        
        // 플로팅 액션 버튼들
        Positioned(
          bottom: 100.h,
          right: 16.w,
          child: Column(
            children: [
              // 현재 위치 버튼
              FloatingActionButton(
                heroTag: "location",
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[700],
                onPressed: _moveToCurrentLocation,
                child: Icon(Icons.my_location, size: 20.sp),
              ),
              SizedBox(height: 8.h),
              
              // 지도 타입 버튼
              FloatingActionButton(
                heroTag: "maptype",
                mini: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[700],
                onPressed: _showMapTypeInfo,
                child: Icon(Icons.layers, size: 20.sp),
              ),
            ],
          ),
        ),
        
        // 업체 정보
        if (widget.companies.isNotEmpty)
          Positioned(
            top: 100.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business,
                    color: Colors.blue[700],
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '업체 ${widget.companies.length}개',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    debugPrint('✅ Google 지도 준비 완료');
    
    // 모든 마커가 보이도록 카메라 조정
    if (_markers.isNotEmpty) {
      _fitBoundsToMarkers();
    }
  }

  void _fitBoundsToMarkers() {
    if (_mapController == null || _markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (final marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          100.0,
        ),
      );
    } catch (e) {
      debugPrint('카메라 피팅 실패: $e');
    }
  }

  void _onMapTapped(LatLng latLng) {
    debugPrint('지도 탭됨: ${latLng.latitude}, ${latLng.longitude}');
  }

  void _moveToCurrentLocation() {
    if (_mapController == null || _currentPosition == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('현재 위치를 가져올 수 없습니다'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      debugPrint('현재 위치로 이동 실패: $e');
    }
  }

  void _showMapTypeInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Maps 활성화됨'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}