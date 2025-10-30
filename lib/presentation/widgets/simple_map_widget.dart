import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../domain/entities/company_entity.dart';

class SimpleMapWidget extends StatefulWidget {
  final List<CompanyEntity> companies;
  final Function(CompanyEntity)? onCompanyTapped;

  const SimpleMapWidget({
    Key? key,
    required this.companies,
    this.onCompanyTapped,
  }) : super(key: key);

  @override
  State<SimpleMapWidget> createState() => _SimpleMapWidgetState();
}

class _SimpleMapWidgetState extends State<SimpleMapWidget> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;
        
        // Get address from coordinates
        final address = await _locationService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude,
        );
        _currentAddress = address;
      }
    } catch (e) {
      debugPrint('위치 가져오기 실패: $e');
      _errorMessage = '위치 정보를 가져올 수 없습니다.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[700], size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _currentAddress ?? '위치 정보 없음',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_currentPosition != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '현재 위치',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Map content
          Expanded(
            child: _buildMapContent(),
          ),
          
          // Footer
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '주변 기업: ${widget.companies.length}개',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Open full map view
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('전체 지도 보기 기능은 곧 추가됩니다'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text(
                    '전체 보기 →',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 32.sp, color: Colors.grey[400]),
            SizedBox(height: 8.h),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _getCurrentLocation();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              ),
              child: Text(
                '다시 시도',
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current location info
          if (_currentPosition != null) ...[
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '현재 위치',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
          
          // Nearby companies
          Text(
            '주변 기업 목록',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          
          Expanded(
            child: widget.companies.isEmpty
                ? Center(
                    child: Text(
                      '주변에 등록된 기업이 없습니다',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.companies.length.clamp(0, 3),
                    itemBuilder: (context, index) {
                      final company = widget.companies[index];
                      double? distance;
                      
                      if (_currentPosition != null && 
                          company.latitude != null && 
                          company.longitude != null) {
                        distance = _locationService.calculateDistance(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          company.latitude!,
                          company.longitude!,
                        );
                      }
                      
                      return GestureDetector(
                        onTap: () {
                          if (widget.onCompanyTapped != null) {
                            widget.onCompanyTapped!(company);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: company.adPayment > 0 
                                      ? Colors.orange[500]
                                      : Colors.grey[500],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      company.companyName,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      company.subcategory,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (distance != null)
                                Text(
                                  _locationService.formatDistance(distance),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}