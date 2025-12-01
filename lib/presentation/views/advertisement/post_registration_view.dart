import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../../data/datasources/firestore_datasource.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../data/models/category_model.dart';

class PostRegistrationView extends StatefulWidget {
  const PostRegistrationView({super.key});

  @override
  State<PostRegistrationView> createState() => _PostRegistrationViewState();
}

class _PostRegistrationViewState extends State<PostRegistrationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers for Tab A
  final TextEditingController _equipmentNameAController = TextEditingController();
  final TextEditingController _manufacturerAController = TextEditingController();
  final TextEditingController _modelAController = TextEditingController();
  final TextEditingController _dimensionsXController = TextEditingController();
  final TextEditingController _dimensionsYController = TextEditingController();
  final TextEditingController _dimensionsZController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _featureAController = TextEditingController();
  final TextEditingController _quantityAController = TextEditingController();
  
  // Form controllers for Tab B
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _machiningCenterController = TextEditingController();
  final TextEditingController _featureBController = TextEditingController();
  
  // Form controllers for Tab C
  final TextEditingController _equipmentNameCController = TextEditingController();
  final TextEditingController _machiningCenterCController = TextEditingController();
  final TextEditingController _manufacturerCController = TextEditingController();
  final TextEditingController _modelCController = TextEditingController();
  final TextEditingController _basicSpecsController = TextEditingController();
  final TextEditingController _featureCController = TextEditingController();
  final TextEditingController _quantityCController = TextEditingController();
  
  XFile? _selectedImage;
  String _selectedCategory = '카테고리';
  String? _selectedSubcategory;
  String? _selectedSubSubcategory;
  List<String> _availableSubcategories = [];
  List<String> _availableSubSubcategories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _equipmentNameAController.dispose();
    _manufacturerAController.dispose();
    _modelAController.dispose();
    _dimensionsXController.dispose();
    _dimensionsYController.dispose();
    _dimensionsZController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _featureAController.dispose();
    _quantityAController.dispose();
    _industryController.dispose();
    _machiningCenterController.dispose();
    _featureBController.dispose();
    _equipmentNameCController.dispose();
    _machiningCenterCController.dispose();
    _manufacturerCController.dispose();
    _modelCController.dispose();
    _basicSpecsController.dispose();
    _featureCController.dispose();
    _quantityCController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('카테고리 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: CategoryData.categories.length * 2 - 1, // 항목 + 구분선
              itemBuilder: (context, index) {
                // 구분선 인덱스 (홀수)
                if (index.isOdd) {
                  return const Divider(
                    height: 2,
                    thickness: 2,
                  );
                }
                // 카테고리 항목 인덱스 (짝수)
                final categoryIndex = index ~/ 2;
                final category = CategoryData.categories[categoryIndex];
                return ListTile(
                  title: Text(category.title),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.title;
                      _availableSubcategories = category.subcategories;
                      _selectedSubcategory = null; // Reset subcategory when main category changes
                      _selectedSubSubcategory = null; // Reset sub-subcategory
                      _availableSubSubcategories = []; // Reset available sub-subcategories
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSubcategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('세부 카테고리 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableSubcategories.length * 2 - 1, // 항목 + 구분선
              itemBuilder: (context, index) {
                // 구분선 인덱스 (홀수)
                if (index.isOdd) {
                  return const Divider(
                    height: 2,
                    thickness: 2,
                  );
                }
                // 세부 카테고리 항목 인덱스 (짝수)
                final subcategoryIndex = index ~/ 2;
                final subcategory = _availableSubcategories[subcategoryIndex];
                return ListTile(
                  title: Text(subcategory),
                  onTap: () {
                    setState(() {
                      _selectedSubcategory = subcategory;
                      _selectedSubSubcategory = null; // Reset sub-subcategory when subcategory changes
                      
                      // Check if this subcategory has sub-subcategories
                      if (CategoryData.hasSubSubcategories(_selectedCategory, subcategory)) {
                        _availableSubSubcategories = CategoryData.getSubSubcategories(_selectedCategory, subcategory) ?? [];
                      } else {
                        _availableSubSubcategories = [];
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSubSubcategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('세부 카테고리 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableSubSubcategories.length * 2 - 1, // 항목 + 구분선
              itemBuilder: (context, index) {
                // 구분선 인덱스 (홀수)
                if (index.isOdd) {
                  return const Divider(
                    height: 2,
                    thickness: 2,
                  );
                }
                // 세부 세부 카테고리 항목 인덱스 (짝수)
                final subSubcategoryIndex = index ~/ 2;
                final subSubcategory = _availableSubSubcategories[subSubcategoryIndex];
                return ListTile(
                  title: Text(subSubcategory),
                  onTap: () {
                    setState(() {
                      _selectedSubSubcategory = subSubcategory;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategorySelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabA(),
                _buildTabB(),
                _buildTabC(),
              ],
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      title: Text(
        '게시글 등록',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          // Category 1 Button
          GestureDetector(
            onTap: _showCategoryDialog,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
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
          ),
          SizedBox(width: 12.w),
          // Category 2 Button - Only show if category 1 is selected
          if (_availableSubcategories.isNotEmpty)
            GestureDetector(
              onTap: _showSubcategoryDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedSubcategory ?? '세부 카테고리',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
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
            ),
          SizedBox(width: 12.w),
          // Category 3 Button - Only show if subcategory has sub-subcategories
          if (_availableSubSubcategories.isNotEmpty)
            GestureDetector(
              onTap: _showSubSubcategoryDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedSubSubcategory ?? '세부 카테고리',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
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
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey[400],
        indicatorColor: Colors.black,
        indicatorWeight: 2,
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: '등록양식A'),
          Tab(text: '등록양식B'),
          Tab(text: '등록양식C'),
        ],
      ),
    );
  }

  Widget _buildTabA() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildImageUploadSection(),
          SizedBox(height: 30.h),
          _buildFormField('장비명', '수십 머신지 센터', _equipmentNameAController),
          SizedBox(height: 20.h),
          _buildFormField('제조사', 'HARTFORD', _manufacturerAController),
          SizedBox(height: 20.h),
          _buildFormField('모델명', 'PRW-426L', _modelAController),
          SizedBox(height: 20.h),
          Text(
            '기본사양',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _buildDimensionField('X', '4200', _dimensionsXController)),
              SizedBox(width: 10.w),
              Expanded(child: _buildDimensionField('Y', '2800', _dimensionsYController)),
              SizedBox(width: 10.w),
              Expanded(child: _buildDimensionField('Z', '1000', _dimensionsZController)),
              SizedBox(width: 10.w),
              Expanded(child: _buildDimensionField('분할각도', '10', _weightController)),
            ],
          ),
          SizedBox(height: 20.h),
          _buildFormField('테이블 사이즈', '2040 X 4200', _sizeController),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _buildFormField('특징', 'CNC', _featureAController)),
              SizedBox(width: 20.w),
              Expanded(child: _buildFormField('수량', '2', _quantityAController)),
            ],
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildTabB() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildImageUploadSection(),
          SizedBox(height: 30.h),
          _buildFormField('공업', '수십 머신지 센터', _industryController),
          SizedBox(height: 20.h),
          _buildFormField('특징', 'HARTFORD', _machiningCenterController),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildTabC() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildImageUploadSection(),
          SizedBox(height: 30.h),
          _buildFormField('장비명', '수십 머신지 센터', _equipmentNameCController),
          SizedBox(height: 20.h),
          _buildFormField('제조사', 'HARTFORD', _manufacturerCController),
          SizedBox(height: 20.h),
          _buildFormField('모델명', 'PRW-426L', _modelCController),
          SizedBox(height: 20.h),
          _buildFormField('기본사양', '2040 X 4200', _basicSpecsController),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _buildFormField('특징', 'CNC', _featureCController)),
              SizedBox(width: 20.w),
              Expanded(child: _buildFormField('수량', '2', _quantityCController)),
            ],
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미지 또는 영상을 첨부해주세요',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Icon(
                    Icons.add,
                    size: 40.sp,
                    color: Colors.black,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFormField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionField(String label, String hint, TextEditingController controller) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[400],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        // Clickable ads image
        GestureDetector(
          onTap: () {
            // Navigate to purchase page
            context.push('/ad-purchase');
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Image.asset(
              'assets/images/ads_add.png',
              width: double.infinity,
              height: 120.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 120.h,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image,
                    size: 60.sp,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // Registration button
        Padding(
          padding: EdgeInsets.only(bottom: 30.h),
          child: GestureDetector(
            onTap: _submitPost,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '등록',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitPost() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      final currentUser = authViewModel.currentUser;
      
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인이 필요합니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get form data based on selected tab
      Map<String, String?> formData = _getFormDataForCurrentTab();
      
      // Upload image to Firebase Storage if exists
      List<String> imageUrls = [];
      if (_selectedImage != null) {
        try {
          final imageUrl = await _uploadImageToStorage(File(_selectedImage!.path), currentUser.uid);
          imageUrls.add(imageUrl);
        } catch (e) {
          debugPrint('이미지 업로드 실패: $e');
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('이미지 업로드 중 오류가 발생했습니다: $e'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }
      
      // Create post entity
      final post = PostEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: currentUser.uid,
        title: formData['title'] ?? '새 게시글',
        content: formData['content'] ?? '',
        images: imageUrls,
        status: PostStatus.published,
        createdAt: DateTime.now(),
        viewCount: 0,
        tags: [],
        isPremium: false,
        category: _selectedCategory != '카테고리' ? _selectedCategory : null,
        subcategory: _selectedSubcategory,
        subSubcategory: _selectedSubSubcategory,
        equipmentName: formData['equipmentName'],
        manufacturer: formData['manufacturer'],
        model: formData['model'],
        dimensionX: formData['dimensionX'],
        dimensionY: formData['dimensionY'],
        dimensionZ: formData['dimensionZ'],
        weight: formData['weight'],
        tableSize: formData['tableSize'],
        features: formData['features'],
        quantity: formData['quantity'],
        industry: formData['industry'],
        machiningCenter: formData['machiningCenter'],
        basicSpecs: formData['basicSpecs'],
      );
      
      // Save to Firebase
      final repository = PostRepositoryImpl(FirestoreDataSourceImpl());
      await repository.createPost(post);
      
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 등록 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Map<String, String?> _getFormDataForCurrentTab() {
    switch (_tabController.index) {
      case 0: // Tab A
        return {
          'title': _equipmentNameAController.text.isNotEmpty ? _equipmentNameAController.text : '새 게시글',
          'content': '제조사: ${_manufacturerAController.text}\n모델: ${_modelAController.text}\n특징: ${_featureAController.text}',
          'equipmentName': _equipmentNameAController.text.isNotEmpty ? _equipmentNameAController.text : null,
          'manufacturer': _manufacturerAController.text.isNotEmpty ? _manufacturerAController.text : null,
          'model': _modelAController.text.isNotEmpty ? _modelAController.text : null,
          'dimensionX': _dimensionsXController.text.isNotEmpty ? _dimensionsXController.text : null,
          'dimensionY': _dimensionsYController.text.isNotEmpty ? _dimensionsYController.text : null,
          'dimensionZ': _dimensionsZController.text.isNotEmpty ? _dimensionsZController.text : null,
          'weight': _weightController.text.isNotEmpty ? _weightController.text : null,
          'tableSize': _sizeController.text.isNotEmpty ? _sizeController.text : null,
          'features': _featureAController.text.isNotEmpty ? _featureAController.text : null,
          'quantity': _quantityAController.text.isNotEmpty ? _quantityAController.text : null,
        };
      case 1: // Tab B
        return {
          'title': _industryController.text.isNotEmpty ? _industryController.text : '새 게시글',
          'content': '공업: ${_industryController.text}\n특징: ${_machiningCenterController.text}',
          'industry': _industryController.text.isNotEmpty ? _industryController.text : null,
          'features': _machiningCenterController.text.isNotEmpty ? _machiningCenterController.text : null,
        };
      case 2: // Tab C
        return {
          'title': _equipmentNameCController.text.isNotEmpty ? _equipmentNameCController.text : '새 게시글',
          'content': '제조사: ${_manufacturerCController.text}\n모델: ${_modelCController.text}\n기본사양: ${_basicSpecsController.text}',
          'equipmentName': _equipmentNameCController.text.isNotEmpty ? _equipmentNameCController.text : null,
          'manufacturer': _manufacturerCController.text.isNotEmpty ? _manufacturerCController.text : null,
          'model': _modelCController.text.isNotEmpty ? _modelCController.text : null,
          'basicSpecs': _basicSpecsController.text.isNotEmpty ? _basicSpecsController.text : null,
          'features': _featureCController.text.isNotEmpty ? _featureCController.text : null,
          'quantity': _quantityCController.text.isNotEmpty ? _quantityCController.text : null,
        };
      default:
        return {};
    }
  }

  Future<String> _uploadImageToStorage(File imageFile, String userId) async {
    try {
      final String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('post_images/$fileName');
      
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }
}