import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, String>> historyItems = [{'year': '', 'content': ''}];
  List<Map<String, String>> partnerItems = [{'name': '', 'details': ''}];
  int _selectedTabIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTabBar(),
            _selectedTabIndex == 0 
                ? _buildCompanyInfoTab() 
                : _selectedTabIndex == 1
                    ? _buildAccountManagementTab()
                    : _buildGeneralInfoTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/main');
          }
        },
      ),
      title: Text(
        '정보관리',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTabIndex == 0 ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
                      width: _selectedTabIndex == 0 ? 2 : 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '기업정보',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                      color: _selectedTabIndex == 0 ? const Color(0xFF1E3A5F) : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 1;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTabIndex == 1 ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
                      width: _selectedTabIndex == 1 ? 2 : 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '계정관리',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                      color: _selectedTabIndex == 1 ? const Color(0xFF1E3A5F) : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = 2;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTabIndex == 2 ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
                      width: _selectedTabIndex == 2 ? 2 : 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    '앱정보',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: _selectedTabIndex == 2 ? FontWeight.bold : FontWeight.normal,
                      color: _selectedTabIndex == 2 ? const Color(0xFF1E3A5F) : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Company Info Tab
  Widget _buildCompanyInfoTab() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildTextField('기업명', '가나다'),
                SizedBox(height: 20.h),
                _buildTextField('기업대표명', '홍길동', isRequired: true),
                SizedBox(height: 20.h),
                _buildTextField('홈페이지', '홈페이지 주소를 입력해주세요'),
                SizedBox(height: 20.h),
                _buildTextField('기업전화번호', '02-3456-7890'),
                SizedBox(height: 20.h),
                _buildAddressSection(),
                SizedBox(height: 20.h),
                _buildTextField('상세주소', '상세주소를 입력해주세요'),
                SizedBox(height: 20.h),
                _buildTextField('인사말', '인사말을 입력해주세요'),
                SizedBox(height: 20.h),
                _buildGenderSection(),
                SizedBox(height: 20.h),
                _buildAddressUpdateSection(),
                SizedBox(height: 20.h),
                _buildAddressRegistrationSection(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          _buildSpecialNoteSection(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // Account Management Tab
  Widget _buildAccountManagementTab() {
    return Column(
      children: [
        _buildPasswordSection(),
        _buildDivider(),
        _buildReservationSection(),
        _buildDivider(),
        _buildPaymentSection(),
        _buildDivider(),
        _buildTermsSection(),
        _buildDivider(),
        _buildOtherSection(),
      ],
    );
  }

  // General Info Tab
  Widget _buildGeneralInfoTab() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        _buildGeneralInfoSection(),
      ],
    );
  }

  Widget _buildGeneralInfoSection() {
    return Column(
      children: [
        _buildCustomerServiceSection(),
        _buildDivider(),
        _buildGeneralInfoItem(
          '개인 정보 처리 방침',
          null,
          hasDropdown: true,
        ),
        _buildDivider(),
        _buildGeneralInfoItem(
          '서비스 이용약관',
          null,
          hasDropdown: true,
        ),
      ],
    );
  }

  Widget _buildCustomerServiceSection() {
    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      title: Text(
        '고객센터',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey[600],
        size: 24.sp,
      ),
      children: [
        _buildSubItem(
          '유료광고',
          '유료광고 등록은 어떻게 하나요? 에 대한 답변입니다 나중 예정입니다\n이 무료예제는 제목에 대한 내용을 보여줄 예정이며 관리자에서\n수정할 수 있습니다 여러의 더길 길면이 있는 곳 까지 잘가는 줄\n예정입니다 또한 유료광고는 계시글 유료광고는 즐 등록될 때 허\n터에 나온 서비스 올려야시면 광고를 구매하는 위들이는 나올니다',
        ),
        _buildSubItem('자재 제목', null),
        _buildSubItem('자주 묻는 질문', null),
      ],
    );
  }

  Widget _buildSubItem(String title, String? content) {
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey[500],
          size: 20.sp,
        ),
        children: content != null ? [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(32.w, 0, 16.w, 16.h),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ] : [],
      ),
    );
  }

  Widget _buildGeneralInfoItem(String title, String? content, {bool hasDropdown = false}) {
    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey[600],
        size: 24.sp,
      ),
      children: content != null ? [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ] : [],
    );
  }

  Widget _buildPasswordSection() {
    return ExpansionTile(
      title: Text(
        '계정 정보 수정',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildAccountInfoRow('기업명', '김기업123'),
              SizedBox(height: 12.h),
              _buildAccountInfoRow('전화번호', '김기업123'),
              SizedBox(height: 12.h),
              _buildAccountInfoRow('현재 비밀번호', '김기업123'),
              SizedBox(height: 12.h),
              _buildAccountInfoRow('새 비밀번호', '김기업123', hasWarning: true, warningText: '비밀번호가 일치하지 않습니다'),
              SizedBox(height: 12.h),
              _buildAccountInfoRow('새 비밀번호 확인', '김기업123', hasWarning: true, warningText: '영문+숫자 혼합하여 8자 이상\n비밀번호가 일치하지 않습니다'),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '완료',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfoRow(String label, String value, {bool hasWarning = false, String? warningText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 100.w,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (hasWarning && warningText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 100.w),
            child: Text(
              warningText,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReservationSection() {
    return ExpansionTile(
      title: Text(
        '구매내역',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildReservationItem('제품광고 - 제품명이 들어갑니다', '2025.03.04', '2025.03.04 ~ 2025.03.09', '결고완'),
              _buildReservationItem('기업광고', '2025.03.05', '2025.03.07 ~ 2025.03.19', '결고완'),
              SizedBox(height: 16.h),
              _buildPagination(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReservationItem(String title, String date1, String date2, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '예약상세',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildReservationDetailRow('구매일', date1),
          _buildReservationDetailRow('광고기간', date2),
          _buildReservationDetailRow('광고상태', status),
        ],
      ),
    );
  }

  Widget _buildReservationDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '< 1 2 3 4 5 6 7 8 9 10 >',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return ExpansionTile(
      title: Text(
        '계시글',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '계시글 등록',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF1E3A5F),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.expand_more),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildPostItem(true),
              _buildPostItem(false),
              _buildPostItem(false),
              SizedBox(height: 16.h),
              _buildPagination(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostItem(bool isHighlighted) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFFF9800) : Colors.grey[300]!,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.push(RouteNames.advertisementRegistration);
            },
            child: Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Image.asset(
                  'assets/images/sample.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        size: 24.sp,
                        color: Colors.grey[500],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '카테고리',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '인쇄 - 패드인쇄',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '품명 삼영이품',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '특징 ' + (isHighlighted ? 'CNC' : '색상이 다양함'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '광고 ' + (isHighlighted ? '2025.03.15 ~ 2025.04.14' : '-'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return ExpansionTile(
      title: Text(
        '1:1 문의',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildTermsItem('제 목', '문의제목111'),
              _buildTermsItem('문의상태', '답변완료'),
              _buildTermsItem('내용', '네항 일부분 20글자까지 취합태고 그 이후는 글들하하', isExpanded: true, hasButton: true),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '2025.05.01',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsItem(String label, String value, {bool isExpanded = false, bool hasButton = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                      maxLines: isExpanded ? null : 1,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (hasButton) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '대화가',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Text(
            '로그아웃',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                '회원탈퇴',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.h,
      color: Colors.grey[300],
    );
  }

  Widget _buildTextField(String label, String hint, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기업주소',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: '기업주소를 입력해주세요',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Text(
                  '검색',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '연혁',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        ...historyItems.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '년도 입력',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '연혁 내용을 입력해주세요',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAddressUpdateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              historyItems.add({'year': '', 'content': ''});
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                '연혁 추가하기',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRegistrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주요거래처',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        ...partnerItems.asMap().entries.map((entry) {
          int index = entry.key;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '거래처명',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: '기타 사항 입력',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        GestureDetector(
          onTap: () {
            setState(() {
              partnerItems.add({'name': '', 'details': ''});
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: const Color(0xFF1E3A5F),
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  '주요 거래처 추가',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF1E3A5F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '특징',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: '특징을 입력해주세요',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.w),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () {
            context.push(RouteNames.advertisementRegistration);
          },
          child: Image.asset(
            'assets/images/ads_add.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.2,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 0.2,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'ads banner',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '회사 사진',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 134.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 24.sp,
                                color: Colors.grey[500],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '사진 업로드',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '회사로고',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 134.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 24.sp,
                                color: Colors.grey[500],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '로고 업로드',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사업자 등록증',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 24.sp,
                            color: Colors.grey[500],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '첨부하기',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.refresh, '되돌가기', false),
          _buildBottomNavItem(Icons.home, '홈', false),
          _buildBottomNavItem(Icons.favorite_border, '좋아요', false),
          _buildBottomNavItem(Icons.person, '마이페이지', true),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == '홈') {
          context.go('/main');
        } else if (label == '좋아요') {
          context.go('/favorites');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24.sp,
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[400],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 20.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
        ],
      ),
    );
  }
}