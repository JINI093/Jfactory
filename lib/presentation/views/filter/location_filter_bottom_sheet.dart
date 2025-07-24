import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationFilterBottomSheet extends StatefulWidget {
  const LocationFilterBottomSheet({super.key});

  @override
  State<LocationFilterBottomSheet> createState() => _LocationFilterBottomSheetState();
}

class _LocationFilterBottomSheetState extends State<LocationFilterBottomSheet> {
  String? selectedRegion;
  String? selectedDistrict;
  
  final Map<String, List<String>> regions = {
    '서울': [
      '전체', '전지역',
      '강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구',
      '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구',
      '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구'
    ],
    '부산': [
      '전체', '전지역',
      '강서구', '금정구', '기장군', '남구', '동구', '동래구', '부산진구', '북구',
      '사상구', '사하구', '서구', '수영구', '연제구', '영도구', '중구', '해운대구'
    ],
    '대구': [
      '전체', '전지역',
      '남구', '달서구', '달성군', '동구', '북구', '서구', '수성구', '중구'
    ],
    '인천': [
      '전체', '전지역',
      '강화군', '계양구', '미추홀구', '남동구', '동구', '부평구', '서구', '연수구', '옹진군', '중구'
    ],
    '광주': [
      '전체', '전지역',
      '광산구', '남구', '동구', '북구', '서구'
    ],
    '대전': [
      '전체', '전지역',
      '대덕구', '동구', '서구', '유성구', '중구'
    ],
    '울산': [
      '전체', '전지역',
      '남구', '동구', '북구', '울주군', '중구'
    ],
    '세종': [
      '전체', '전지역', '세종시'
    ],
    '경기': [
      '전체', '전지역',
      '가평군', '고양시', '과천시', '광명시', '광주시', '구리시', '군포시', '김포시',
      '남양주시', '동두천시', '부천시', '성남시', '수원시', '시흥시', '안산시', '안성시',
      '안양시', '양주시', '양평군', '여주시', '연천군', '오산시', '용인시', '의왕시',
      '의정부시', '이천시', '파주시', '평택시', '포천시', '하남시', '화성시'
    ],
    '강원': [
      '전체', '전지역',
      '강릉시', '고성군', '동해시', '삼척시', '속초시', '양구군', '양양군', '영월군',
      '원주시', '인제군', '정선군', '철원군', '춘천시', '태백시', '평창군', '홍천군', '화천군', '횡성군'
    ],
    '충북': [
      '전체', '전지역',
      '괴산군', '단양군', '보은군', '영동군', '옥천군', '음성군', '제천시', '진천군', '청주시', '충주시', '증평군'
    ],
    '충남': [
      '전체', '전지역',
      '계룡시', '공주시', '금산군', '논산시', '당진시', '보령시', '부여군', '서산시',
      '서천군', '아산시', '예산군', '천안시', '청양군', '태안군', '홍성군'
    ],
    '전북': [
      '전체', '전지역',
      '고창군', '군산시', '김제시', '남원시', '무주군', '부안군', '순창군', '완주군',
      '익산시', '임실군', '장수군', '전주시', '정읍시', '진안군'
    ],
    '전남': [
      '전체', '전지역',
      '강진군', '고흥군', '곡성군', '구례군', '나주시', '담양군', '목포시', '무안군',
      '보성군', '순천시', '신안군', '여수시', '영광군', '영암군', '완도군', '장성군',
      '장흥군', '진도군', '함평군', '해남군', '화순군'
    ],
    '경북': [
      '전체', '전지역',
      '경산시', '경주시', '고령군', '구미시', '군위군', '김천시', '문경시', '봉화군',
      '상주시', '성주군', '안동시', '영덕군', '영양군', '영주시', '영천시', '예천군',
      '울릉군', '울진군', '의성군', '청도군', '청송군', '칠곡군', '포항시'
    ],
    '경남': [
      '전체', '전지역',
      '거제시', '거창군', '고성군', '김해시', '남해군', '밀양시', '사천시', '산청군',
      '양산시', '의령군', '진주시', '창녕군', '창원시', '통영시', '하동군', '함안군',
      '함양군', '합천군'
    ],
    '제주': [
      '전체', '전지역',
      '서귀포시', '제주시'
    ],
  };

  List<String> get districts {
    if (selectedRegion == null) return [];
    return regions[selectedRegion!] ?? [];
  }

  void _resetFilters() {
    setState(() {
      selectedRegion = null;
      selectedDistrict = null;
    });
  }

  void _applyFilters() {
    // Return the selected filters
    Navigator.of(context).pop({
      'region': selectedRegion,
      'district': selectedDistrict,
    });
  }

  int get _resultCount {
    // Mock result count based on selection
    if (selectedRegion == null) return 31894;
    if (selectedDistrict == null || selectedDistrict == '전체' || selectedDistrict == '전지역') {
      return 31894;
    }
    return 31894; // This would be calculated based on actual filters
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildRegionList(),
                _buildDistrictList(),
              ],
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '지역선택',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionList() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.grey[50],
        child: ListView(
          children: regions.keys.map((region) {
            final isSelected = selectedRegion == region;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedRegion = region;
                  selectedDistrict = null; // Reset district when region changes
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: isSelected 
                    ? Border(right: BorderSide(color: const Color(0xFF1E3A5F), width: 2))
                    : null,
                ),
                child: Text(
                  region,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF1E3A5F) : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDistrictList() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            if (districts.isNotEmpty)
              Expanded(
                child: ListView(
                  children: districts.map((district) {
                    final isSelected = selectedDistrict == district;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDistrict = district;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE8F4FD) : Colors.transparent,
                        ),
                        child: Text(
                          district,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? const Color(0xFF1E3A5F) : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Selected filter chip
          if (selectedRegion != null && selectedDistrict != null && selectedDistrict != '전체')
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$selectedRegion > $selectedDistrict',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDistrict = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Bottom buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 18.sp,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '지역 초기화',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _applyFilters,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '${_resultCount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}개 결과보기',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showLocationFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const LocationFilterBottomSheet(),
  ).then((result) {
    if (result != null) {
      // Handle the filter result
      print('Selected filters: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필터 적용: ${result['region']} > ${result['district']}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  });
}