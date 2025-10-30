import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'user_management_view.dart';
import 'post_management_view.dart';
import 'post_registration_view.dart';
import 'ad_management_view.dart';
import 'inquiry_management_view.dart';

class AdminMainView extends StatelessWidget {
  const AdminMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '관리자 페이지',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 로그아웃 로직
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E3A5F).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A5F),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '관리자 대시보드',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '시스템 관리 및 모니터링',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // 메뉴 그리드
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    children: [
                      _buildMenuCard(
                        context,
                        title: '회원 관리',
                        subtitle: '사용자 계정 관리',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pushNamed(context, '/user-management');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: '게시글 관리',
                        subtitle: '게시글 승인 및 관리',
                        icon: Icons.article,
                        color: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(context, '/post-management');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: '게시글 등록',
                        subtitle: '관리자 게시글 작성',
                        icon: Icons.add_circle,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushNamed(context, '/post-registration');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: '광고 관리',
                        subtitle: '광고 승인 및 관리',
                        icon: Icons.campaign,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pushNamed(context, '/ad-management');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: '문의 관리',
                        subtitle: '1:1 문의 답변',
                        icon: Icons.support_agent,
                        color: Colors.red,
                        onTap: () {
                          Navigator.pushNamed(context, '/inquiry-management');
                        },
                      ),
                      _buildMenuCard(
                        context,
                        title: '통계',
                        subtitle: '사이트 통계 보기',
                        icon: Icons.analytics,
                        color: Colors.teal,
                        onTap: () {
                          // 통계 페이지는 추후 구현
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('통계 기능은 추후 구현 예정입니다.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
