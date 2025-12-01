import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_registration_view.dart';

class CompanyDetailView extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const CompanyDetailView({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<CompanyDetailView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
                  '회원관리',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(20),
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
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
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
          
          // 메인 콘텐츠 영역 (2단 레이아웃)
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 왼쪽: 기업정보
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 기업명 헤더
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '기업명 ${_getCompanyName()}',
                                  style: TextStyle(
                                    fontSize: _responsiveFontSize(16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 기업정보 콘텐츠
                          Expanded(
                            child: _buildCompanyInfo(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 오른쪽: 게시글
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // 게시글 헤더 및 추가 버튼
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '게시글',
                                style: TextStyle(
                                  fontSize: _responsiveFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              // 추가 버튼
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostRegistrationView(
                                        companyId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                ),
                                child: Text(
                                  '추가',
                                  style: TextStyle(fontSize: _responsiveFontSize(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 게시글 콘텐츠
                        Expanded(
                          child: _buildPostsInfo(),
                        ),
                      ],
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

  String _getCompanyName() {
    return widget.userData['companyName'] ?? '정보 없음';
  }

  String? _getPhotoUrl(Map<String, dynamic> companyData) {
    // photos 배열이 있으면 첫 번째 이미지 사용
    if (companyData['photos'] != null && companyData['photos'] is List) {
      final photos = companyData['photos'] as List;
      if (photos.isNotEmpty && photos[0] is String) {
        return photos[0] as String;
      }
    }
    // photo 필드가 있으면 사용
    if (companyData['photo'] != null && companyData['photo'] is String) {
      return companyData['photo'] as String;
    }
    return null;
  }

  Widget _buildCompanyInfo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('companies').doc(widget.userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '오류가 발생했습니다: ${snapshot.error}',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.red),
            ),
          );
        }

        final companyData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final userEmail = widget.userData['email'] ?? '이메일 없음';

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Table(
            columnWidths: {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(3),
            },
            children: [
              _buildInfoRow('기업대표명', companyData['ceoName'] ?? widget.userData['name'] ?? '정보 없음'),
              _buildInfoRow('전화번호', companyData['phone'] ?? widget.userData['phone'] ?? '정보 없음'),
              _buildInfoRow('이메일', userEmail),
              _buildInfoRow('홈페이지', companyData['website'] ?? '정보 없음'),
              _buildInfoRow('홈페이지 사진', '', isImage: true, imageUrl: _getPhotoUrl(companyData)),
              _buildInfoRow('사업자등록증', '', isImage: true, imageUrl: companyData['businessLicenseImage']),
            ],
          ),
        );
      },
    );
  }

  TableRow _buildInfoRow(String label, String value, {bool isImage = false, String? imageUrl}) {
    return TableRow(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: _responsiveFontSize(14),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: isImage
              ? _buildImageCell(imageUrl)
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: _responsiveFontSize(14),
                    color: Colors.black87,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildImageCell(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          Icons.add,
          size: _responsiveFontSize(40),
          color: Colors.grey[400],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        // TODO: 이미지 확대 보기
      },
      child: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                size: _responsiveFontSize(40),
                color: Colors.grey[400],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostsInfo() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('posts')
          .where('companyId', isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '오류가 발생했습니다: ${snapshot.error}',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.red),
            ),
          );
        }

        final posts = snapshot.data?.docs ?? [];
        
        // 검색 필터 적용
        final filteredPosts = posts.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final equipmentName = data['equipmentName']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return title.contains(query) || equipmentName.contains(query);
        }).toList();

        if (filteredPosts.isEmpty) {
          return Center(
            child: Text(
              '게시글이 없습니다.',
              style: TextStyle(fontSize: _responsiveFontSize(14), color: Colors.grey[600]),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(2),
            },
            children: [
              // 헤더
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                ),
                children: [
                  _buildHeaderCell('장비명'),
                  _buildHeaderCell('카테고리'),
                  _buildHeaderCell('게시글 날짜'),
                  _buildHeaderCell('광고 등급'),
                  _buildHeaderCell('광고기한'),
                ],
              ),
              // 데이터 행
              ...filteredPosts.map((doc) {
                final postData = doc.data() as Map<String, dynamic>;
                return _buildPostRow(postData);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _responsiveFontSize(12),
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  TableRow _buildPostRow(Map<String, dynamic> postData) {
    final equipmentName = postData['equipmentName'] ?? postData['title'] ?? '정보 없음';
    final category = _formatCategory(postData);
    final createdAt = _formatDate(postData['createdAt']);
    final adGrade = _getAdGrade(postData);
    final adPeriod = _getAdPeriod(postData);

    return TableRow(
      children: [
        _buildCell(equipmentName),
        _buildCell(category),
        _buildCell(createdAt),
        _buildCell(adGrade),
        _buildCell(adPeriod),
      ],
    );
  }

  Widget _buildCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _responsiveFontSize(12),
          color: Colors.black87,
        ),
      ),
    );
  }

  String _formatCategory(Map<String, dynamic> postData) {
    final category = postData['category'] ?? '';
    final subcategory = postData['subcategory'] ?? '';
    
    if (category.isEmpty && subcategory.isEmpty) {
      return '';
    }
    
    if (subcategory.isNotEmpty) {
      return '$category > $subcategory';
    }
    
    return category;
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
      
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}.${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '정보 없음';
    }
  }

  String _getAdGrade(Map<String, dynamic> postData) {
    final isPremium = postData['isPremium'] ?? false;
    final premiumExpiryDate = postData['premiumExpiryDate'];
    
    if (isPremium && premiumExpiryDate != null) {
      final expiry = _parseDate(premiumExpiryDate);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return '프리미엄';
      }
    }
    
    // 스탠다드 등급 확인 (다른 필드로 판단)
    // 예: adPayment가 있으면 스탠다드
    final adPayment = postData['adPayment'] ?? 0;
    if (adPayment > 0) {
      return '스탠다드';
    }
    
    return '-';
  }

  String _getAdPeriod(Map<String, dynamic> postData) {
    final isPremium = postData['isPremium'] ?? false;
    final premiumExpiryDate = postData['premiumExpiryDate'];
    final createdAt = _parseDate(postData['createdAt']);
    
    if (isPremium && premiumExpiryDate != null && createdAt != null) {
      final expiry = _parseDate(premiumExpiryDate);
      if (expiry != null) {
        final startDate = '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
        final endDate = '${expiry.year}.${expiry.month.toString().padLeft(2, '0')}.${expiry.day.toString().padLeft(2, '0')}';
        return '$startDate ~ $endDate';
      }
    }
    
    // 스탠다드 광고 기한 확인
    final adPayment = postData['adPayment'] ?? 0;
    if (adPayment > 0 && createdAt != null) {
      final endDate = createdAt.add(const Duration(days: 30));
      final startDate = '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}.${endDate.month.toString().padLeft(2, '0')}.${endDate.day.toString().padLeft(2, '0')}';
      return '$startDate ~ $endDateStr';
    }
    
    return '-';
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
}

