import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'faq_detail_view.dart';

class FaqManagementView extends StatefulWidget {
  const FaqManagementView({super.key});

  @override
  State<FaqManagementView> createState() => _FaqManagementViewState();
}

class _FaqManagementViewState extends State<FaqManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
                  '자주 묻는 질문',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // 등록 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FaqDetailView(),
                      ),
                    );
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
                    '등록',
                    style: TextStyle(fontSize: _responsiveFontSize(12)),
                  ),
                ),
              ],
            ),
          ),
          
          // FAQ 테이블
          Expanded(
            child: _buildFaqTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('faqs').orderBy('createdAt', descending: true).snapshots(),
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

        final faqs = snapshot.data?.docs ?? [];
        
        // 검색 필터 적용
        final filteredFaqs = faqs.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final content = data['content']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return title.contains(query) || content.contains(query);
        }).toList();

        if (filteredFaqs.isEmpty) {
          return Center(
            child: Text(
              '등록된 FAQ가 없습니다',
              style: TextStyle(fontSize: _responsiveFontSize(14), color: Colors.grey[600]),
            ),
          );
        }

        // 페이지네이션 계산
        final totalPages = (filteredFaqs.length / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        final paginatedFaqs = filteredFaqs.sublist(
          startIndex,
          endIndex > filteredFaqs.length ? filteredFaqs.length : endIndex,
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
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(1),
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
                          _buildHeaderCell('NO.'),
                          _buildHeaderCell('제목'),
                          _buildHeaderCell('내용'),
                          _buildHeaderCell('자세히보기'),
                        ],
                      ),
                      // 데이터 행
                      ...paginatedFaqs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final faqDoc = entry.value;
                        final faqData = faqDoc.data() as Map<String, dynamic>;
                        return _buildFaqRow(
                          startIndex + index + 1,
                          faqDoc.id,
                          faqData,
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

  TableRow _buildFaqRow(int index, String faqId, Map<String, dynamic> faqData) {
    final title = faqData['title'] ?? '제목 없음';
    final content = faqData['content'] ?? '내용 없음';
    final contentPreview = content.length > 50 ? '${content.substring(0, 50)}...' : content;
    
    return TableRow(
      children: [
        _buildCell('$index'),
        _buildCell(title),
        _buildCell(contentPreview),
        _buildCell('자세히 보기', isLink: true, faqId: faqId),
      ],
    );
  }

  Widget _buildCell(String text, {bool isLink = false, String? faqId}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: isLink
          ? GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FaqDetailView(faqId: faqId),
                  ),
                );
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
}

