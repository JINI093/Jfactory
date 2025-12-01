import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/repositories/post_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/category_model.dart';

class PostRegistrationView extends StatefulWidget {
  final String? companyId;
  
  const PostRegistrationView({
    super.key,
    this.companyId,
  });

  @override
  State<PostRegistrationView> createState() => _PostRegistrationViewState();
}

class _PostRegistrationViewState extends State<PostRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _equipmentNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _dimensionXController = TextEditingController();
  final _dimensionYController = TextEditingController();
  final _dimensionZController = TextEditingController();
  final _weightController = TextEditingController();
  final _tableSizeController = TextEditingController();
  final _featuresController = TextEditingController();
  final _quantityController = TextEditingController();
  final _industryController = TextEditingController();
  final _machiningCenterController = TextEditingController();
  final _basicSpecsController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSubSubcategory;
  List<XFile> _selectedImages = [];
  bool _isPremium = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _equipmentNameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _dimensionXController.dispose();
    _dimensionYController.dispose();
    _dimensionZController.dispose();
    _weightController.dispose();
    _tableSizeController.dispose();
    _featuresController.dispose();
    _quantityController.dispose();
    _industryController.dispose();
    _machiningCenterController.dispose();
    _basicSpecsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '게시글 등록',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePost,
            child: Text(
              '저장',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    _buildSectionTitle('제목'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '게시글 제목을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '제목을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // 내용
                    _buildSectionTitle('내용'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '게시글 내용을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '내용을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // 카테고리
                    _buildSectionTitle('카테고리'),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              hintText: '카테고리 선택',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            items: _buildCategoryItemsWithDividers(CategoryData.categories.map((category) => category.title).toList()),
                            onChanged: (value) {
                              if (value != null && 
                                  value != '__category_divider__' && 
                                  value != '__section_divider__' && 
                                  value != '__item_divider__') {
                                setState(() {
                                  _selectedCategory = value;
                                  _selectedSubcategory = null;
                                  _selectedSubSubcategory = null;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSubcategory,
                            decoration: InputDecoration(
                              hintText: '세부카테고리',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            items: _getSubcategoryItems(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubcategory = value;
                                _selectedSubSubcategory = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // 3단계 카테고리 (세부카테고리)
                    if (_selectedCategory != null && _selectedSubcategory != null && 
                        CategoryData.hasSubSubcategories(_selectedCategory!, _selectedSubcategory!))
                      Column(
                        children: [
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedSubSubcategory,
                                  decoration: InputDecoration(
                                    hintText: '세부카테고리',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  items: _getSubSubcategoryItems(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSubSubcategory = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    
                    SizedBox(height: 24.h),
                    
                    // 장비 정보
                    _buildSectionTitle('장비 정보'),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _equipmentNameController,
                            decoration: InputDecoration(
                              labelText: '장비명',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: _manufacturerController,
                            decoration: InputDecoration(
                              labelText: '제조사',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _modelController,
                            decoration: InputDecoration(
                              labelText: '모델',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: '수량',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dimensionXController,
                            decoration: InputDecoration(
                              labelText: 'X 치수 (mm)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: _dimensionYController,
                            decoration: InputDecoration(
                              labelText: 'Y 치수 (mm)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: _dimensionZController,
                            decoration: InputDecoration(
                              labelText: 'Z 치수 (mm)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: '중량 (kg)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: _tableSizeController,
                            decoration: InputDecoration(
                              labelText: '테이블 크기',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // 특징
                    _buildSectionTitle('특징'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _featuresController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '장비의 특징을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // 프리미엄 설정
                    _buildSectionTitle('프리미엄 설정'),
                    SizedBox(height: 8.h),
                    SwitchListTile(
                      title: Text(
                        '프리미엄 게시글',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '프리미엄 게시글로 설정하면 상단에 노출됩니다.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      value: _isPremium,
                      onChanged: (value) {
                        setState(() {
                          _isPremium = value;
                        });
                      },
                      activeColor: const Color(0xFF1E3A5F),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // 이미지
                    _buildSectionTitle('이미지'),
                    SizedBox(height: 8.h),
                    _buildImageSection(),
                    
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 현재 선택된 이미지들
        if (_selectedImages.isNotEmpty) ...[
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                        });
                      },
                      child: Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
        ],
        
        // 이미지 추가 버튼
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400]!,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: Colors.grey[600],
                  size: 24.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  '이미지 추가',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  List<DropdownMenuItem<String>> _getSubcategoryItems() {
    if (_selectedCategory == null) {
      return [];
    }
    
    final category = CategoryData.categories.firstWhere(
      (cat) => cat.title == _selectedCategory,
      orElse: () => CategoryData.categories.first,
    );
    
    return category.subcategories.map((subcategory) {
      return DropdownMenuItem(
        value: subcategory,
        child: Text(subcategory),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _getSubSubcategoryItems() {
    if (_selectedCategory == null || _selectedSubcategory == null) {
      return [];
    }
    
    final subSubcategories = CategoryData.getSubSubcategories(_selectedCategory!, _selectedSubcategory!);
    if (subSubcategories == null) {
      return [];
    }
    
    return subSubcategories.map((subSubcategory) {
      return DropdownMenuItem(
        value: subSubcategory,
        child: Text(subSubcategory),
      );
    }).toList();
  }

  // 카테고리 드롭다운용: 각 카테고리 사이에 구분선 추가
  List<DropdownMenuItem<String>> _buildCategoryItemsWithDividers(List<String> items) {
    final List<DropdownMenuItem<String>> result = [];
    for (int i = 0; i < items.length; i++) {
      result.add(
        DropdownMenuItem<String>(
          value: items[i],
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(items[i]),
          ),
        ),
      );
      // 마지막 항목이 아니면 구분선 추가
      if (i < items.length - 1) {
        result.add(
          DropdownMenuItem<String>(
            enabled: false,
            value: '__category_divider__',
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[400]!,
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.grey[400]!,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return result;
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 이미지 업로드
      List<String> imageUrls = [];
      for (final image in _selectedImages) {
        final imageUrl = await _uploadImageToStorage(File(image.path));
        imageUrls.add(imageUrl);
      }

      // 게시글 엔티티 생성
      final post = PostEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: widget.companyId ?? 'admin', // 전달받은 companyId 사용
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        images: imageUrls,
        status: PostStatus.published,
        createdAt: DateTime.now(),
        viewCount: 0,
        tags: [],
        isPremium: _isPremium,
        category: _selectedCategory,
        subcategory: _selectedSubcategory,
        subSubcategory: _selectedSubSubcategory,
        equipmentName: _equipmentNameController.text.trim().isEmpty ? null : _equipmentNameController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty ? null : _manufacturerController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        dimensionX: _dimensionXController.text.trim().isEmpty ? null : _dimensionXController.text.trim(),
        dimensionY: _dimensionYController.text.trim().isEmpty ? null : _dimensionYController.text.trim(),
        dimensionZ: _dimensionZController.text.trim().isEmpty ? null : _dimensionZController.text.trim(),
        weight: _weightController.text.trim().isEmpty ? null : _weightController.text.trim(),
        tableSize: _tableSizeController.text.trim().isEmpty ? null : _tableSizeController.text.trim(),
        features: _featuresController.text.trim().isEmpty ? null : _featuresController.text.trim(),
        quantity: _quantityController.text.trim().isEmpty ? null : _quantityController.text.trim(),
        industry: _industryController.text.trim().isEmpty ? null : _industryController.text.trim(),
        machiningCenter: _machiningCenterController.text.trim().isEmpty ? null : _machiningCenterController.text.trim(),
        basicSpecs: _basicSpecsController.text.trim().isEmpty ? null : _basicSpecsController.text.trim(),
      );

      // Firebase에 저장
      await context.read<PostRepository>().createPost(post);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 등록 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      final String fileName = 'admin_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
