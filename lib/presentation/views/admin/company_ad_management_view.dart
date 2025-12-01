import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyAdManagementView extends StatefulWidget {
  const CompanyAdManagementView({super.key});

  @override
  State<CompanyAdManagementView> createState() => _CompanyAdManagementViewState();
}

class _CompanyAdManagementViewState extends State<CompanyAdManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedTab = 'premium'; // 'premium', 'active', 'scheduled'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _premiumPriceController = TextEditingController(text: '30000');
  int _currentPage = 1;
  final int _itemsPerPage = 9;

  @override
  void dispose() {
    _searchController.dispose();
    _premiumPriceController.dispose();
    super.dispose();
  }

  // 반응형 폰트 크기 계산
  double _responsiveFontSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 1200) {
      return baseSize * 0.7;
    } else if (screenWidth < 1600) {
      return baseSize * 0.85;
    } else {
      return baseSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 헤더 영역
          Container(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Text(
                  '기업광고 관리',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // 검색바
                SizedBox(
                  width: 200.w,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                  child: Text(
                    '검색',
                    style: TextStyle(fontSize: _responsiveFontSize(12)),
                  ),
                ),
              ],
            ),
          ),
          
          // 프리미엄 광고 가격 설정
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '프리미엄 광고',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 24.w),
                Text(
                  '광고금액(1일)',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(14),
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 150.w,
                  child: TextField(
                    controller: _premiumPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffixText: '원',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _updatePremiumPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                  child: Text(
                    '가격수정',
                    style: TextStyle(fontSize: _responsiveFontSize(12)),
                  ),
                ),
              ],
            ),
          ),
          
          // 탭 및 광고 목록
          Expanded(
            child: Column(
              children: [
                // 탭
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    children: [
                      _buildTab('프리미엄 광고', 'premium'),
                      SizedBox(width: 8.w),
                      _buildTab('광고중', 'active'),
                      SizedBox(width: 8.w),
                      _buildTab('광고예정', 'scheduled'),
                    ],
                  ),
                ),
                // 광고 목록 및 페이지네이션
                Expanded(
                  child: _buildAdGrid(),
                ),
                // 하단 버튼
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: 수정 기능
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: Text(
                          '수정',
                          style: TextStyle(fontSize: _responsiveFontSize(12)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: 삭제 기능
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: Text(
                          '삭제',
                          style: TextStyle(fontSize: _responsiveFontSize(12)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: 확인 기능
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: Text(
                          '확인',
                          style: TextStyle(fontSize: _responsiveFontSize(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = value;
          _currentPage = 1;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.grey[400],
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: _responsiveFontSize(14),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAdGrid() {
    Query query = _firestore.collection('purchases');

    // 탭에 따른 필터
    if (_selectedTab == 'premium') {
      try {
        query = query.where('purchaseType', isEqualTo: 'premiumAd');
      } catch (e) {
        debugPrint('premium 필터 오류: $e');
      }
    } else if (_selectedTab == 'active') {
      try {
        query = query.where('status', isEqualTo: 'active');
      } catch (e) {
        debugPrint('active 필터 오류: $e');
      }
    } else if (_selectedTab == 'scheduled') {
      try {
        query = query.where('status', isEqualTo: 'pending');
      } catch (e) {
        debugPrint('scheduled 필터 오류: $e');
      }
    }

    // orderBy는 인덱스가 필요하므로 클라이언트 사이드에서 정렬
    // query = query.orderBy('purchaseDate', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('기업광고 관리 페이지 오류: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  '오류: ${snapshot.error}',
                  style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'purchases 컬렉션을 확인해주세요.',
                  style: TextStyle(fontSize: _responsiveFontSize(10), color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final ads = snapshot.data?.docs ?? [];
        
        // 날짜 기준으로 정렬 (클라이언트 사이드)
        final sortedAds = ads.toList()..sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = _parseDate(aData['purchaseDate'] ?? aData['createdAt']);
          final bDate = _parseDate(bData['purchaseDate'] ?? bData['createdAt']);
          
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          
          return bDate.compareTo(aDate); // 내림차순
        });
        
        // 검색 필터 적용
        final filteredAds = sortedAds.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final companyId = data['companyId'] ?? data['userId'] ?? '';
          final adName = data['adName'] ?? data['title'] ?? '';
          final query = _searchQuery.toLowerCase();
          
          return companyId.toLowerCase().contains(query) || 
                 adName.toLowerCase().contains(query);
        }).toList();

        if (filteredAds.isEmpty) {
          return Center(
            child: Text(
              '등록된 광고가 없습니다',
              style: TextStyle(fontSize: _responsiveFontSize(14), color: Colors.grey[600]),
            ),
          );
        }

        // 페이지네이션 계산
        final totalPages = (filteredAds.length / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        final paginatedAds = filteredAds.sublist(
          startIndex,
          endIndex > filteredAds.length ? filteredAds.length : endIndex,
        );

        return Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(24.w),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: paginatedAds.length,
                  itemBuilder: (context, index) {
                    final adDoc = paginatedAds[index];
                    final adData = adDoc.data() as Map<String, dynamic>;
                    return _buildAdCard(adDoc.id, adData);
                  },
                ),
              ),
            ),
            // 페이지네이션
            _buildPagination(totalPages),
          ],
        );
      },
    );
  }

  Widget _buildAdCard(String adId, Map<String, dynamic> adData) {
    final companyId = adData['companyId'] ?? adData['userId'] ?? '';
    final purchaseDate = _formatDate(adData['purchaseDate'] ?? adData['createdAt'] ?? adData['purchaseDate']);
    final adPeriod = _getAdPeriod(adData);
    final adName = adData['adName'] ?? adData['title'] ?? '기업광고';
    final status = adData['status'] ?? adData['adStatus'] ?? 'active';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기업명',
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _getCompanyName(companyId),
            style: TextStyle(
              fontSize: _responsiveFontSize(14),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '구매일',
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            purchaseDate,
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '광고 기한',
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            adPeriod,
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '광고명',
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            adName,
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: status == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              status == 'active' ? '광고중' : '대기중',
              style: TextStyle(
                fontSize: _responsiveFontSize(10),
                color: status == 'active' ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),
          ...List.generate(
            totalPages > 10 ? 10 : totalPages,
            (index) {
              final pageNum = index + 1;
              final isCurrentPage = _currentPage == pageNum;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentPage = pageNum;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentPage ? Colors.grey[600] : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '$pageNum',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(12),
                      color: isCurrentPage ? Colors.white : Colors.black87,
                      fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  String _getCompanyName(String companyId) {
    // TODO: Firestore에서 기업명 조회
    return companyId.isNotEmpty ? companyId : '기업명 없음';
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '정보 없음';
    
    try {
      DateTime date;
      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return '정보 없음';
      }
      
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '정보 없음';
    }
  }

  String _getAdPeriod(Map<String, dynamic> adData) {
    final purchaseDate = _parseDate(adData['purchaseDate'] ?? adData['createdAt']);
    final expiryDate = _parseDate(adData['expiryDate'] ?? adData['endDate']);
    
    if (purchaseDate != null && expiryDate != null) {
      final startDate = '${purchaseDate.year}.${purchaseDate.month.toString().padLeft(2, '0')}.${purchaseDate.day.toString().padLeft(2, '0')}';
      final endDate = '${expiryDate.year}.${expiryDate.month.toString().padLeft(2, '0')}.${expiryDate.day.toString().padLeft(2, '0')}';
      return '$startDate ~ $endDate';
    }
    
    // purchaseDate만 있는 경우 30일 후를 종료일로 계산
    if (purchaseDate != null) {
      final endDate = purchaseDate.add(const Duration(days: 30));
      final startDate = '${purchaseDate.year}.${purchaseDate.month.toString().padLeft(2, '0')}.${purchaseDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}.${endDate.month.toString().padLeft(2, '0')}.${endDate.day.toString().padLeft(2, '0')}';
      return '$startDate ~ $endDateStr';
    }
    
    return '정보 없음';
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> _updatePremiumPrice() async {
    try {
      final price = int.tryParse(_premiumPriceController.text);
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('올바른 가격을 입력해주세요')),
        );
        return;
      }

      // TODO: Firestore에 프리미엄 광고 가격 저장
      // 예: _firestore.collection('settings').doc('premiumAdPrice').set({'price': price});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('가격이 수정되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('가격 수정 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

