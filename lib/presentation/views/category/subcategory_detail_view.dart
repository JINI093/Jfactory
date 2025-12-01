import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/category_model.dart';
import '../../../domain/entities/company_entity.dart';
import '../../viewmodels/company_viewmodel.dart';
import '../../viewmodels/favorite_viewmodel.dart';

class SubcategoryDetailView extends StatefulWidget {
  final String categoryTitle;
  final String subcategoryTitle;
  final String? initialSubSubcategory;
  final bool forceDetailView;
  
  const SubcategoryDetailView({
    super.key,
    required this.categoryTitle,
    required this.subcategoryTitle,
    this.initialSubSubcategory,
    this.forceDetailView = false,
  });

  @override
  State<SubcategoryDetailView> createState() => _SubcategoryDetailViewState();
}

class _SubcategoryDetailViewState extends State<SubcategoryDetailView> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSubSubcategory;
  String? _selectedSubSubSubcategory;

  @override
  void initState() {
    super.initState();
    _selectedSubSubcategory = widget.initialSubSubcategory;
    print('🔥 SubcategoryDetailView initState - categoryTitle: ${widget.categoryTitle}, subcategoryTitle: ${widget.subcategoryTitle}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _loadCompanies();
        context.read<FavoriteViewModel>().loadFavoriteCompanies();
      } catch (e, stackTrace) {
        print('🔥 Error in initState postFrameCallback: $e');
        print('🔥 Stack trace: $stackTrace');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCompanies() {
    try {
      print('🔥 _loadCompanies called - categoryTitle: ${widget.categoryTitle}, subcategoryTitle: ${widget.subcategoryTitle}');
      final companyViewModel = context.read<CompanyViewModel>();
      
      companyViewModel.loadCompaniesByCategory(
        widget.categoryTitle,
        subcategory: widget.subcategoryTitle,
        subSubcategory: _selectedSubSubcategory,
      );
      print('🔥 loadCompaniesByCategory called successfully');
    } catch (e, stackTrace) {
      print('🔥 Error in _loadCompanies: $e');
      print('🔥 Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로딩 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  CategoryModel? get _currentCategory {
    // First, try to decode the title
    String decodedTitle = widget.categoryTitle;
    print('🔥 _currentCategory - original title: ${widget.categoryTitle}');
    
    try {
      // Try to decode if it's encoded
      if (widget.categoryTitle.contains('%')) {
        decodedTitle = Uri.decodeComponent(widget.categoryTitle);
        print('🔥 _currentCategory - decoded title: $decodedTitle');
      }
    } catch (e) {
      print('🔥 _currentCategory - decoding failed: $e');
      // If decoding fails, use the original title
      decodedTitle = widget.categoryTitle;
    }
    
    final category = CategoryData.getCategoryByTitle(decodedTitle);
    print('🔥 _currentCategory - found category: ${category?.title}');
    if (category == null) {
      print('🔥 _currentCategory - Available categories:');
      for (var cat in CategoryData.categories) {
        print('🔥   - ${cat.title}');
      }
    }
    
    return category;
  }

  @override
  Widget build(BuildContext context) {
    print('🔥 SubcategoryDetailView build called');
    
    try {
      final category = _currentCategory;
      print('🔥 SubcategoryDetailView build - category: ${category?.title}');
      
      if (category == null) {
        print('🔥 SubcategoryDetailView build - category is null, showing error page');
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '카테고리를 찾을 수 없습니다.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '전달받은 카테고리: ${widget.categoryTitle}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/main');
                    }
                  },
                  child: const Text('메인으로 돌아가기'),
                ),
              ],
            ),
          ),
        );
      }

      print('🔥 SubcategoryDetailView build - rendering main content');
      final isDetailView = widget.forceDetailView && widget.initialSubSubcategory != null;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreadcrumb(),
              _buildSearchBar(),
              if (isDetailView)
                _buildSubSubSubcategoriesGrid()
              else
                _buildSubSubcategoriesGrid(category),
              _buildPremiumSection(),
              _buildGeneralPostsSection(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    } catch (e, stackTrace) {
      print('🔥 Error in SubcategoryDetailView build: $e');
      print('🔥 Stack trace: $stackTrace');
      
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('오류'),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/main');
              }
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '페이지를 표시하는 중 오류가 발생했습니다.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '오류: $e',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/main');
                  }
                },
                child: const Text('메인으로 돌아가기'),
              ),
            ],
          ),
        ),
      );
    }
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
    final segments = [
      widget.categoryTitle,
      widget.subcategoryTitle,
      if (widget.initialSubSubcategory != null)
        _cleanLabel(widget.initialSubSubcategory!),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Text(
        '${segments.join(' > ')}${widget.forceDetailView ? '' : ' >'}',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
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

  Widget _buildSubSubcategoriesGrid(CategoryModel category) {
    final subSubcategories = CategoryData.getSubSubcategories(widget.categoryTitle, widget.subcategoryTitle);
    print('🔥 Retrieved subSubcategories: $subSubcategories');
    if (subSubcategories == null || subSubcategories.isEmpty) {
      print('🔥 No subSubcategories found, returning empty widget');
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세부 카테고리',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: subSubcategories.length,
            itemBuilder: (context, index) {
              return _buildSubSubcategoryCard(subSubcategories[index]);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSubSubcategoryCard(String subSubcategory) {
    final isSelected = _selectedSubSubcategory == subSubcategory;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () async {
            final hasMore = CategoryData.hasSubSubSubcategories(
              widget.categoryTitle,
              widget.subcategoryTitle,
              subSubcategory,
            );

            if (hasMore) {
              if (widget.forceDetailView && _selectedSubSubcategory == subSubcategory) {
                // 이미 동일한 4차 카테고리 페이지인 경우 상태만 초기화
                setState(() {
                  _selectedSubSubcategory = subSubcategory;
                  _selectedSubSubSubcategory = null;
                });
              } else {
                try {
                  await context.pushNamed(
                    'sub_subcategory_detail',
                    pathParameters: {
                      'categoryTitle': widget.categoryTitle,
                      'subcategoryTitle': widget.subcategoryTitle,
                      'subSubcategoryTitle': subSubcategory,
                    },
                  );
                } on GoException catch (e, stackTrace) {
                  debugPrint(
                    '🚨 GoException while navigating to sub_subcategory_detail: ${e.message}\n'
                    '  categoryTitle: ${widget.categoryTitle}\n'
                    '  subcategoryTitle: ${widget.subcategoryTitle}\n'
                    '  subSubcategoryTitle: $subSubcategory',
                  );
                  debugPrintStack(stackTrace: stackTrace);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('페이지 이동에 실패했습니다: ${e.message}')),
                    );
                  }
                } catch (e, stackTrace) {
                  debugPrint(
                    '🚨 Unexpected navigation error to sub_subcategory_detail: $e\n'
                    '  categoryTitle: ${widget.categoryTitle}\n'
                    '  subcategoryTitle: ${widget.subcategoryTitle}\n'
                    '  subSubcategoryTitle: $subSubcategory',
                  );
                  debugPrintStack(stackTrace: stackTrace);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('예상치 못한 오류가 발생했습니다: ${e.toString()}')),
                    );
                  }
                }
              }
            } else {
              setState(() {
                _selectedSubSubcategory = _selectedSubSubcategory == subSubcategory ? null : subSubcategory;
                _selectedSubSubSubcategory = null;
              });
              final companyViewModel = context.read<CompanyViewModel>();
              companyViewModel.loadCompaniesByCategory(
                widget.categoryTitle,
                subcategory: widget.subcategoryTitle,
                subSubcategory: _selectedSubSubcategory,
              );
            }
          },
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                _cleanLabel(subSubcategory),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubSubSubcategoriesGrid() {
    final parentSubSubcategory = widget.initialSubSubcategory ?? _selectedSubSubcategory;
    if (parentSubSubcategory == null) {
      return const SizedBox.shrink();
    }

    final details = CategoryData.getSubSubSubcategories(
      widget.categoryTitle,
      widget.subcategoryTitle,
      parentSubSubcategory,
    );

    if (details == null || details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세부 카테고리',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: details.length,
            itemBuilder: (context, index) {
              return _buildSubSubSubcategoryCard(parentSubSubcategory, details[index]);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSubSubSubcategoryCard(String parentSubSubcategory, String detail) {
    final isSelected = _selectedSubSubSubcategory == detail;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () {
            setState(() {
              _selectedSubSubcategory = parentSubSubcategory;
              _selectedSubSubSubcategory =
                  _selectedSubSubSubcategory == detail ? null : detail;
            });

            final companyViewModel = context.read<CompanyViewModel>();
            companyViewModel.loadCompaniesByCategory(
              widget.categoryTitle,
              subcategory: widget.subcategoryTitle,
              subSubcategory: _selectedSubSubcategory,
            );
          },
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                _cleanLabel(detail),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _cleanLabel(String value) {
    return value.replaceAll('*', '').trim();
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
    return Consumer<FavoriteViewModel>(
      builder: (context, favoriteViewModel, _) {
        final isFavorite = favoriteViewModel.isFavorite(company.id);
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
                      onTap: () async {
                        try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('좋아요 기능은 로그인 후 이용 가능합니다.'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final result = await favoriteViewModel.toggleFavorite(company.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result
                                    ? '${company.companyName}을(를) 좋아요에 추가했습니다.'
                                    : '${company.companyName}을(를) 좋아요에서 제거했습니다.',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e, stackTrace) {
                          debugPrint('좋아요 토글 실패 (프리미엄 카드): $e');
                          debugPrintStack(stackTrace: stackTrace);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
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
                  _cleanLabel(company.greeting ?? company.subcategory),
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
      },
    );
  }

  Widget _buildGeneralPostsSection() {
    return Consumer<CompanyViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SizedBox.shrink();
        }

        if (viewModel.errorMessage != null && viewModel.errorMessage!.isNotEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '해당 기업이 없습니다.',
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

        final generalCompanies = viewModel.generalCompanies;
        final allCompanies = viewModel.companies;
        print('🔥 SubcategoryDetailView: All companies: ${allCompanies.length}');
        print('🔥 SubcategoryDetailView: General companies: ${generalCompanies.length}');
        print('🔥 SubcategoryDetailView: Premium companies: ${viewModel.premiumCompanies.length}');
        
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
                    '해당 기업이 없습니다.',
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
          // 임시: 모든 기업을 표시
          if (allCompanies.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '모든 기업 (임시)',
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
                  itemCount: allCompanies.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        context.push('/company/${allCompanies[index].id}');
                      },
                      child: _buildGeneralPostCard(allCompanies[index]),
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
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
    return Consumer<FavoriteViewModel>(
      builder: (context, favoriteViewModel, _) {
        final isFavorite = favoriteViewModel.isFavorite(company.id);
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
                        onTap: () async {
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('좋아요 기능은 로그인 후 이용 가능합니다.'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            final result = await favoriteViewModel.toggleFavorite(company.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result
                                      ? '${company.companyName}을(를) 좋아요에 추가했습니다.'
                                      : '${company.companyName}을(를) 좋아요에서 제거했습니다.',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e, stackTrace) {
                            debugPrint('좋아요 토글 실패 (일반 카드): $e');
                            debugPrintStack(stackTrace: stackTrace);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
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
                  _cleanLabel(company.subcategory),
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
      },
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
              Icons.business_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              '해당 기업이 없습니다.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
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
    return GestureDetector(
      onTap: () {
        if (label == '홈') {
          context.go('/main');
        } else if (label == '좋아요') {
          context.go('/favorites');
        } else if (label == '마이페이지') {
          context.go('/profile');
        } else if (label == '되돌가기') {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/main');
          }
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
        ],
      ),
    );
  }
}

