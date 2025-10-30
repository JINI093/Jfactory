import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InquiryManagementView extends StatefulWidget {
  const InquiryManagementView({super.key});

  @override
  State<InquiryManagementView> createState() => _InquiryManagementViewState();
}

class _InquiryManagementViewState extends State<InquiryManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _answerController = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedType = 'all';

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '문의 관리',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 필터
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '상태: ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('전체')),
                          DropdownMenuItem(value: 'pending', child: Text('대기중')),
                          DropdownMenuItem(value: 'answered', child: Text('답변완료')),
                          DropdownMenuItem(value: 'closed', child: Text('종료')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '타입: ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('전체')),
                          DropdownMenuItem(value: 'general', child: Text('일반')),
                          DropdownMenuItem(value: 'technical', child: Text('기술')),
                          DropdownMenuItem(value: 'payment', child: Text('결제')),
                          DropdownMenuItem(value: 'complaint', child: Text('불만')),
                          DropdownMenuItem(value: 'other', child: Text('기타')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 문의 목록
          Expanded(
            child: _buildInquiryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryList() {
    Query query = _firestore.collection('inquiries');

    // 상태 필터 적용
    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    // 타입 필터 적용
    if (_selectedType != 'all') {
      query = query.where('type', isEqualTo: _selectedType);
    }

    // 최신순 정렬
    query = query.orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: Colors.red[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '문의 목록을 불러오는 중 오류가 발생했습니다.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        final inquiries = snapshot.data?.docs ?? [];

        if (inquiries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.support_agent_outlined,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '등록된 문의가 없습니다.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: inquiries.length,
          itemBuilder: (context, index) {
            final inquiryDoc = inquiries[index];
            final inquiryData = inquiryDoc.data() as Map<String, dynamic>;
            
            return _buildInquiryCard(inquiryDoc.id, inquiryData);
          },
        );
      },
    );
  }

  Widget _buildInquiryCard(String inquiryId, Map<String, dynamic> inquiryData) {
    final title = inquiryData['title'] ?? '제목 없음';
    final content = inquiryData['content'] ?? '';
    final type = inquiryData['type'] ?? 'unknown';
    final status = inquiryData['status'] ?? 'unknown';
    final userId = inquiryData['userId'] ?? '';
    final createdAt = inquiryData['createdAt'] as Timestamp?;
    final answeredAt = inquiryData['answeredAt'] as Timestamp?;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: _getTypeColor(type),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '사용자: $userId',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getTypeColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _getTypeText(type),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: _getTypeColor(type),
                ),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              content.length > 100 ? '${content.substring(0, 100)}...' : content,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 4.w),
                Text(
                  createdAt != null
                      ? '문의일: ${_formatDate(createdAt.toDate())}'
                      : '문의일: 정보 없음',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (answeredAt != null) ...[
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.check_circle,
                    size: 14.sp,
                    color: Colors.green[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '답변일: ${_formatDate(answeredAt.toDate())}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ],
            ),
            
            SizedBox(height: 12.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showInquiryDetails(inquiryId, inquiryData),
                  child: Text(
                    '상세보기',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                if (status == 'pending') ...[
                  TextButton(
                    onPressed: () => _showAnswerDialog(inquiryId),
                    child: Text(
                      '답변하기',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
                if (status == 'answered') ...[
                  TextButton(
                    onPressed: () => _updateInquiryStatus(inquiryId, 'closed'),
                    child: Text(
                      '종료',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'general':
        return Colors.blue;
      case 'technical':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'complaint':
        return Colors.red;
      case 'other':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'general':
        return Icons.help_outline;
      case 'technical':
        return Icons.build;
      case 'payment':
        return Icons.payment;
      case 'complaint':
        return Icons.report_problem;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'general':
        return '일반';
      case 'technical':
        return '기술';
      case 'payment':
        return '결제';
      case 'complaint':
        return '불만';
      case 'other':
        return '기타';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'answered':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'answered':
        return '답변완료';
      case 'closed':
        return '종료';
      default:
        return '알 수 없음';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showInquiryDetails(String inquiryId, Map<String, dynamic> inquiryData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('문의 상세 정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('제목', inquiryData['title'] ?? '정보 없음'),
              _buildDetailRow('내용', inquiryData['content'] ?? '정보 없음'),
              _buildDetailRow('타입', _getTypeText(inquiryData['type'] ?? 'unknown')),
              _buildDetailRow('상태', _getStatusText(inquiryData['status'] ?? 'unknown')),
              _buildDetailRow('사용자 ID', inquiryData['userId'] ?? '정보 없음'),
              _buildDetailRow(
                '문의일',
                inquiryData['createdAt'] != null
                    ? _formatDate((inquiryData['createdAt'] as Timestamp).toDate())
                    : '정보 없음',
              ),
              if (inquiryData['answer'] != null)
                _buildDetailRow('답변', inquiryData['answer']),
              if (inquiryData['answeredAt'] != null)
                _buildDetailRow(
                  '답변일',
                  _formatDate((inquiryData['answeredAt'] as Timestamp).toDate()),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAnswerDialog(String inquiryId) {
    _answerController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('문의 답변'),
        content: TextField(
          controller: _answerController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '답변 내용을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              if (_answerController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('답변 내용을 입력해주세요.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _submitAnswer(inquiryId, _answerController.text.trim());
            },
            child: const Text('답변하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer(String inquiryId, String answer) async {
    try {
      await _firestore.collection('inquiries').doc(inquiryId).update({
        'answer': answer,
        'status': 'answered',
        'answeredAt': FieldValue.serverTimestamp(),
        'adminId': 'admin', // 관리자 ID
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('답변이 성공적으로 등록되었습니다.'),
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

  void _updateInquiryStatus(String inquiryId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('문의 상태 변경'),
        content: Text('문의 상태를 "${_getStatusText(newStatus)}"로 변경하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('inquiries').doc(inquiryId).update({
                  'status': newStatus,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('문의 상태가 변경되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('상태 변경 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
