import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/category_model.dart';

class PostRegistrationViewNew extends StatefulWidget {
  const PostRegistrationViewNew({super.key});

  @override
  State<PostRegistrationViewNew> createState() => _PostRegistrationViewNewState();
}

class _PostRegistrationViewNewState extends State<PostRegistrationViewNew> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCompanyId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedForm = 'A';
  final _equipmentNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dimensionXController = TextEditingController();
  final _dimensionYController = TextEditingController();
  final _dimensionZController = TextEditingController();
  final _otherController = TextEditingController();
  final _sizeController = TextEditingController();
  final _featuresController = TextEditingController();
  List<XFile> _selectedImages = [];
  String _selectedSort = '최신순';

  @override
  void dispose() {
    _searchController.dispose();
    _equipmentNameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _quantityController.dispose();
    _dimensionXController.dispose();
    _dimensionYController.dispose();
    _dimensionZController.dispose();
    _otherController.dispose();
    _sizeController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  // 반응형 폰트 크기 계산
  double _responsiveFontSize(double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
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
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // 왼쪽: 기업명 리스트
          Container(
            width: 250.w,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Text(
                    '기업명',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildCompanyList(),
                ),
              ],
            ),
          ),
          // 오른쪽: 게시글 관리 및 입력 폼
          Expanded(
            child: Column(
              children: [
                // 상단: 검색 및 정렬
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 정렬 드롭다운
                      SizedBox(
                        width: 120.w,
                        child: DropdownButtonFormField<String>(
                          value: _selectedSort,
                          decoration: InputDecoration(
                            labelText: '정렬',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: '최신순', child: Text('최신순')),
                            DropdownMenuItem(value: '오래된순', child: Text('오래된순')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSort = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 검색바
                      Expanded(
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
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
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
                // 메인 콘텐츠
                Expanded(
                  child: _selectedCompanyId == null
                      ? Center(
                          child: Text(
                            '왼쪽에서 기업을 선택해주세요',
                            style: TextStyle(
                              fontSize: _responsiveFontSize(14),
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 오른쪽 상단: 등록된 게시글
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // 헤더
                                    Container(
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey[300]!),
                                        ),
                                      ),
                                      child: StreamBuilder<DocumentSnapshot>(
                                        stream: _selectedCompanyId != null
                                            ? _firestore.collection('companies').doc(_selectedCompanyId).snapshots()
                                            : null,
                                        builder: (context, snapshot) {
                                          final companyName = snapshot.data?.data() != null
                                              ? (snapshot.data!.data() as Map<String, dynamic>)['companyName'] ?? '기업명 없음'
                                              : '기업명 없음';
                                          
                                          return Row(
                                            children: [
                                              Text(
                                                '기업명 $companyName',
                                                style: TextStyle(
                                                  fontSize: _responsiveFontSize(16),
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const Spacer(),
                                          ElevatedButton(
                                            onPressed: () {
                                              // TODO: 게시글 추가
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 8.h,
                                              ),
                                            ),
                                            child: Text(
                                              '추가',
                                              style: TextStyle(fontSize: _responsiveFontSize(12)),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          ElevatedButton(
                                            onPressed: _savePost,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 8.h,
                                              ),
                                            ),
                                            child: Text(
                                              '완료',
                                              style: TextStyle(fontSize: _responsiveFontSize(12)),
                                            ),
                                          ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    // 등록된 게시글 테이블
                                    Expanded(
                                      child: _buildPostsTable(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 오른쪽 하단: 게시글 입력 폼
                            Expanded(
                              flex: 1,
                              child: _buildPostForm(),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('companies').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '오류: ${snapshot.error}',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.red),
            ),
          );
        }

        final companies = snapshot.data?.docs ?? [];
        
        if (companies.isEmpty) {
          return Center(
            child: Text(
              '등록된 기업이 없습니다',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final companyDoc = companies[index];
            final companyData = companyDoc.data() as Map<String, dynamic>;
            final companyName = companyData['companyName'] ?? '기업명 없음';
            final companyId = companyDoc.id;
            final isSelected = _selectedCompanyId == companyId;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCompanyId = companyId;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                child: Text(
                  companyName,
                  style: TextStyle(
                    fontSize: _responsiveFontSize(14),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildPostsTable() {
    if (_selectedCompanyId == null) {
      return const SizedBox.shrink();
    }

    Query query = _firestore
        .collection('posts')
        .where('companyId', isEqualTo: _selectedCompanyId);

    if (_selectedSort == '최신순') {
      query = query.orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: false);
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
              '오류: ${snapshot.error}',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.red),
            ),
          );
        }

        final posts = snapshot.data?.docs ?? [];
        
        // 검색 필터 적용
        final filteredPosts = posts.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? '';
          final equipmentName = data['equipmentName']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return title.contains(query) || equipmentName.contains(query);
        }).toList();

        if (filteredPosts.isEmpty) {
          return Center(
            child: Text(
              '등록된 게시글이 없습니다',
              style: TextStyle(fontSize: _responsiveFontSize(12), color: Colors.grey[600]),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Table(
            columnWidths: {
              0: FlexColumnWidth(1.5),
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
                ),
                children: [
                  _buildHeaderCell('장비명'),
                  _buildHeaderCell('카테고리'),
                  _buildHeaderCell('게시글 날짜'),
                  _buildHeaderCell('광고 등급'),
                  _buildHeaderCell('광고기한'),
                ],
              ),
              // 데이터 행
              ...filteredPosts.map((doc) {
                final postData = doc.data() as Map<String, dynamic>;
                return _buildPostTableRow(postData);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _responsiveFontSize(12),
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  TableRow _buildPostTableRow(Map<String, dynamic> postData) {
    final equipmentName = postData['equipmentName'] ?? postData['title'] ?? '정보 없음';
    final category = _formatCategory(postData);
    final createdAt = _formatDate(postData['createdAt']);
    final adGrade = _getAdGrade(postData);
    final adPeriod = _getAdPeriod(postData);

    return TableRow(
      children: [
        _buildCell(equipmentName),
        _buildCell(category),
        _buildCell(createdAt),
        _buildCell(adGrade),
        _buildCell(adPeriod),
      ],
    );
  }

  Widget _buildCell(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _responsiveFontSize(12),
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPostForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '등록된 게시글',
            style: TextStyle(
              fontSize: _responsiveFontSize(16),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          // 카테고리, 하위카테고리
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: '카테고리',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('선택')),
                    ...CategoryData.categories.map((cat) => DropdownMenuItem(
                      value: cat.title,
                      child: Text(cat.title.replaceAll('\n', ' ')),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSubcategory = null;
                    });
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSubcategory,
                  decoration: InputDecoration(
                    labelText: '하위카테고리',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('선택')),
                    if (_selectedCategory != null)
                      ..._getSubcategories().map((sub) => DropdownMenuItem(
                        value: sub,
                        child: Text(sub.replaceAll('\n', ' ')),
                      )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategory = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 입력 폼 테이블
          Table(
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1),
            },
            children: [
              // 헤더 행
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                children: [
                  _buildHeaderCell('양식'),
                  _buildHeaderCell('장비명(품명)'),
                  _buildHeaderCell('제조사'),
                  _buildHeaderCell('모델명'),
                  _buildHeaderCell('수량'),
                ],
              ),
              // 입력 행
              TableRow(
                children: [
                  _buildFormCell(
                    DropdownButtonFormField<String>(
                      value: _selectedForm,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: ['A', 'B', 'C'].map((form) => DropdownMenuItem(
                        value: form,
                        child: Text(form),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedForm = value;
                        });
                      },
                    ),
                  ),
                  _buildFormCell(
                    TextField(
                      controller: _equipmentNameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '장비명 입력',
                      ),
                    ),
                  ),
                  _buildFormCell(
                    TextField(
                      controller: _manufacturerController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '제조사 입력',
                      ),
                    ),
                  ),
                  _buildFormCell(
                    TextField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '모델명 입력',
                      ),
                    ),
                  ),
                  _buildFormCell(
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '수량 입력',
                      ),
                    ),
                  ),
                ],
              ),
              // 헤더 행 2
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                children: [
                  _buildHeaderCell('기본사양'),
                  _buildHeaderCell('사이즈'),
                  _buildHeaderCell('특징'),
                  _buildHeaderCell('이미지'),
                  _buildHeaderCell(''),
                ],
              ),
              // 입력 행 2
              TableRow(
                children: [
                  _buildFormCell(
                    Column(
                      children: [
                        TextField(
                          controller: _dimensionXController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'X',
                            labelText: 'X',
                          ),
                        ),
                        TextField(
                          controller: _dimensionYController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Y',
                            labelText: 'Y',
                          ),
                        ),
                        TextField(
                          controller: _dimensionZController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Z',
                            labelText: 'Z',
                          ),
                        ),
                        TextField(
                          controller: _otherController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '그외',
                            labelText: '그외',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFormCell(
                    TextField(
                      controller: _sizeController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '6T x 4100mm',
                      ),
                    ),
                  ),
                  _buildFormCell(
                    TextField(
                      controller: _featuresController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'CNC',
                      ),
                    ),
                  ),
                  _buildFormCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '이미지, 영상 총 2개 등록가능',
                          style: TextStyle(fontSize: _responsiveFontSize(10)),
                        ),
                        Text(
                          '; 단 영상은 1개만',
                          style: TextStyle(fontSize: _responsiveFontSize(10)),
                        ),
                        Text(
                          '파일형식 다양하게 가능',
                          style: TextStyle(fontSize: _responsiveFontSize(10)),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: _pickImages,
                          child: Text('이미지 선택'),
                        ),
                        if (_selectedImages.isNotEmpty)
                          ..._selectedImages.map((image) => Text(
                            image.name,
                            style: TextStyle(fontSize: _responsiveFontSize(10)),
                          )),
                      ],
                    ),
                  ),
                  _buildFormCell(SizedBox.shrink()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCell(Widget child) {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: child,
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.take(2).toList(); // 최대 2개
      });
    }
  }

  Future<void> _savePost() async {
    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기업을 선택해주세요')),
      );
      return;
    }

    try {
      // 이미지 업로드
      List<String> imageUrls = [];
      for (final image in _selectedImages) {
        final imageUrl = await _uploadImageToStorage(File(image.path));
        imageUrls.add(imageUrl);
      }

      // 게시글 저장
      final postData = {
        'companyId': _selectedCompanyId,
        'title': _equipmentNameController.text.trim(),
        'equipmentName': _equipmentNameController.text.trim(),
        'content': '',
        'images': imageUrls,
        'status': 'published',
        'createdAt': FieldValue.serverTimestamp(),
        'viewCount': 0,
        'tags': [],
        'isPremium': false,
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'manufacturer': _manufacturerController.text.trim(),
        'model': _modelController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'dimensionX': _dimensionXController.text.trim(),
        'dimensionY': _dimensionYController.text.trim(),
        'dimensionZ': _dimensionZController.text.trim(),
        'tableSize': _sizeController.text.trim(),
        'features': _featuresController.text.trim(),
      };

      await _firestore.collection('posts').add(postData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 성공적으로 등록되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        // 폼 초기화
        _equipmentNameController.clear();
        _manufacturerController.clear();
        _modelController.clear();
        _quantityController.clear();
        _dimensionXController.clear();
        _dimensionYController.clear();
        _dimensionZController.clear();
        _otherController.clear();
        _sizeController.clear();
        _featuresController.clear();
        _selectedImages.clear();
        _selectedCategory = null;
        _selectedSubcategory = null;
      }
    } catch (e) {
      if (mounted) {
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

  List<String> _getSubcategories() {
    if (_selectedCategory == null) return [];
    final category = CategoryData.categories.firstWhere(
      (cat) => cat.title == _selectedCategory,
      orElse: () => CategoryModel(title: '', subcategories: []),
    );
    return category.subcategories;
  }

  String _formatCategory(Map<String, dynamic> postData) {
    final category = postData['category'] ?? '';
    final subcategory = postData['subcategory'] ?? '';
    
    if (category.isEmpty && subcategory.isEmpty) {
      return '';
    }
    
    if (subcategory.isNotEmpty) {
      return '$category > $subcategory';
    }
    
    return category;
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '정보 없음';
    
    try {
      DateTime date;
      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return '정보 없음';
      }
      
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}.${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '정보 없음';
    }
  }

  String _getAdGrade(Map<String, dynamic> postData) {
    final isPremium = postData['isPremium'] ?? false;
    final premiumExpiryDate = postData['premiumExpiryDate'];
    
    if (isPremium && premiumExpiryDate != null) {
      final expiry = _parseDate(premiumExpiryDate);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return '프리미엄';
      }
    }
    
    final adPayment = postData['adPayment'] ?? 0;
    if (adPayment > 0) {
      return '스탠다드';
    }
    
    return '-';
  }

  String _getAdPeriod(Map<String, dynamic> postData) {
    final isPremium = postData['isPremium'] ?? false;
    final premiumExpiryDate = postData['premiumExpiryDate'];
    final createdAt = _parseDate(postData['createdAt']);
    
    if (isPremium && premiumExpiryDate != null && createdAt != null) {
      final expiry = _parseDate(premiumExpiryDate);
      if (expiry != null) {
        final startDate = '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
        final endDate = '${expiry.year}.${expiry.month.toString().padLeft(2, '0')}.${expiry.day.toString().padLeft(2, '0')}';
        return '$startDate ~ $endDate';
      }
    }
    
    final adPayment = postData['adPayment'] ?? 0;
    if (adPayment > 0 && createdAt != null) {
      final endDate = createdAt.add(const Duration(days: 30));
      final startDate = '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}.${endDate.month.toString().padLeft(2, '0')}.${endDate.day.toString().padLeft(2, '0')}';
      return '$startDate ~ $endDateStr';
    }
    
    return '-';
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    
    try {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

