import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../domain/entities/company_entity.dart';
import '../views/map/fullscreen_map_view.dart';

class EnhancedMapWidget extends StatefulWidget {
  final List<CompanyEntity> companies;
  final Function(CompanyEntity)? onCompanyTapped;

  const EnhancedMapWidget({
    super.key,
    required this.companies,
    this.onCompanyTapped,
  });

  @override
  State<EnhancedMapWidget> createState() => _EnhancedMapWidgetState();
}

class _EnhancedMapWidgetState extends State<EnhancedMapWidget> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  bool _mapLoadingError = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
      }
      
      await _setupMarkers();
    } catch (e) {
      debugPrint('위치 초기화 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Google Maps API 키 설정 후 안정성을 위해 임시로 플레이스홀더 표시
    return _buildMapPlaceholder();
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Google Maps 준비중',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (widget.companies.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '주변 업체 ${widget.companies.length}개',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildMapControls(),
        ],
      ),
    );
  }


  Widget _buildGoogleMap() {
    double lat = _currentPosition?.latitude ?? 37.5665;
    double lng = _currentPosition?.longitude ?? 126.9780;

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Stack(
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
            _buildMapControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 8.h,
      right: 8.w,
      child: Column(
        children: [
          // 현재 위치 버튼
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 20.sp,
              padding: EdgeInsets.all(8.w),
              constraints: BoxConstraints(
                minWidth: 32.w,
                minHeight: 32.h,
              ),
              onPressed: _moveToCurrentLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.blue[700],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          
          // 업체 수 배지
          if (widget.companies.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${widget.companies.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
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
      // API 키 문제일 가능성이 있으므로 플레이스홀더로 전환
      if (mounted) {
        setState(() {
          _mapLoadingError = true;
        });
      }
    }
  }

  void _onMapTapped(LatLng latLng) {
    debugPrint('지도 탭됨: ${latLng.latitude}, ${latLng.longitude}');
    _openFullscreenMap();
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

  void _openFullscreenMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenMapView(
          companies: widget.companies,
          onCompanyTapped: widget.onCompanyTapped,
          currentPosition: _currentPosition,
        ),
      ),
    );
  }
}