import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/category_model.dart';
import '../filter/location_filter_bottom_sheet.dart';
import '../filter/category_filter_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/company_entity.dart';
import '../../widgets/naver_map_widget.dart';
import '../../widgets/admob_banner_widget.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _companiesSectionKey = GlobalKey();
  bool _hasInitialized = false;
  String? _previousRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load companies when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<MainViewModel>().loadCompanies();
          _checkCompanyRegistration();
          _hasInitialized = true;
        } catch (e) {
          // Handle error silently for now
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 다른 화면에서 돌아왔을 때 검색 결과 초기화
    if (_hasInitialized && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        try {
          final router = GoRouter.of(context);
          final currentLocation = router.routerDelegate.currentConfiguration.uri.toString();
          
          // 이전 경로가 메인이 아니고 현재 경로가 메인인 경우 (다른 화면에서 돌아온 경우)
          if (_previousRoute != null && 
              _previousRoute != RouteNames.main && 
              currentLocation == RouteNames.main) {
            // 검색 결과 초기화
            final viewModel = context.read<MainViewModel>();
            if (viewModel.searchQuery.isNotEmpty || 
                viewModel.selectedCategory != null ||
                viewModel.selectedLocations.isNotEmpty) {
              viewModel.clearFilters();
              _searchController.clear();
            }
          }
          _previousRoute = currentLocation;
        } catch (e) {
          // GoRouter를 사용할 수 없는 경우 무시
          debugPrint('Error getting current route: $e');
        }
      });
    } else if (!_hasInitialized) {
      // 첫 초기화 시 현재 경로 저장
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            final router = GoRouter.of(context);
            _previousRoute = router.routerDelegate.currentConfiguration.uri.toString();
          } catch (e) {
            _previousRoute = RouteNames.main;
          }
        }
      });
    }
  }

  Future<void> _checkCompanyRegistration() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Get user data from Firestore to check user type
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final userType = userData['userType'] as String?;

      // If user is company type, check if company registration exists
      if (userType == 'company') {
        final companyDoc = await FirebaseFirestore.instance
            .collection('companies')
            .doc(currentUser.uid)
            .get();

        // If company registration doesn't exist, redirect to registration page
        if (!companyDoc.exists && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go(RouteNames.companyRegistration);
            }
          });
        }
      }
    } catch (e) {
      // Handle error silently
      debugPrint('Error checking company registration: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildAdSenseBanner(),
            _buildCategoryButtons(),
            _buildSearchBar(),
            _buildLocationSection(),
            _buildPremiumCompanies(),
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
      title: Image.asset(
        'assets/icons/logo2.png',
        height: 32.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            '제작소',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          );
        },
      ),
      actions: [
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final isLoggedIn = snapshot.data != null;
            
            if (isLoggedIn) {
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.grey[600],
                  size: 24.sp,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      context.go(RouteNames.profile);
                      break;
                    case 'logout':
                      _handleLogout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 18.sp),
                        SizedBox(width: 8.w),
                        const Text('마이페이지'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18.sp),
                        SizedBox(width: 8.w),
                        const Text('로그아웃'),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return TextButton(
                onPressed: () {
                  context.go(RouteNames.login);
                },
                child: Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }
          },
        ),
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildAdSenseBanner() {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: const AdmobBannerWidget(),
    );
  }

  Widget _buildCategoryButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: CategoryData.categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryButton(CategoryData.categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryButton(CategoryModel category) {
    final fontSize = 13.sp;
        
    return Container(
      width: 64.w,
      height: 64.h,
      decoration: BoxDecoration(
        color: const Color(0xFFC6D6E8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Material(
        color: Colors.transparent,
          child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () {
            try {
              // 세부 카테고리 페이지로 이동
              context.goNamed(
                'category_detail',
                pathParameters: {
                  'categoryTitle': category.title,
                },
              );
            } catch (e) {
              print('Navigation error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('카테고리로 이동할 수 없습니다: ${e.toString()}')),
              );
            }
          },
          child: Center(
            child: Text(
              category.title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            final mainViewModel = context.read<MainViewModel>();
            mainViewModel.searchCompanies(value);
          },
          decoration: InputDecoration(
            hintText: '키워드로 검색해보세요',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            suffixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 주변의 업체를 확인해보세요!',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildLocationDropdown('카테고리'),
              SizedBox(width: 8.w),
              _buildLocationDropdown('지역'),
              const Spacer(),
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.view_module,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Consumer<MainViewModel>(
            builder: (context, mainViewModel, child) {
              return NaverMapWidget(
                companies: mainViewModel.companies,
                onCompanyTapped: (company) {
                  // 회사 상세 페이지로 이동
                  context.push('/company/${company.id}');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown(String text) {
    return GestureDetector(
      onTap: () async {
        if (text == '지역') {
          final viewModel = context.read<MainViewModel>();
          final result = await showLocationFilterBottomSheet(
            context, 
            selectedLocations: viewModel.selectedLocations,
          );
          
          if (result != null && mounted) {
            viewModel.updateLocationFilter(result);
            
            if (result.isNotEmpty) {
              final locationNames = result
                  .where((loc) => loc['district'] != '전체' && loc['district'] != '전지역')
                  .map((loc) => '${loc['region']} > ${loc['district']}')
                  .join(', ');
              
              if (locationNames.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('선택된 지역: $locationNames'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('모든 지역 필터가 해제되었습니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        } else if (text == '카테고리') {
          showCategoryFilterBottomSheet(context);
        } else {
          // Handle other filters if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$text 필터 준비 중입니다'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCompanies() {
    return Container(
      key: _companiesSectionKey,
      margin: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<MainViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          viewModel.searchQuery.isNotEmpty 
                              ? '검색 결과'
                              : viewModel.selectedCategory != null
                                  ? '${viewModel.selectedCategory} 기업'
                                  : '프리미엄 기업',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (viewModel.selectedCategory != null || viewModel.searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            viewModel.clearFilters();
                            _searchController.clear();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close,
                                size: 16.sp,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '필터 초기화',
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
                  SizedBox(height: 16.h),
                ],
              );
            },
          ),
          Consumer<MainViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.h),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }

              // 오류가 발생했거나 데이터가 없는 경우
              if (viewModel.error != null || viewModel.companies.isEmpty) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 48.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '해당 기업이 없습니다.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 검색어나 카테고리 필터가 있으면 필터링된 기업 표시, 아니면 프리미엄 기업만 필터링
              final displayCompanies = viewModel.searchQuery.isNotEmpty || viewModel.selectedCategory != null
                  ? viewModel.companies.take(20).toList()
                  : viewModel.companies
                      .where((company) => company.adPayment > 0)
                      .take(6)
                      .toList();
              
              debugPrint('🔥 Total companies loaded: ${viewModel.companies.length}');
              debugPrint('🔥 Display companies found: ${displayCompanies.length}');

              // 표시할 기업이 없으면 메시지 표시
              if (displayCompanies.isEmpty) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          viewModel.searchQuery.isNotEmpty 
                              ? Icons.search_off
                              : Icons.business_outlined,
                          size: 48.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          viewModel.searchQuery.isNotEmpty
                              ? '검색 결과가 없습니다.'
                              : '프리미엄 기업이 없습니다.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          viewModel.searchQuery.isNotEmpty
                              ? '다른 키워드로 검색해보세요.'
                              : '기업광고를 구매하면 메인에 노출됩니다.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: displayCompanies.length,
                itemBuilder: (context, index) {
                  final company = displayCompanies[index];
                  return GestureDetector(
                    onTap: () {
                      context.push('/company-page/${company.id}');
                    },
                    child: _buildCompanyCard(company, isPremium: true),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(CompanyEntity company, {bool isPremium = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  child: _buildCompanyImage(company),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.companyName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _buildCategoryLine(company),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Text(
                    company.address,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyImage(CompanyEntity company) {
    final String? imageUrl = (company.photos.isNotEmpty)
        ? company.photos.first
        : (company.logo != null && company.logo!.isNotEmpty ? company.logo : null);
    if (imageUrl == null) {
      return Container(
        width: double.infinity,
        color: Colors.grey[300],
        child: Icon(
          Icons.business,
          size: 40.sp,
          color: Colors.grey[500],
        ),
      );
    }
    return Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          color: Colors.grey[300],
          child: Icon(
            Icons.business,
            size: 40.sp,
            color: Colors.grey[500],
          ),
        );
      },
    );
  }

  String _buildCategoryLine(CompanyEntity company) {
    final parts = <String>[];
    if (company.category.isNotEmpty) parts.add(company.category);
    if (company.subcategory.isNotEmpty) parts.add(company.subcategory);
    if ((company.subSubcategory ?? '').isNotEmpty) parts.add(company.subSubcategory!);
    return parts.join(' > ');
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
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: _buildBottomNavItem(Icons.arrow_back_ios, '뒤로가기', false),
          ),
          _buildBottomNavItem(Icons.home, '홈', true),
          GestureDetector(
            onTap: () {
              context.go('/favorites');
            },
            child: _buildBottomNavItem(Icons.favorite_border, '좋아요', false),
          ),
          GestureDetector(
            onTap: () {
              context.go('/profile');
            },
            child: _buildBottomNavItem(Icons.person_outline, '마이페이지', false),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected) {
    return Column(
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
    );
  }
}