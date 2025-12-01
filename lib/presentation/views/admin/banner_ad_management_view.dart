import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BannerAdManagementView extends StatefulWidget {
  const BannerAdManagementView({super.key});

  @override
  State<BannerAdManagementView> createState() => _BannerAdManagementViewState();
}

class _BannerAdManagementViewState extends State<BannerAdManagementView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _admobAccountController = TextEditingController();

  @override
  void dispose() {
    _admobAccountController.dispose();
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
  void initState() {
    super.initState();
    _loadAdmobAccount();
  }

  Future<void> _loadAdmobAccount() async {
    try {
      final doc = await _firestore.collection('settings').doc('bannerAd').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _admobAccountController.text = data['admobAccount'] ?? '';
      }
    } catch (e) {
      debugPrint('애드몹 계정 로드 오류: $e');
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
                  '배너 광고관리',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // 위치 정보
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '위치 : 홈 - 로고 하단',
                style: TextStyle(
                  fontSize: _responsiveFontSize(12),
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          
          // 메인 콘텐츠
          Expanded(
            child: Container(
              margin: EdgeInsets.all(24.w),
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '구글 애드몹',
                        style: TextStyle(
                          fontSize: _responsiveFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        '계정',
                        style: TextStyle(
                          fontSize: _responsiveFontSize(14),
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _admobAccountController,
                          decoration: InputDecoration(
                            hintText: '구글 애드몹 계정 입력',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.r),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _saveAdmobAccount,
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
                          '저장',
                          style: TextStyle(fontSize: _responsiveFontSize(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAdmobAccount() async {
    try {
      await _firestore.collection('settings').doc('bannerAd').set({
        'admobAccount': _admobAccountController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구글 애드몹 계정이 저장되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

