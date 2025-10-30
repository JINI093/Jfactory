import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdManagementView extends StatefulWidget {
  const AdManagementView({super.key});

  @override
  State<AdManagementView> createState() => _AdManagementViewState();
}

class _AdManagementViewState extends State<AdManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedStatus = 'all';
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '광고 관리',
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
                          DropdownMenuItem(value: 'active', child: Text('활성')),
                          DropdownMenuItem(value: 'expired', child: Text('만료됨')),
                          DropdownMenuItem(value: 'cancelled', child: Text('취소됨')),
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
                          DropdownMenuItem(value: 'basicAd', child: Text('기본 광고')),
                          DropdownMenuItem(value: 'premiumAd', child: Text('프리미엄 광고')),
                          DropdownMenuItem(value: 'featured', child: Text('추천 광고')),
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
          
          // 광고 목록
          Expanded(
            child: _buildAdList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdList() {
    Query query = _firestore.collection('purchases');

    // 상태 필터 적용
    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    // 타입 필터 적용
    if (_selectedType != 'all') {
      query = query.where('purchaseType', isEqualTo: _selectedType);
    }

    // 최신순 정렬
    query = query.orderBy('purchaseDate', descending: true);

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
                  '광고 목록을 불러오는 중 오류가 발생했습니다.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        final ads = snapshot.data?.docs ?? [];

        if (ads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '등록된 광고가 없습니다.',
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
          itemCount: ads.length,
          itemBuilder: (context, index) {
            final adDoc = ads[index];
            final adData = adDoc.data() as Map<String, dynamic>;
            
            return _buildAdCard(adDoc.id, adData);
          },
        );
      },
    );
  }

  Widget _buildAdCard(String adId, Map<String, dynamic> adData) {
    final userId = adData['userId'] ?? '';
    final purchaseType = adData['purchaseType'] ?? 'unknown';
    final amount = adData['amount'] ?? 0;
    final status = adData['status'] ?? 'unknown';
    final purchaseDate = adData['purchaseDate'] as Timestamp?;
    final expiryDate = adData['expiryDate'] as Timestamp?;

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
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: _getAdTypeColor(purchaseType),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Icon(
                    _getAdTypeIcon(purchaseType),
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getAdTypeText(purchaseType),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '사용자: $userId',
                        style: TextStyle(
                          fontSize: 14.sp,
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
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    '금액',
                    '${amount.toStringAsFixed(0)}원',
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    '구매일',
                    purchaseDate != null ? _formatDate(purchaseDate.toDate()) : '정보 없음',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            
            if (expiryDate != null) ...[
              SizedBox(height: 8.h),
              _buildInfoItem(
                '만료일',
                _formatDate(expiryDate.toDate()),
                Icons.schedule,
              ),
            ],
            
            SizedBox(height: 12.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showAdDetails(adId, adData),
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
                    onPressed: () => _updateAdStatus(adId, 'active'),
                    child: Text(
                      '승인',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
                if (status == 'active') ...[
                  TextButton(
                    onPressed: () => _updateAdStatus(adId, 'cancelled'),
                    child: Text(
                      '중단',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: () => _updateAdStatus(adId, 'cancelled'),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAdTypeColor(String type) {
    switch (type) {
      case 'basicAd':
        return Colors.blue;
      case 'premiumAd':
        return Colors.orange;
      case 'featured':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAdTypeIcon(String type) {
    switch (type) {
      case 'basicAd':
        return Icons.campaign;
      case 'premiumAd':
        return Icons.star;
      case 'featured':
        return Icons.featured_play_list;
      default:
        return Icons.campaign;
    }
  }

  String _getAdTypeText(String type) {
    switch (type) {
      case 'basicAd':
        return '기본 광고';
      case 'premiumAd':
        return '프리미엄 광고';
      case 'featured':
        return '추천 광고';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'expired':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '대기중';
      case 'active':
        return '활성';
      case 'expired':
        return '만료됨';
      case 'cancelled':
        return '취소됨';
      default:
        return '알 수 없음';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showAdDetails(String adId, Map<String, dynamic> adData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('광고 상세 정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('광고 타입', _getAdTypeText(adData['purchaseType'] ?? 'unknown')),
              _buildDetailRow('사용자 ID', adData['userId'] ?? '정보 없음'),
              _buildDetailRow('회사 ID', adData['companyId'] ?? '정보 없음'),
              _buildDetailRow('금액', '${adData['amount'] ?? 0}원'),
              _buildDetailRow('상태', _getStatusText(adData['status'] ?? 'unknown')),
              _buildDetailRow('통화', adData['currency'] ?? 'KRW'),
              _buildDetailRow(
                '구매일',
                adData['purchaseDate'] != null
                    ? _formatDate((adData['purchaseDate'] as Timestamp).toDate())
                    : '정보 없음',
              ),
              if (adData['expiryDate'] != null)
                _buildDetailRow(
                  '만료일',
                  _formatDate((adData['expiryDate'] as Timestamp).toDate()),
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

  void _updateAdStatus(String adId, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('광고 상태 변경'),
        content: Text('광고 상태를 "${_getStatusText(newStatus)}"로 변경하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('purchases').doc(adId).update({
                  'status': newStatus,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('광고 상태가 변경되었습니다.'),
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
