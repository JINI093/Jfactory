import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryDetailView extends StatefulWidget {
  final String inquiryId;
  final Map<String, dynamic> inquiryData;

  const InquiryDetailView({
    super.key,
    required this.inquiryId,
    required this.inquiryData,
  });

  @override
  State<InquiryDetailView> createState() => _InquiryDetailViewState();
}

class _InquiryDetailViewState extends State<InquiryDetailView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _answerController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _answerController.dispose();
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

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Future<String> _getCompanyName(String userId) async {
    try {
      // 먼저 companies 컬렉션에서 userId로 검색
      final companyQuery = await _firestore
          .collection('companies')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      
      if (companyQuery.docs.isNotEmpty) {
        final companyData = companyQuery.docs.first.data();
        return companyData['companyName'] ?? '업체명 없음';
      }
      
      // companies 컬렉션에 없으면 users 컬렉션에서 확인
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          return userData['companyName'] ?? userData['name'] ?? '업체명 없음';
        }
      }
      
      return '업체명 없음';
    } catch (e) {
      debugPrint('기업명 조회 오류: $e');
      return '업체명 없음';
    }
  }

  Future<void> _saveAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('답변 내용을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _firestore.collection('inquiries').doc(widget.inquiryId).update({
        'answer': _answerController.text.trim(),
        'status': 'answered',
        'answeredAt': FieldValue.serverTimestamp(),
        'adminId': 'admin',
      });

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('답변이 등록되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('답변 등록 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('답변 내용을 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _firestore.collection('inquiries').doc(widget.inquiryId).update({
        'answer': _answerController.text.trim(),
        'answeredAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('답변이 수정되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('답변 수정 중 오류가 발생했습니다: $e'),
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('inquiries').doc(widget.inquiryId).snapshots(),
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

          final inquiryData = snapshot.data?.data() as Map<String, dynamic>? ?? widget.inquiryData;
          final createdAt = _parseDate(inquiryData['createdAt']);
          final userId = inquiryData['userId'] ?? '';
          final hasAnswer = inquiryData['answer'] != null && (inquiryData['answer'] as String).isNotEmpty;

          // 답변이 있고 편집 모드가 아니면 답변 컨트롤러에 값 설정
          if (hasAnswer && !_isEditing && _answerController.text.isEmpty) {
            _answerController.text = inquiryData['answer'] ?? '';
          }

          return Container(
            margin: EdgeInsets.all(24.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 제목과 닫기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1:1 문의',
                      style: TextStyle(
                        fontSize: _responsiveFontSize(20),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                // 작성자와 작성일
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 작성자
                    Row(
                      children: [
                        Text(
                          '작성자',
                          style: TextStyle(
                            fontSize: _responsiveFontSize(14),
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        FutureBuilder<String>(
                          future: _getCompanyName(userId),
                          builder: (context, companySnapshot) {
                            return Text(
                              companySnapshot.data ?? '업체명 없음',
                              style: TextStyle(
                                fontSize: _responsiveFontSize(14),
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // 작성일
                    Row(
                      children: [
                        Text(
                          '작성일',
                          style: TextStyle(
                            fontSize: _responsiveFontSize(14),
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          createdAt != null ? _formatDate(createdAt) : '정보 없음',
                          style: TextStyle(
                            fontSize: _responsiveFontSize(14),
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
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
                Text(
                  inquiryData['title'] ?? '제목 없음',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(14),
                    color: Colors.black87,
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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    inquiryData['content'] ?? '내용 없음',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(14),
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                
                // 답변
                Text(
                  '답변',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(14),
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _isEditing || !hasAnswer
                      ? TextField(
                          controller: _answerController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: '답변 내용을 입력하세요',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: _responsiveFontSize(14),
                            color: Colors.black87,
                          ),
                        )
                      : Text(
                          inquiryData['answer'] ?? '',
                          style: TextStyle(
                            fontSize: _responsiveFontSize(14),
                            color: Colors.black87,
                          ),
                        ),
                ),
                SizedBox(height: 24.h),
                
                // 하단 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (hasAnswer) {
                          setState(() {
                            _isEditing = true;
                            _answerController.text = inquiryData['answer'] ?? '';
                          });
                        }
                      },
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
                        '수정',
                        style: TextStyle(fontSize: _responsiveFontSize(14)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () {
                        if (_isEditing && hasAnswer) {
                          _updateAnswer();
                        } else {
                          _saveAnswer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
