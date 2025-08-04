import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/company_entity.dart';
import '../../viewmodels/company_viewmodel.dart';

class CategoryDetailView extends StatefulWidget {
  final String categoryTitle;
  
  const CategoryDetailView({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCompanies() {
    final companyViewModel = context.read<CompanyViewModel>();
    companyViewModel.loadCompaniesByCategory(
      widget.categoryTitle,
      subcategory: _selectedSubcategory,
    );
  }

  CategoryModel? get _currentCategory {
    print('Original categoryTitle: ${widget.categoryTitle}');
    
    try {
      // Try different decoding methods
      String decodedTitle = Uri.decodeQueryComponent(widget.categoryTitle);
      print('Decoded with decodeQueryComponent: $decodedTitle');
      CategoryModel? result = CategoryData.getCategoryByTitle(decodedTitle);
      if (result != null) return result;
    } catch (e) {
      print('decodeQueryComponent failed: $e');
    }
    
    try {
      // Fallback to decodeComponent
      String decodedTitle = Uri.decodeComponent(widget.categoryTitle);
      print('Decoded with decodeComponent: $decodedTitle');
      CategoryModel? result = CategoryData.getCategoryByTitle(decodedTitle);
      if (result != null) return result;
    } catch (e) {
      print('decodeComponent failed: $e');
    }
    
    // If all decoding fails, try using the title as-is
    print('Using title as-is: ${widget.categoryTitle}');
    return CategoryData.getCategoryByTitle(widget.categoryTitle);
  }

  @override
  Widget build(BuildContext context) {
    final category = _currentCategory;
    
    if (category == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Center(
          child: Text(
            '카테고리를 찾을 수 없습니다.',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumb(),
            _buildSearchBar(),
            _buildSubcategoriesGrid(category),
            _buildPremiumSection(),
            _buildGeneralPostsSection(),
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
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Text(
        '${widget.categoryTitle} >',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            final companyViewModel = context.read<CompanyViewModel>();
            companyViewModel.searchCompanies(value);
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

  Widget _buildSubcategoriesGrid(CategoryModel category) {
    final displaySubcategories = category.subcategories.take(8).toList();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: displaySubcategories.length,
            itemBuilder: (context, index) {
              return _buildSubcategoryCard(displaySubcategories[index]);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(String subcategory) {
    final isSelected = _selectedSubcategory == subcategory;
    return Container(
      width: 64.w,
      height: 64.h,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFC6D6E8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () {
            setState(() {
              _selectedSubcategory = _selectedSubcategory == subcategory ? null : subcategory;
            });
            final companyViewModel = context.read<CompanyViewModel>();
            companyViewModel.loadCompaniesByCategory(
              widget.categoryTitle,
              subcategory: _selectedSubcategory,
            );
          },
          child: Center(
            child: Text(
              subcategory,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _buildFilterButton('하위카테고리'),
          SizedBox(width: 8.w),
          _buildFilterButton('절단/밴딩/절곡/용접'),
          SizedBox(width: 8.w),
          _buildFilterButton('사출'),
          SizedBox(width: 8.w),
          _buildFilterButton('금형'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF1976D2),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSection() {
    return Consumer<CompanyViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return _buildLoadingSection();
        }

        if (viewModel.errorMessage != null) {
          return _buildErrorSection(viewModel.errorMessage!);
        }

        final premiumCompanies = viewModel.premiumCompanies;
        if (premiumCompanies.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '프리미엄 상품',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${premiumCompanies.length}개',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: premiumCompanies.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      context.push('/company/${premiumCompanies[index].id}');
                    },
                    child: _buildPremiumCard(premiumCompanies[index]),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumCard(CompanyEntity company) {
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
                  child: company.logo != null && company.logo!.isNotEmpty
                      ? Image.network(
                          company.logo!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackImage();
                          },
                        )
                      : _buildFallbackImage(),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () {
                    final companyViewModel = context.read<CompanyViewModel>();
                    companyViewModel.toggleFavorite(company.id);
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
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
                  company.greeting ?? company.subcategory,
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
        ],
      ),
    );
  }

  Widget _buildGeneralPostsSection() {
    return Consumer<CompanyViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SizedBox.shrink();
        }

        final generalCompanies = viewModel.generalCompanies;
        if (generalCompanies.isEmpty && viewModel.premiumCompanies.isEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '해당 카테고리에 등록된 기업이 없습니다.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (generalCompanies.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '일반기업',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: generalCompanies.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      context.push('/company/${generalCompanies[index].id}');
                    },
                    child: _buildGeneralPostCard(generalCompanies[index]),
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneralPostCard(CompanyEntity company) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              color: Colors.grey[200],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                  child: company.logo != null && company.logo!.isNotEmpty
                      ? Image.network(
                          company.logo!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildSmallFallbackImage();
                          },
                        )
                      : _buildSmallFallbackImage(),
                ),
                Positioned(
                  top: 6.h,
                  left: 6.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      company.companyName,
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: () {
                      final companyViewModel = context.read<CompanyViewModel>();
                      companyViewModel.toggleFavorite(company.id);
                    },
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.red,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            child: Text(
              company.subcategory,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red[400],
            ),
            SizedBox(height: 16.h),
            Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadCompanies,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
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

  Widget _buildSmallFallbackImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: Icon(
        Icons.business,
        size: 24.sp,
        color: Colors.grey[500],
      ),
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
          _buildBottomNavItem(Icons.person_outline, '마이페이지', false),
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
      ],
    );
  }
}