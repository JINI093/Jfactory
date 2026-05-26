import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/entities/company_entity.dart';

class FullscreenMapView extends StatefulWidget {
  final List<CompanyEntity> companies;
  final Function(CompanyEntity)? onCompanyTapped;
  final String? mapImageUrl;
  final List<CompanyEntity> markerCompanies;
  final Map<String, LatLng> markerPositions;
  final double? initialLat;
  final double? initialLng;

  const FullscreenMapView({
    super.key,
    required this.companies,
    this.onCompanyTapped,
    this.mapImageUrl,
    this.markerCompanies = const [],
    this.markerPositions = const {},
    this.initialLat,
    this.initialLng,
  });

  @override
  State<FullscreenMapView> createState() => _FullscreenMapViewState();
}

class _FullscreenMapViewState extends State<FullscreenMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  static const double _fallbackLat = 37.5665;
  static const double _fallbackLng = 126.9780;

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  void _buildMarkers() {
    final source = widget.markerCompanies.isNotEmpty
        ? widget.markerCompanies
        : widget.companies;
    final markers = <Marker>{};

    for (final company in source) {
      final overridePosition = widget.markerPositions[company.id];
      final lat = overridePosition?.latitude ?? company.latitude;
      final lng = overridePosition?.longitude ?? company.longitude;
      if (lat != null && lng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('company_${company.id}'),
            position: LatLng(lat, lng),
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

    _markers = markers;
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
      body: _buildGoogleMapFullscreen(),
    );
  }

  Widget _buildGoogleMapFullscreen() {
    final initial = _resolveInitialPosition();

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: initial,
            zoom: 12.0,
          ),
          markers: _markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
        ),
      ],
    );
  }

  LatLng _resolveInitialPosition() {
    if (widget.initialLat != null && widget.initialLng != null) {
      return LatLng(widget.initialLat!, widget.initialLng!);
    }
    if (_markers.isNotEmpty) {
      return _markers.first.position;
    }
    if (widget.markerPositions.isNotEmpty) {
      return widget.markerPositions.values.first;
    }
    return const LatLng(_fallbackLat, _fallbackLng);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80.0,
      ),
    );
  }

  void _onMarkerTapped(CompanyEntity company) {
    if (widget.onCompanyTapped != null) {
      widget.onCompanyTapped!(company);
    }
  }
}