import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/category_model.dart';

class PostManagementView extends StatefulWidget {
  const PostManagementView({super.key});

  @override
  State<PostManagementView> createState() => _PostManagementViewState();
}

class _PostManagementViewState extends State<PostManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String _selectedSort = '최신순';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
                  '게시글 관리',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // 필터 및 검색 영역
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 카테고리 드롭다운
                  SizedBox(
                    width: 180.w,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: '카테고리',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('전체')),
                        ...CategoryData.categories.map((cat) => DropdownMenuItem(
                          value: cat.title,
                          child: Text(
                            cat.title.replaceAll('\n', ' '),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )),
                      ],
                      selectedItemBuilder: (context) {
                        return [
                          const Text('전체', overflow: TextOverflow.ellipsis),
                          ...CategoryData.categories.map((cat) => Text(
                            cat.title.replaceAll('\n', ' '),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
                        ];
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _selectedSubcategory = null;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // 하위카테고리 드롭다운
                  SizedBox(
                    width: 180.w,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubcategory,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: '하위카테고리',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('전체')),
                        if (_selectedCategory != null)
                          ..._getSubcategories().map((sub) => DropdownMenuItem(
                            value: sub,
                            child: Text(
                              sub.replaceAll('\n', ' '),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )),
                      ],
                      selectedItemBuilder: (context) {
                        return [
                          const Text('전체', overflow: TextOverflow.ellipsis),
                          if (_selectedCategory != null)
                            ..._getSubcategories().map((sub) => Text(
                              sub.replaceAll('\n', ' '),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                        ];
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategory = value;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // 정렬 드롭다운
                  SizedBox(
                    width: 120.w,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSort,
                      decoration: InputDecoration(
                        labelText: '정렬',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: '최신순', child: Text('최신순')),
                        DropdownMenuItem(value: '오래된순', child: Text('오래된순')),
                        DropdownMenuItem(value: '조회수순', child: Text('조회수순')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // 검색바
                  SizedBox(
                    width: 300.w,
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
          ),
          
          // 게시글 테이블
          Expanded(
            child: _buildPostTable(),
          ),
        ],
      ),
    );
  }

  List<String> _getSubcategories() {
    if (_selectedCategory == null) return [];
    final category = CategoryData.categories.firstWhere(
      (cat) => cat.title == _selectedCategory,
      orElse: () => CategoryModel(title: '', subcategories: []),
    );
    return category.subcategories;
  }

  Widget _buildPostTable() {
    Query query = _firestore.collection('posts');

    // 카테고리 필터
    if (_selectedCategory != null) {
      query = query.where('category', isEqualTo: _selectedCategory);
    }
    if (_selectedSubcategory != null) {
      query = query.where('subcategory', isEqualTo: _selectedSubcategory);
    }

    // 정렬
    if (_selectedSort == '최신순') {
      query = query.orderBy('createdAt', descending: true);
    } else if (_selectedSort == '오래된순') {
      query = query.orderBy('createdAt', descending: false);
    } else if (_selectedSort == '조회수순') {
      query = query.orderBy('viewCount', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
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
              _searchQuery.isEmpty ? '등록된 게시글이 없습니다.' : '검색 결과가 없습니다.',
              style: TextStyle(fontSize: _responsiveFontSize(14), color: Colors.grey[600]),
            ),
          );
        }

        // 페이지네이션 계산
        final totalPages = (filteredPosts.length / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        final paginatedPosts = filteredPosts.sublist(
          startIndex,
          endIndex > filteredPosts.length ? filteredPosts.length : endIndex,
        );

        return Column(
          children: [
            // 테이블
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SingleChildScrollView(
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(1.5),
                      5: FlexColumnWidth(2),
                      6: FlexColumnWidth(1),
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
                          _buildHeaderCell('카테고리'),
                          _buildHeaderCell('기업명'),
                          _buildHeaderCell('게시글명'),
                          _buildHeaderCell('작성일'),
                          _buildHeaderCell('광고 유형'),
                          _buildHeaderCell('광고기한'),
                          _buildHeaderCell('자세히보기'),
                        ],
                      ),
                      // 데이터 행
                      ...paginatedPosts.asMap().entries.map((entry) {
                        final index = entry.key;
                        final postDoc = entry.value;
                        final postData = postDoc.data() as Map<String, dynamic>;
                        return _buildPostRow(
                          startIndex + index + 1,
                          postDoc.id,
                          postData,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            // 페이지네이션
            Container(
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
            ),
          ],
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

  TableRow _buildPostRow(int index, String postId, Map<String, dynamic> postData) {
    final category = _formatCategory(postData);
    final companyName = _getCompanyName(postData['companyId'] ?? '');
    final postName = postData['equipmentName'] ?? postData['title'] ?? '정보 없음';
    final createdAt = _formatDate(postData['createdAt']);
    final adType = _getAdType(postData);
    final adPeriod = _getAdPeriod(postData);
    
    return TableRow(
      children: [
        _buildCell(category),
        _buildCell(companyName),
        _buildCell(postName),
        _buildCell(createdAt),
        _buildCell(adType),
        _buildCell(adPeriod),
        _buildCell('자세히 보기', isLink: true, postId: postId),
      ],
    );
  }

  Widget _buildCell(String text, {bool isLink = false, String? postId}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: isLink
          ? GestureDetector(
              onTap: () {
                // TODO: 게시글 상세보기 페이지로 이동
              },
              child: Text(
                text,
                style: TextStyle(
                  fontSize: _responsiveFontSize(12),
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          : Text(
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
      return '-';
    }
    
    if (subcategory.isNotEmpty) {
      return '$category > $subcategory';
    }
    
    return category;
  }

  String _getCompanyName(String companyId) {
    // TODO: Firestore에서 companyId로 기업명 조회
    // 임시로 companyId 반환
    return companyId.isNotEmpty ? companyId : '-';
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

  String _getAdType(Map<String, dynamic> postData) {
    final isPremium = postData['isPremium'] ?? false;
    final premiumExpiryDate = postData['premiumExpiryDate'];
    
    if (isPremium && premiumExpiryDate != null) {
      final expiry = _parseDate(premiumExpiryDate);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return '프리미엄';
      }
    }
    
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
