import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../domain/entities/company_entity.dart';

class GoogleMapWidget extends StatefulWidget {
  final List<CompanyEntity> companies;
  final Function(CompanyEntity)? onCompanyTapped;
  final double? initialLat;
  final double? initialLng;
  final double initialZoom;

  const GoogleMapWidget({
    super.key,
    required this.companies,
    this.onCompanyTapped,
    this.initialLat,
    this.initialLng,
    this.initialZoom = 11.0,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};

  // 기본 좌표 (서울 중심가)
  static const double _defaultLat = 37.5665;
  static const double _defaultLng = 126.9780;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // 현재 위치 가져오기 시도
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
      }
      
      // 마커들 설정
      await _setupMarkers();
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
      _errorMessage = '위치 정보를 가져올 수 없습니다.';
    } finally {
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
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _requestLocationPermission,
                child: const Text('위치 권한 요청'),
              ),
            ],
          ),
        ),
      );
    }

    // 초기 카메라 위치 결정
    double lat = widget.initialLat ?? 
                 _currentPosition?.latitude ?? 
                 _defaultLat;
    double lng = widget.initialLng ?? 
                 _currentPosition?.longitude ?? 
                 _defaultLng;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: widget.initialZoom,
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
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    debugPrint('✅ Google 지도 준비 완료');
  }

  void _onMapTapped(LatLng latLng) {
    // 지도 탭 처리
    debugPrint('지도 탭됨: ${latLng.latitude}, ${latLng.longitude}');
  }

  void _onMarkerTapped(CompanyEntity company) {
    // 마커 탭 처리
    debugPrint('마커 탭됨: ${company.companyName}');
    
    if (widget.onCompanyTapped != null) {
      widget.onCompanyTapped!(company);
    }
  }

  Future<void> _requestLocationPermission() async {
    final hasPermission = await _locationService.requestLocationPermission();
    
    if (hasPermission) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      await _initializeMap();
    } else {
      setState(() {
        _errorMessage = '위치 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      });
    }
  }

  /// 특정 위치로 카메라 이동
  void moveCamera(double lat, double lng, {double? zoom}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: zoom ?? widget.initialZoom,
        ),
      ),
    );
  }

  /// 현재 위치로 카메라 이동
  void moveToCurrentLocation() {
    if (_currentPosition != null) {
      moveCamera(
        _currentPosition!.latitude, 
        _currentPosition!.longitude,
        zoom: 15.0,
      );
    }
  }

  /// 모든 마커가 보이도록 카메라 조정
  void fitToMarkers() {
    if (_markers.isEmpty) return;

    // Get bounds from all markers
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

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }
}