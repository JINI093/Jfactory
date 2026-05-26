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
    } catch (e) {
      debugPrint('위치 초기화 실패: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Google Maps API 키 설정 후 안정성을 위해 임시로 플레이스홀더 표시
    return _buildMapPlaceholder();
  }

  Widget _buildMapPlaceholder() {
    return GestureDetector(
      onTap: _openFullscreenMap,
      child: Container(
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
    final markerCompanies = widget.companies
        .where((company) => company.latitude != null && company.longitude != null)
        .toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenMapView(
          companies: widget.companies,
          onCompanyTapped: widget.onCompanyTapped,
          mapImageUrl: null,
          markerCompanies: markerCompanies,
          initialLat: _currentPosition?.latitude,
          initialLng: _currentPosition?.longitude,
        ),
      ),
    );
  }
}