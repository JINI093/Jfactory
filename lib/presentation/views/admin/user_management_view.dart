import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'company_detail_view.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  // [DEFAULT] 앱의 Firestore 인스턴스 사용
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedUserType = 'company'; // 'company' 또는 'individual'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  '회원관리',
                  style: TextStyle(
                    fontSize: _responsiveFontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                // 개인회원/기업회원 탭
                Row(
                  children: [
                    _buildTabButton('기업회원', 'company'),
                    SizedBox(width: 8.w),
                    _buildTabButton('개인회원', 'individual'),
                  ],
                ),
                SizedBox(width: 16.w),
                // 검색바
                SizedBox(
                  width: 200.w,
                  child: TextField(
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
          
          // 테이블 영역
          Expanded(
            child: _buildUserTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedUserType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = value;
          _currentPage = 1;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[600] : Colors.grey[300],
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: _responsiveFontSize(12),
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    Query query = _firestore.collection('users');

    // 사용자 타입 필터 적용
    if (_selectedUserType != 'all') {
      query = query.where('userType', isEqualTo: _selectedUserType);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '오류가 발생했습니다: ${snapshot.error}',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.red),
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];
        
        // 검색 필터 적용
        final filteredUsers = users.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          final email = data['email']?.toString().toLowerCase() ?? '';
          final companyName = data['companyName']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return name.contains(query) || 
                 email.contains(query) || 
                 companyName.contains(query);
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Text(
              _searchQuery.isEmpty ? '등록된 사용자가 없습니다.' : '검색 결과가 없습니다.',
              style: TextStyle(fontSize: _responsiveFontSize(14), color: Colors.grey[600]),
            ),
          );
        }

        // 페이지네이션 계산
        final totalPages = (filteredUsers.length / _itemsPerPage).ceil();
        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        final paginatedUsers = filteredUsers.sublist(
          startIndex,
          endIndex > filteredUsers.length ? filteredUsers.length : endIndex,
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
                    columnWidths: _selectedUserType == 'company'
                        ? {
                            0: FixedColumnWidth(50.w),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(1.5),
                            5: FlexColumnWidth(1.5),
                            6: FlexColumnWidth(1),
                          }
                        : {
                            0: FixedColumnWidth(50.w),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(2),
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
                        children: _selectedUserType == 'company'
                            ? [
                                _buildHeaderCell(''),
                                _buildHeaderCell('기업명'),
                                _buildHeaderCell('승인여부', showSortIcon: true),
                                _buildHeaderCell('이메일'),
                                _buildHeaderCell('가입경로'),
                                _buildHeaderCell('기업대표명'),
                                _buildHeaderCell('자세히보기'),
                              ]
                            : [
                                _buildHeaderCell(''),
                                _buildHeaderCell('이름'),
                                _buildHeaderCell('이메일'),
                                _buildHeaderCell('가입경로'),
                                _buildHeaderCell('핸드폰 번호'),
                              ],
                      ),
                      // 데이터 행
                      ...paginatedUsers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final userDoc = entry.value;
                        final userData = userDoc.data() as Map<String, dynamic>;
                        return _buildTableRow(
                          startIndex + index + 1,
                          userDoc.id,
                          userData,
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

  Widget _buildHeaderCell(String text, {bool showSortIcon = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: _responsiveFontSize(12),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (showSortIcon) ...[
            SizedBox(width: 4.w),
            Icon(Icons.arrow_downward, size: _responsiveFontSize(14), color: Colors.grey[600]),
          ],
        ],
      ),
    );
  }

  TableRow _buildTableRow(int index, String userId, Map<String, dynamic> userData) {
    if (_selectedUserType == 'company') {
      final companyName = userData['companyName'] ?? '기업명 없음';
      // isApproved 필드가 없으면 자동 승인으로 간주 (true)
      // 필드가 있으면 그 값을 사용, 없으면 true (자동 승인)
      final isApproved = userData.containsKey('isApproved') 
          ? (userData['isApproved'] == true || userData['isApproved'] == 'true')
          : true; // 필드가 없으면 자동 승인
      final email = userData['email'] ?? '이메일 없음';
      final registrationPath = _getRegistrationPath(userData);
      final representativeName = userData['representativeName'] ?? 
                                  userData['name'] ?? 
                                  '대표명 없음';
      
      return TableRow(
        children: [
          _buildCell('$index'),
          _buildCell(companyName),
          _buildCell(isApproved ? '승인' : '미승인', 
                    color: isApproved ? Colors.green : Colors.red),
          _buildCell(email),
          _buildCell(registrationPath),
          _buildCell(representativeName),
          _buildCell('자세히 보기', isLink: true, userId: userId, userData: userData),
        ],
      );
    } else {
      final name = userData['name'] ?? '이름 없음';
      final email = userData['email'] ?? '이메일 없음';
      final registrationPath = _getRegistrationPath(userData);
      final phone = userData['phone'] ?? '번호 없음';
      
      return TableRow(
        children: [
          _buildCell('$index'),
          _buildCell(name),
          _buildCell(email),
          _buildCell(registrationPath),
          _buildCell(phone),
        ],
      );
    }
  }

  Widget _buildCell(String text, {Color? color, bool isLink = false, String? userId, Map<String, dynamic>? userData}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: isLink
          ? GestureDetector(
              onTap: () {
                if (userId != null && userData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetailView(
                        userId: userId,
                        userData: userData,
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

  String _getRegistrationPath(Map<String, dynamic> userData) {
    // Firestore에 저장된 provider 정보 확인
    // 여러 가능한 필드명 확인
    final provider = userData['provider']?.toString().toLowerCase() ?? '';
    final providerId = userData['providerId']?.toString().toLowerCase() ?? '';
    final registrationMethod = userData['registrationMethod']?.toString().toLowerCase() ?? '';
    final authProvider = userData['authProvider']?.toString().toLowerCase() ?? '';
    final signInMethod = userData['signInMethod']?.toString().toLowerCase() ?? '';
    
    // 모든 provider 관련 필드를 합쳐서 확인
    String combinedProvider = '$provider$providerId$registrationMethod$authProvider$signInMethod';
    
    // 네이버 로그인 확인
    if (combinedProvider.contains('naver') || 
        combinedProvider.contains('naver.com') ||
        provider == 'naver' ||
        providerId == 'naver.com') {
      return '네이버';
    }
    
    // 구글 로그인 확인
    if (combinedProvider.contains('google') || 
        combinedProvider.contains('google.com') ||
        provider == 'google' ||
        providerId == 'google.com') {
      return '구글';
    }
    
    // 카카오 로그인 확인
    if (combinedProvider.contains('kakao') || 
        combinedProvider.contains('kakao.com') ||
        provider == 'kakao' ||
        providerId == 'kakao.com') {
      return '카카오';
    }
    
    // 애플 로그인 확인
    if (combinedProvider.contains('apple') || 
        combinedProvider.contains('apple.com') ||
        provider == 'apple' ||
        providerId == 'apple.com') {
      return '애플';
    }
    
    // provider 정보가 없거나 password인 경우 이메일 가입으로 간주
    // 이메일/비밀번호 가입 = 일반
    return '일반';
  }

}
