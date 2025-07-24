import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/category_model.dart';

class CategoryFilterBottomSheet extends StatefulWidget {
  const CategoryFilterBottomSheet({super.key});

  @override
  State<CategoryFilterBottomSheet> createState() => _CategoryFilterBottomSheetState();
}

class _CategoryFilterBottomSheetState extends State<CategoryFilterBottomSheet> {
  String? selectedMainCategory;
  String? selectedSubCategory;
  
  List<CategoryModel> get categories => CategoryData.categories;
  
  List<String> get subCategories {
    if (selectedMainCategory == null) return [];
    final category = categories.firstWhere(
      (cat) => cat.title == selectedMainCategory,
      orElse: () => CategoryModel(title: '', subcategories: []),
    );
    return ['전체', '전체 하위카테고리', ...category.subcategories];
  }

  void _resetFilters() {
    setState(() {
      selectedMainCategory = null;
      selectedSubCategory = null;
    });
  }

  void _applyFilters() {
    // Return the selected filters
    Navigator.of(context).pop({
      'mainCategory': selectedMainCategory,
      'subCategory': selectedSubCategory,
    });
  }

  int get _resultCount {
    // Mock result count based on selection
    if (selectedMainCategory == null) return 31894;
    if (selectedSubCategory == null || selectedSubCategory == '전체' || selectedSubCategory == '전체 하위카테고리') {
      return 31894;
    }
    return 31894; // This would be calculated based on actual filters
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildMainCategoryList(),
                _buildSubCategoryList(),
              ],
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '카테고리선택',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCategoryList() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.grey[50],
        child: ListView(
          children: categories.map((category) {
            final isSelected = selectedMainCategory == category.title;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMainCategory = category.title;
                  selectedSubCategory = null; // Reset subcategory when main category changes
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  border: isSelected 
                    ? Border(right: BorderSide(color: const Color(0xFF1E3A5F), width: 2))
                    : null,
                ),
                child: Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF1E3A5F) : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubCategoryList() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            if (subCategories.isNotEmpty)
              Expanded(
                child: ListView(
                  children: subCategories.map((subCategory) {
                    final isSelected = selectedSubCategory == subCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSubCategory = subCategory;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE8F4FD) : Colors.transparent,
                        ),
                        child: Text(
                          subCategory,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? const Color(0xFF1E3A5F) : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Selected filter chip
          if (selectedMainCategory != null && selectedSubCategory != null && 
              selectedSubCategory != '전체' && selectedSubCategory != '전체 하위카테고리')
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$selectedMainCategory > $selectedSubCategory',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSubCategory = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Bottom buttons
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          size: 18.sp,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            '초기화',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: _applyFilters,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '${_resultCount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}개 결과보기',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper function to show the category filter bottom sheet
void showCategoryFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CategoryFilterBottomSheet(),
  ).then((result) {
    if (result != null) {
      // Handle the filter result
      print('Selected category filters: $result');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카테고리 필터 적용: ${result['mainCategory']} > ${result['subCategory']}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  });
}