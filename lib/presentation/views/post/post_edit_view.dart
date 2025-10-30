import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/repositories/post_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/category_model.dart';

class PostEditView extends StatefulWidget {
  final PostEntity post;

  const PostEditView({
    super.key,
    required this.post,
  });

  @override
  State<PostEditView> createState() => _PostEditViewState();
}

class _PostEditViewState extends State<PostEditView> {
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
  XFile? _selectedImage;
  List<String> _currentImageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
    _equipmentNameController.text = widget.post.equipmentName ?? '';
    _manufacturerController.text = widget.post.manufacturer ?? '';
    _modelController.text = widget.post.model ?? '';
    _dimensionXController.text = widget.post.dimensionX ?? '';
    _dimensionYController.text = widget.post.dimensionY ?? '';
    _dimensionZController.text = widget.post.dimensionZ ?? '';
    _weightController.text = widget.post.weight ?? '';
    _tableSizeController.text = widget.post.tableSize ?? '';
    _featuresController.text = widget.post.features ?? '';
    _quantityController.text = widget.post.quantity ?? '';
    _industryController.text = widget.post.industry ?? '';
    _machiningCenterController.text = widget.post.machiningCenter ?? '';
    _basicSpecsController.text = widget.post.basicSpecs ?? '';
    
    _selectedCategory = widget.post.category;
    _selectedSubcategory = widget.post.subcategory;
    _selectedSubSubcategory = widget.post.subSubcategory;
    _currentImageUrls = List.from(widget.post.images);
  }

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
          '게시글 수정',
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
            onPressed: _isLoading ? null : _saveChanges,
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
                            items: CategoryData.categories.map((category) {
                              return DropdownMenuItem(
                                value: category.title,
                                child: Text(category.title),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                                _selectedSubcategory = null; // 카테고리 변경 시 세부카테고리 초기화
                                _selectedSubSubcategory = null; // 세부카테고리도 초기화
                              });
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
                                _selectedSubSubcategory = null; // 세부카테고리 초기화
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
        // 현재 이미지들
        if (_currentImageUrls.isNotEmpty) ...[
          Text(
            '현재 이미지',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _currentImageUrls.map((url) {
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
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentImageUrls.remove(url);
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
        
        // 새 이미지 추가
        GestureDetector(
          onTap: _pickImage,
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
        
        if (_selectedImage != null) ...[
          SizedBox(height: 8.h),
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 새 이미지 업로드
      List<String> updatedImageUrls = List.from(_currentImageUrls);
      if (_selectedImage != null) {
        final newImageUrl = await _uploadImageToStorage(File(_selectedImage!.path));
        updatedImageUrls.add(newImageUrl);
      }

      // 업데이트된 게시글 엔티티 생성
      final updatedPost = PostEntity(
        id: widget.post.id,
        companyId: widget.post.companyId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        images: updatedImageUrls,
        status: widget.post.status,
        createdAt: widget.post.createdAt,
        updatedAt: DateTime.now(),
        viewCount: widget.post.viewCount,
        tags: widget.post.tags,
        isPremium: widget.post.isPremium,
        premiumExpiryDate: widget.post.premiumExpiryDate,
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

      // Firebase에 업데이트
      await context.read<PostRepository>().updatePost(updatedPost);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        // 상세 페이지로 돌아가기
        Navigator.pop(context);
        Navigator.pop(context); // 상세 페이지도 닫기
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 수정 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      final String fileName = '${widget.post.companyId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
}
