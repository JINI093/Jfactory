import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inquiry_detail_view.dart';

class InquiryManagementView extends StatefulWidget {
  const InquiryManagementView({super.key});

  @override
  State<InquiryManagementView> createState() => _InquiryManagementViewState();
}

class _InquiryManagementViewState extends State<InquiryManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedSort = 'all'; // 'all', 'pending', 'answered'
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
                  '문의내역',
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
            child: Row(
              children: [
                // 정렬 드롭다운
                SizedBox(
                  width: 150.w,
                  child: DropdownButtonFormField<String>(
                    value: _selectedSort,
                    decoration: InputDecoration(
                      labelText: '정렬 답변여부',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('전체')),
                      DropdownMenuItem(value: 'pending', child: Text('답변대기')),
                      DropdownMenuItem(value: 'answered', child: Text('답변완료')),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '작성자나 문의제목 검색',
                        style: TextStyle(
                          fontSize: _responsiveFontSize(12),
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      TextField(
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
                    ],
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
          
          // 문의 테이블
          Expanded(
            child: _buildInquiryTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryTable() {
    Query query = _firestore.collection('inquiries');

    // 정렬 필터
    if (_selectedSort == 'pending') {
      query = query.where('status', isEqualTo: 'pending');
    } else if (_selectedSort == 'answered') {
      query = query.where('status', isEqualTo: 'answered');
    }

    query = query.orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '오류: ${snapshot.error}',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.red),
            ),
          );
        }

        final inquiries = snapshot.data?.docs ?? [];
        
        // 검색 필터 적용
        final filteredInquiries = inquiries.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final userId = data['userId']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return title.contains(query) || userId.contains(query);
        }).toList();

        if (filteredInquiries.isEmpty) {
          return Center(
            child: Text(
              '등록된 문의가 없습니다',
              style: TextStyle(fontSize: _responsiveFontSize(14), color: Colors.grey[600]),
            ),
          );
        }

        // 페이지네이션 계산
        final totalPages = (filteredInquiries.length / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        final paginatedInquiries = filteredInquiries.sublist(
          startIndex,
          endIndex > filteredInquiries.length ? filteredInquiries.length : endIndex,
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
                      0: FixedColumnWidth(60.w),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(1.5),
                      5: FlexColumnWidth(1),
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
                          _buildHeaderCell('번호'),
                          _buildHeaderCell('작성자'),
                          _buildHeaderCell('답변여부'),
                          _buildHeaderCell('1:1 문의 제목'),
                          _buildHeaderCell('작성일'),
                          _buildHeaderCell('자세히보기'),
                        ],
                      ),
                      // 데이터 행
                      ...paginatedInquiries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final inquiryDoc = entry.value;
                        final inquiryData = inquiryDoc.data() as Map<String, dynamic>;
                        return _buildInquiryRow(
                          startIndex + index + 1,
                          inquiryDoc.id,
                          inquiryData,
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

  TableRow _buildInquiryRow(int index, String inquiryId, Map<String, dynamic> inquiryData) {
    final userId = inquiryData['userId'] ?? '';
    final status = inquiryData['status'] ?? 'pending';
    final title = inquiryData['title'] ?? '제목 없음';
    final createdAt = _formatDate(inquiryData['createdAt']);
    final companyName = _getCompanyName(userId);
    
    return TableRow(
      children: [
        _buildCell('$index'),
        _buildCell(companyName),
        _buildCell(
          status == 'answered' ? '답변완료' : '답변대기',
          color: status == 'answered' ? Colors.green : Colors.orange,
        ),
        _buildCell(title),
        _buildCell(createdAt),
        _buildCell('자세히 보기', isLink: true, inquiryId: inquiryId, inquiryData: inquiryData),
      ],
    );
  }

  Widget _buildCell(String text, {Color? color, bool isLink = false, String? inquiryId, Map<String, dynamic>? inquiryData}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: isLink
          ? GestureDetector(
              onTap: () {
                if (inquiryId != null && inquiryData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InquiryDetailView(
                        inquiryId: inquiryId,
                        inquiryData: inquiryData,
                      ),
                    ),
                  );
                }
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
                color: color ?? Colors.black87,
              ),
            ),
    );
  }

  String _getCompanyName(String userId) {
    // TODO: Firestore에서 userId로 기업명 조회
    // 임시로 '업체명' 반환
    return '업체명';
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
}
