import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaqDetailView extends StatefulWidget {
  final String? faqId; // null이면 새로 등록, 있으면 수정

  const FaqDetailView({
    super.key,
    this.faqId,
  });

  @override
  State<FaqDetailView> createState() => _FaqDetailViewState();
}

class _FaqDetailViewState extends State<FaqDetailView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.faqId != null) {
      _loadFaqData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadFaqData() async {
    try {
      final doc = await _firestore.collection('faqs').doc(widget.faqId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _titleController.text = data['title'] ?? '';
          _contentController.text = data['content'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('FAQ 데이터 로드 오류: $e');
    }
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

  Future<void> _saveFaq() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제목을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('내용을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final faqData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.faqId == null) {
        // 새로 등록
        faqData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('faqs').add(faqData);
      } else {
        // 수정
        await _firestore.collection('faqs').doc(widget.faqId).update(faqData);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.faqId == null ? 'FAQ가 등록되었습니다' : 'FAQ가 수정되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteFaq() async {
    if (widget.faqId == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말로 이 FAQ를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('faqs').doc(widget.faqId).delete();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FAQ가 삭제되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 헤더 영역
                Container(
                  padding: EdgeInsets.all(24.w),
                  child: Row(
                    children: [
                      Text(
                        '자주 묻는 질문 > 등록 및 수정',
                        style: TextStyle(
                          fontSize: _responsiveFontSize(20),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 입력 폼 영역
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          '제목',
                          style: TextStyle(
                            fontSize: _responsiveFontSize(14),
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'FAQ 제목을 입력하세요',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12.w),
                            ),
                            style: TextStyle(
                              fontSize: _responsiveFontSize(14),
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        
                        // 내용
                        Text(
                          '내용',
                          style: TextStyle(
                            fontSize: _responsiveFontSize(14),
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: _contentController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'FAQ 내용을 입력하세요',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12.w),
                              ),
                              style: TextStyle(
                                fontSize: _responsiveFontSize(14),
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 하단 버튼 및 페이지네이션
                Container(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      // 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.faqId != null)
                            ElevatedButton(
                              onPressed: _deleteFaq,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: Text(
                                '삭제',
                                style: TextStyle(fontSize: _responsiveFontSize(14)),
                              ),
                            ),
                          if (widget.faqId != null) SizedBox(width: 12.w),
                          ElevatedButton(
                            onPressed: _saveFaq,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                            ),
                            child: Text(
                              '등록',
                              style: TextStyle(fontSize: _responsiveFontSize(14)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // 페이지네이션 (임시 - 실제로는 FAQ 목록의 페이지네이션)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              // TODO: 이전 페이지로 이동
                            },
                          ),
                          ...List.generate(
                            10,
                            (index) {
                              final pageNum = index + 1;
                              final isCurrentPage = pageNum == 2; // 임시로 2페이지 선택
                              return GestureDetector(
                                onTap: () {
                                  // TODO: 페이지 이동
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
                            onPressed: () {
                              // TODO: 다음 페이지로 이동
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

