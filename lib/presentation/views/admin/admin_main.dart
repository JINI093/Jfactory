import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'user_management_view.dart';
import 'post_management_view.dart';
import 'post_registration_view_new.dart';
import 'company_ad_management_view.dart';
import 'banner_ad_management_view.dart';
import 'inquiry_management_view.dart';
import 'faq_management_view.dart';

class AdminMainView extends StatefulWidget {
  const AdminMainView({super.key});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  int _selectedIndex = 0;
  int? _selectedSubIndex; // 서브메뉴 인덱스

  final List<Widget> _mainPages = [
    const UserManagementView(),
    const PostManagementView(),
    const PostRegistrationViewNew(),
    const CompanyAdManagementView(), // 광고 관리 - 기업광고 관리
    const InquiryManagementView(), // 문의 관리 - 1:1문의
  ];

  Widget get _currentPage {
    if (_selectedIndex == 3 && _selectedSubIndex == 1) {
      return const BannerAdManagementView();
    } else if (_selectedIndex == 4 && _selectedSubIndex == 1) {
      return const FaqManagementView();
    }
    return _mainPages[_selectedIndex];
  }

  // 반응형 폰트 크기 계산
  double _responsiveFontSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 기본 기준: 1920px (데스크톱)
    // 화면이 작을수록 폰트 크기 감소
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
      body: Row(
        children: [
          // 사이드바
          Container(
            width: 200.w,
            color: Colors.grey[100],
            child: Column(
              children: [
                // 로고 영역
                Container(
                  height: 60.h,
                  padding: EdgeInsets.all(16.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/icons/logo2.png',
                      height: _responsiveFontSize(40),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey[300]),
                // 메뉴 리스트
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildMenuItem(
                        '회원 관리',
                        0,
                        Icons.people,
                      ),
                      _buildMenuItem(
                        '게시글관리',
                        1,
                        Icons.article,
                      ),
                      _buildMenuItem(
                        '게시글등록',
                        2,
                        Icons.add_circle,
                      ),
                      _buildMenuItem(
                        '광고 관리',
                        3,
                        Icons.campaign,
                        hasSubMenu: true,
                      ),
                      if (_selectedIndex == 3) ...[
                        _buildSubMenuItem(
                          'ㄴ 기업광고 관리',
                          3,
                          0,
                        ),
                        _buildSubMenuItem(
                          'ㄴ배너 광고 관리',
                          3,
                          1,
                        ),
                      ],
                      _buildMenuItem(
                        '문의 관리',
                        4,
                        Icons.support_agent,
                        hasSubMenu: true,
                      ),
                      if (_selectedIndex == 4) ...[
                        _buildSubMenuItem(
                          'ㄴ 1:1문의',
                          4,
                          0,
                        ),
                        _buildSubMenuItem(
                          'ㄴ 자주 묻는 질문',
                          4,
                          1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 메인 콘텐츠 영역
          Expanded(
            child: _currentPage,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, int index, IconData icon, {bool hasSubMenu = false}) {
    final isSelected = _selectedIndex == index && _selectedSubIndex == null;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _selectedSubIndex = hasSubMenu ? null : null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: isSelected ? Colors.red : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: _responsiveFontSize(18),
              color: isSelected ? Colors.white : Colors.black87,
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: _responsiveFontSize(12),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem(String title, int mainIndex, int subIndex) {
    final isSelected = _selectedIndex == mainIndex && _selectedSubIndex == subIndex;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = mainIndex;
          _selectedSubIndex = subIndex;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        color: isSelected ? Colors.pink : Colors.transparent,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: _responsiveFontSize(12),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
