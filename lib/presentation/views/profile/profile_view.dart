import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/router/route_names.dart';
import '../../../domain/entities/user_entity.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../domain/entities/purchase_entity.dart' as entities;
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/inquiry_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/repositories/inquiry_repository.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/purchase_repository.dart';
import '../post/post_detail_view.dart';
import '../post/post_edit_view.dart';
import '../../../data/models/category_model.dart';

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
  
  // Company data state
  Map<String, dynamic>? _companyData;
  bool _isLoadingCompanyData = false;
  String? _companyDataError;
  bool _hasInitialLoadTriggered = false;
  bool _isEditMode = false;
  bool _isSaving = false;
  
  // Account edit mode state
  bool _isAccountEditMode = false;
  bool _isAccountSaving = false;
  
  // Form controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _ceoNameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  final TextEditingController _greetingController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  
  // Account info controllers
  final TextEditingController _accountCompanyNameController = TextEditingController();
  final TextEditingController _accountPhoneController = TextEditingController();
  
  // Password controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Category selection for editing
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSubSubcategory;
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedCompanyPhoto;
  File? _selectedCompanyLogo;
  File? _selectedBusinessLicense;
  
  // Categories data from CategoryData
  List<CategoryModel> get _categories => CategoryData.categories;
  
  // Legacy category mapping for backward compatibility
  final Map<String, String> _legacyCategoryMapping = {
    '절삭가공': '기계 제작',
    '절단/밴딩/절곡/용접': '기계 제작',
    '사출': '사출\n(공병, 플라스틱, 유리 등)',
    '금형': '*금형/몰드\n*3D 프린터',
    '*금형/몰드 *3D 프린터': '*금형/몰드\n*3D 프린터', // Firebase에 저장된 형태
    '표면처리': '*표면처리\n*건조기\n(열,UV,LED)',
    '인쇄': '인쇄',
    '기계제작': '기계 제작',
    '공구 MALL': '공구 MALL',
    '볼트': '공구 MALL',
    '유공압': '*유공압\n*모터',
    '전기 자재': '공구 MALL',
    'Vision': '*Vision\n(비전)\n*Robot\n(무인화)',
    'Motor': '*유공압\n*모터',
  };
  
  // Get subcategories for selected category
  List<String> _getSubcategoriesForSelectedCategory() {
    if (_selectedCategory == null) return [];
    
    final selectedCategoryModel = _categories.firstWhere(
      (category) => category.title == _selectedCategory,
      orElse: () => CategoryModel(title: '', subcategories: []),
    );
    
    return selectedCategoryModel.subcategories;
  }

  // Get sub-subcategories for selected subcategory
  List<String> _getSubSubcategoriesForSelected() {
    if (_selectedCategory == null || _selectedSubcategory == null) return [];
    return CategoryData.getSubSubcategories(_selectedCategory!, _selectedSubcategory!) ?? [];
  }

  // Dropdown helper: add dividers between items for better readability
  List<DropdownMenuItem<String>> _buildItemsWithDividers(List<String> items) {
    final List<DropdownMenuItem<String>> result = [];
    for (int i = 0; i < items.length; i++) {
      result.add(
        DropdownMenuItem<String>(
          value: items[i],
          child: Text(items[i]),
        ),
      );
      if (i < items.length - 1) {
        result.add(
          const DropdownMenuItem<String>(
            enabled: false,
            value: '__divider__',
            child: Divider(height: 1),
          ),
        );
      }
    }
    return result;
  }
  
  // Map legacy category to new category
  String? _mapLegacyCategory(String? legacyCategory) {
    if (legacyCategory == null) return null;
    return _legacyCategoryMapping[legacyCategory] ?? legacyCategory;
  }
  
  // Check if category is valid
  bool _isValidCategory(String? category) {
    if (category == null) return false;
    return _categories.any((cat) => cat.title == category);
  }
  
  // Check if subcategory is valid for current category
  bool _isValidSubcategory(String? subcategory) {
    if (subcategory == null || _selectedCategory == null) return false;
    return _getSubcategoriesForSelectedCategory().contains(subcategory);
  }

  bool _isValidSubSubcategory(String? subSubcategory) {
    if (subSubcategory == null || _selectedCategory == null || _selectedSubcategory == null) return false;
    return _getSubSubcategoriesForSelected().contains(subSubcategory);
  }
  
  @override
  void initState() {
    super.initState();
    // Consumer pattern으로 이동했으므로 여기서 직접 호출하지 않음
  }
  
  @override
  void dispose() {
    _companyNameController.dispose();
    _ceoNameController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _greetingController.dispose();
    _featuresController.dispose();
    _accountCompanyNameController.dispose();
    _accountPhoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  
  Future<void> _loadCompanyData() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (_isLoadingCompanyData) {
      return;
    }
    
    setState(() {
      _isLoadingCompanyData = true;
      _companyDataError = null;
      _companyData = null; // 기존 데이터 초기화
    });
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }
      
      // Load company data from Firestore companies collection
      DocumentSnapshot companyDoc;
      
      // First try with current user UID
      companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(currentUser.uid)
          .get();
      
      // If not found with UID, try to find by userId field
      if (!companyDoc.exists) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('userId', isEqualTo: currentUser.uid)
            .limit(1)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          companyDoc = querySnapshot.docs.first;
        }
      }
      
      // If still not found, try with the specific document ID as fallback
      if (!companyDoc.exists) {
        companyDoc = await FirebaseFirestore.instance
            .collection('companies')
            .doc('iXg3uBzc7VZvhcLd0jVqHGJ9Z972')
            .get();
      }
      
      if (mounted) {
        if (companyDoc.exists && companyDoc.data() != null) {
          setState(() {
            _companyData = companyDoc.data() as Map<String, dynamic>?;
            _isLoadingCompanyData = false;
          });
          _populateCompanyFields();
        } else {
          setState(() {
            _companyData = null;
            _isLoadingCompanyData = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _companyDataError = '기업 정보를 불러오는 중 오류가 발생했습니다: ${e.toString()}';
          _isLoadingCompanyData = false;
          _companyData = null;
        });
      }
      debugPrint('Error loading company data: $e');
    }
  }
  
  void _populateFormFields(UserEntity user) {
    _ceoNameController.text = user.name;
    _phoneController.text = user.phone;
  }
  
  void _populateAccountFields(UserEntity user) {
    _accountCompanyNameController.text = user.companyName ?? '';
    _accountPhoneController.text = user.phone;
  }
  
  void _populateCompanyFields() {
    if (_companyData == null) return;
    
    _companyNameController.text = _companyData!['companyName'] ?? '';
    _ceoNameController.text = _companyData!['ceoName'] ?? '';
    _phoneController.text = _companyData!['phone'] ?? '';
    _addressController.text = _companyData!['address'] ?? '';
    _detailAddressController.text = _companyData!['detailAddress'] ?? '';
    _websiteController.text = _companyData!['website'] ?? '';
    _greetingController.text = _companyData!['greeting'] ?? '';
    _featuresController.text = _companyData!['features'] ?? '';
    
    // Populate category information with legacy mapping
    final legacyCategory = _companyData!['category'];
    _selectedCategory = _mapLegacyCategory(legacyCategory);
    _selectedSubcategory = _companyData!['subcategory'];
    _selectedSubSubcategory = _companyData!['subSubcategory'];
    
    // Populate history items
    if (_companyData!['history'] != null) {
      final historyList = _companyData!['history'] as List<dynamic>;
      historyItems = historyList.map((item) => {
        'year': item['year']?.toString() ?? '',
        'content': item['content']?.toString() ?? '',
      }).toList();
      
      if (historyItems.isEmpty) {
        historyItems = [{'year': '', 'content': ''}];
      }
    }
    
    // Populate partner items
    if (_companyData!['clients'] != null) {
      final clientsList = _companyData!['clients'] as List<dynamic>;
      partnerItems = clientsList.map((item) => {
        'name': item['name']?.toString() ?? '',
        'details': item['details']?.toString() ?? '',
      }).toList();
      
      if (partnerItems.isEmpty) {
        partnerItems = [{'name': '', 'details': ''}];
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // AuthViewModel이 인증되고 사용자가 있으면 데이터 로드 (한 번만)
        if (authViewModel.isAuthenticated && 
            authViewModel.currentUser != null && 
            _companyData == null && 
            !_isLoadingCompanyData && 
            !_hasInitialLoadTriggered && 
            !authViewModel.isLoading) {
          _hasInitialLoadTriggered = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _populateFormFields(authViewModel.currentUser!);
              _populateAccountFields(authViewModel.currentUser!);
              _loadCompanyData();
            }
          });
        }
        
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
      },
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
    if (_isLoadingCompanyData) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(
                '기업 정보를 불러오는 중...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_companyDataError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                _companyDataError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  // 재시도 시 상태 초기화
                  setState(() {
                    _hasInitialLoadTriggered = false;
                  });
                  _loadCompanyData();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }
    
    // 로딩이 완료되었고 데이터가 없으며 에러도 없을 때만 빈 상태 표시
    if (!_isLoadingCompanyData && _companyData == null && _companyDataError == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center_outlined,
                size: 48.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                '등록된 기업 정보가 없습니다',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '기업회원 등록을 먼저 완료해주세요',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  // Navigate to company registration
                  context.push(RouteNames.companyRegistration);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: Text(
                  '기업회원 등록하기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
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
                if (_isEditMode) _buildCompanyImagesSection(),
                if (_isEditMode) SizedBox(height: 20.h),
                _buildTextFieldWithController('기업명', '기업명을 입력해주세요', _companyNameController, readOnly: !_isEditMode),
                SizedBox(height: 20.h),
                _buildTextFieldWithController('기업대표명', 'CEO 이름을 입력해주세요', _ceoNameController, isRequired: true, readOnly: !_isEditMode),
                SizedBox(height: 20.h),
                _buildTextFieldWithController('홈페이지', '홈페이지 주소를 입력해주세요', _websiteController, readOnly: !_isEditMode),
                SizedBox(height: 20.h),
                _buildTextFieldWithController('기업전화번호', '전화번호를 입력해주세요', _phoneController, readOnly: !_isEditMode),
                SizedBox(height: 20.h),
                _buildTextFieldWithController('기업주소', '기업주소를 입력해주세요', _addressController, readOnly: !_isEditMode),
                SizedBox(height: 20.h),
                _buildTextFieldWithController('상세주소', '상세주소를 입력해주세요', _detailAddressController, readOnly: !_isEditMode),
                SizedBox(height: 20.h),
                _buildTextFieldWithController('인사말', '인사말을 입력해주세요', _greetingController, readOnly: !_isEditMode),
                SizedBox(height: 20.h),
                if (!_isEditMode) _buildCategoryDisplaySection() else _buildCategoryEditSection(),
                SizedBox(height: 20.h),
                if (!_isEditMode) _buildHistoryDisplaySection() else _buildHistoryEditSection(),
                SizedBox(height: 20.h),
                if (!_isEditMode) _buildClientsDisplaySection() else _buildClientsEditSection(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          _buildSpecialNoteSection(),
          if (_companyData != null) _buildEditSaveButton(),
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
          onTap: _openPrivacyPolicy,
        ),
        _buildDivider(),
        _buildGeneralInfoItem(
          '서비스 이용약관',
          null,
          hasDropdown: true,
          onTap: _openTermsOfService,
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
          '유료광고 등록은 어떻게 하나요? 에 대한 답변입니다 나중 예정입니다\n이 무료예제는 제목에 대한 내용을 보여줄 예정이며 관리자에서\n수정할 수 있습니다 여러의 더길 길면이 있는 곳 까지 잘가는 줄\n예정입니다 또한 유료광고는 게시글 유료광고는 즐 등록될 때 허\n터에 나온 서비스 올려야시면 광고를 구매하는 위들이는 나올니다',
        ),
        _buildSubItem('자재 제목', null),
        _buildFaqList(),
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

  Widget _buildFaqList() {
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faqs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            debugPrint('FAQ 로드 오류: ${snapshot.error}');
            // 인덱스 오류 시 orderBy 없이 재시도
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('faqs')
                  .snapshots(),
              builder: (context, retrySnapshot) {
                if (retrySnapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (retrySnapshot.hasError) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(32.w, 0, 16.w, 16.h),
                    child: Text(
                      'FAQ를 불러올 수 없습니다.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                final faqs = retrySnapshot.data?.docs ?? [];
                
                if (faqs.isEmpty) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(32.w, 0, 16.w, 16.h),
                    child: Text(
                      '등록된 FAQ가 없습니다.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                // 클라이언트에서 정렬 (createdAt 기준)
                faqs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aCreatedAt = aData['createdAt'];
                  final bCreatedAt = bData['createdAt'];
                  
                  if (aCreatedAt == null && bCreatedAt == null) return 0;
                  if (aCreatedAt == null) return 1;
                  if (bCreatedAt == null) return -1;
                  
                  DateTime aDate;
                  DateTime bDate;
                  
                  try {
                    aDate = aCreatedAt is Timestamp ? aCreatedAt.toDate() : DateTime.parse(aCreatedAt.toString());
                    bDate = bCreatedAt is Timestamp ? bCreatedAt.toDate() : DateTime.parse(bCreatedAt.toString());
                    return bDate.compareTo(aDate); // 최신순
                  } catch (e) {
                    return 0;
                  }
                });

                return Column(
                  children: faqs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? '제목 없음';
                    final content = data['content'] ?? '내용 없음';
                    
                    return _buildSubItem(title, content);
                  }).toList(),
                );
              },
            );
          }

          final faqs = snapshot.data?.docs ?? [];
          
          if (faqs.isEmpty) {
            return Container(
              padding: EdgeInsets.fromLTRB(32.w, 0, 16.w, 16.h),
              child: Text(
                '등록된 FAQ가 없습니다.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          // 클라이언트에서 정렬 (createdAt 기준)
          faqs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aCreatedAt = aData['createdAt'];
            final bCreatedAt = bData['createdAt'];
            
            if (aCreatedAt == null && bCreatedAt == null) return 0;
            if (aCreatedAt == null) return 1;
            if (bCreatedAt == null) return -1;
            
            DateTime aDate;
            DateTime bDate;
            
            try {
              aDate = aCreatedAt is Timestamp ? aCreatedAt.toDate() : DateTime.parse(aCreatedAt.toString());
              bDate = bCreatedAt is Timestamp ? bCreatedAt.toDate() : DateTime.parse(bCreatedAt.toString());
              return bDate.compareTo(aDate); // 최신순
            } catch (e) {
              return 0;
            }
          });

          return Column(
            children: faqs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? '제목 없음';
              final content = data['content'] ?? '내용 없음';
              
              return _buildSubItem(title, content);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildGeneralInfoItem(String title, String? content, {bool hasDropdown = false, VoidCallback? onTap}) {
    if (onTap != null) {
      // For clickable items like privacy policy and terms
      return ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.open_in_new,
          color: Colors.grey[600],
          size: 20.sp,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      );
    }
    
    // For expandable items
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

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://www.notion.so/24c61d84851980feb8cdf7f031b8c642');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
        );
      } else {
        throw Exception('Cannot launch URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('개인 정보 처리 방침 페이지를 열 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openTermsOfService() async {
    final url = Uri.parse('https://www.notion.so/24c61d84851980efbc54d21196296bb1');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
        );
      } else {
        throw Exception('Cannot launch URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('서비스 이용약관 페이지를 열 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Edit/Save 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_isAccountEditMode) {
                        _saveAccountInfo();
                      } else {
                        setState(() {
                          _isAccountEditMode = true;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _isAccountEditMode ? const Color(0xFF1E3A5F) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: _isAccountSaving 
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isAccountEditMode ? '저장' : '수정',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _isAccountEditMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  if (_isAccountEditMode)
                    SizedBox(width: 8.w),
                  if (_isAccountEditMode)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAccountEditMode = false;
                          // Reset controllers to original values
                          final authViewModel = context.read<AuthViewModel>();
                          if (authViewModel.currentUser != null) {
                            _populateAccountFields(authViewModel.currentUser!);
                          }
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // 기업명
              _buildAccountField('기업명', _accountCompanyNameController.text, 
                  controller: _accountCompanyNameController, isEditable: false),
              SizedBox(height: 12.h),
              
              // 전화번호
              _buildAccountField('전화번호', _accountPhoneController.text,
                  controller: _accountPhoneController, isEditable: _isAccountEditMode),
              SizedBox(height: 12.h),
              
              // 현재 비밀번호 (읽기 모드에서는 ****** 표시, 편집 모드에서는 입력 필드)
              _buildAccountField('현재 비밀번호', 
                  _isAccountEditMode ? '' : '******',
                  controller: _currentPasswordController, 
                  isEditable: _isAccountEditMode,
                  isPassword: true,
                  hintText: _isAccountEditMode ? '현재 비밀번호를 입력하세요' : null),
              
              // 편집 모드일 때만 새 비밀번호 필드들 표시
              if (_isAccountEditMode) ...[
                SizedBox(height: 12.h),
                _buildAccountField('새 비밀번호', '',
                    controller: _newPasswordController, 
                    isEditable: true,
                    isPassword: true,
                    hintText: '새 비밀번호를 입력하세요'),
                SizedBox(height: 12.h),
                _buildAccountField('새 비밀번호 확인', '',
                    controller: _confirmPasswordController, 
                    isEditable: true,
                    isPassword: true,
                    hintText: '새 비밀번호를 다시 입력하세요'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountField(String label, String value, {
    TextEditingController? controller, 
    bool isEditable = false,
    bool isPassword = false,
    String? hintText
  }) {
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: isEditable && controller != null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: controller,
                        obscureText: isPassword,
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, 
                            vertical: 8.h
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : Container(
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
        _buildPurchaseHistoryList(),
      ],
    );
  }







  Widget _buildPostsList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Center(
        child: Text(
          '로그인이 필요합니다.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return StreamBuilder<List<PostEntity>>(
      stream: context.read<PostRepository>().streamUserPosts(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('❌ Posts stream error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '게시글을 불러오는 중 오류가 발생했습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '오류: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '등록된 게시글이 없습니다',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '게시글을 등록하여 제품을 홍보해보세요.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: posts.map((post) => _buildPostItemFromEntity(post)).toList(),
        );
      },
    );
  }

  Widget _buildPaymentSection() {
    return ExpansionTile(
      title: Text(
        '게시글',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              context.push('/post-registration');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '게시글 등록',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          const Icon(Icons.expand_more),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          child: _buildPostsList(),
        ),
      ],
    );
  }

  Widget _buildPurchaseHistoryList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Center(
        child: Text(
          '로그인이 필요합니다.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return StreamBuilder<List<entities.PurchaseEntity>>(
      stream: context.read<PurchaseRepository>().streamUserPurchases(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.w),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          final error = snapshot.error.toString();
          debugPrint('Purchase history error: $error');
          
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    error.contains('권한') 
                        ? '구매 내역에 접근할 권한이 없습니다.'
                        : error.contains('인덱스')
                            ? '데이터베이스 인덱스를 준비 중입니다.'
                            : '구매 내역을 불러오는 중 오류가 발생했습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    error.contains('권한') 
                        ? '로그아웃 후 다시 로그인해주세요.'
                        : error.contains('인덱스')
                            ? '잠시 후 다시 시도해주세요.'
                            : '네트워크 연결을 확인해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      // 강제로 위젯 새로고침
                      setState(() {});
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        final purchases = snapshot.data ?? [];
        
        if (purchases.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 40.sp,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  '구매 내역이 없습니다',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '아직 광고를 구매하지 않으셨네요.\n광고를 구매하여 비즈니스를 홍보해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
                 SizedBox(height: 32.h),
                 OutlinedButton.icon(
                   onPressed: () {
                     setState(() {}); // 새로고침
                   },
                   icon: Icon(
                     Icons.refresh,
                     size: 16.sp,
                   ),
                   label: Text(
                     '새로고침',
                     style: TextStyle(
                       fontSize: 12.sp,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                   style: OutlinedButton.styleFrom(
                     foregroundColor: Colors.grey[600],
                     side: BorderSide(color: Colors.grey[300]!),
                     padding: EdgeInsets.symmetric(
                       horizontal: 16.w, 
                       vertical: 8.h,
                     ),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.r),
                     ),
                   ),
                 ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '총 ${purchases.length}건의 구매내역',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12.h),
              ...purchases.map((purchase) => _buildPurchaseItem(purchase)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchaseItem(entities.PurchaseEntity purchase) {
    String getAdTypeName(entities.PurchaseType type) {
      switch (type) {
        case entities.PurchaseType.basicAd:
          return '기본 광고';
        case entities.PurchaseType.premiumAd:
          return '프리미엄 광고';
        case entities.PurchaseType.featured:
          return '추천 광고';
      }
    }

    String getStatusName(entities.PurchaseStatus status) {
      switch (status) {
        case entities.PurchaseStatus.pending:
          return '대기 중';
        case entities.PurchaseStatus.completed:
          return '완료';
        case entities.PurchaseStatus.failed:
          return '실패';
        case entities.PurchaseStatus.refunded:
          return '환불';
      }
    }

    Color getStatusColor(entities.PurchaseStatus status) {
      switch (status) {
        case entities.PurchaseStatus.pending:
          return Colors.orange;
        case entities.PurchaseStatus.completed:
          return Colors.green;
        case entities.PurchaseStatus.failed:
          return Colors.red;
        case entities.PurchaseStatus.refunded:
          return Colors.grey;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  getAdTypeName(purchase.purchaseType),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: getStatusColor(purchase.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  getStatusName(purchase.status),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: getStatusColor(purchase.status),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  '결제 금액',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Text(
                '${purchase.amount.toStringAsFixed(0)}원',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  '구매 일시',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Text(
                '${purchase.purchaseDate.year}.${purchase.purchaseDate.month.toString().padLeft(2, '0')}.${purchase.purchaseDate.day.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          if (purchase.expiryDate != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '만료 일시',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Text(
                  '${purchase.expiryDate!.year}.${purchase.expiryDate!.month.toString().padLeft(2, '0')}.${purchase.expiryDate!.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: purchase.expiryDate!.isAfter(DateTime.now()) 
                        ? Colors.green 
                        : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostItemFromEntity(PostEntity post) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && post.companyId == currentUser.uid;
    
    return InkWell(
      onTap: () {
        // 게시글 상세 보기로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailView(post: post),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: post.isPremium ? const Color(0xFFFF9800) : Colors.grey[300]!,
            width: post.isPremium ? 1.5 : 1,
          ),
        ),
        child: Row(
        children: [
          Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: post.images.isNotEmpty
                    ? Image.network(
                        post.images.first,
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
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image,
                          size: 24.sp,
                          color: Colors.grey[500],
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
                      post.category ?? '미분류',
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
                  '품명 ${post.equipmentName ?? post.title}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '특징 ${post.features ?? '특징 정보 없음'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '광고 ${post.premiumExpiryDate != null ? '${post.premiumExpiryDate!.year}.${post.premiumExpiryDate!.month.toString().padLeft(2, '0')}.${post.premiumExpiryDate!.day.toString().padLeft(2, '0')}까지' : '-'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _getPostStatusColor(post.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _getPostStatusText(post.status),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: _getPostStatusColor(post.status),
                        ),
                      ),
                    ),
                    if (post.isPremium) ...[
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '프리미엄',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // 본인 게시글인 경우에만 수정 버튼 표시
          if (isOwner)
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20.sp,
                color: const Color(0xFF1E3A5F),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostEditView(post: post),
                  ),
                );
              },
            ),
        ],
      ),
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              context.push('/inquiry-submission');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '1:1 문의 등록',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          const Icon(Icons.expand_more),
        ],
      ),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          child: _buildInquiryList(),
        ),
      ],
    );
  }

  Widget _buildInquiryList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Center(
        child: Text(
          '로그인이 필요합니다.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return StreamBuilder<List<InquiryEntity>>(
      stream: context.read<InquiryRepository>().streamUserInquiries(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('❌ Inquiry stream error: ${snapshot.error}');
          debugPrint('❌ Error type: ${snapshot.error.runtimeType}');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '문의 내역을 불러오는 중 오류가 발생했습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '오류: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        final inquiries = snapshot.data ?? [];

        if (inquiries.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '등록된 문의가 없습니다',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '궁금한 점이 있으시면 1:1 문의를 등록해주세요.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: inquiries.map((inquiry) => _buildInquiryItem(inquiry)).toList(),
        );
      },
    );
  }

  Widget _buildInquiryItem(InquiryEntity inquiry) {

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: () => _showInquiryDetailDialog(inquiry),
        borderRadius: BorderRadius.circular(8.r),
        child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        title: Text(
          inquiry.title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(inquiry.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    _getStatusText(inquiry.status),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(inquiry.status),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '${inquiry.createdAt.year}.${inquiry.createdAt.month.toString().padLeft(2, '0')}.${inquiry.createdAt.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '문의 내용',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    inquiry.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                if (inquiry.status == InquiryStatus.answered && inquiry.answer != null) ...[
                  SizedBox(height: 16.h),
                  Text(
                    '답변',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Text(
                      inquiry.answer!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (inquiry.answeredAt != null) ...[
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '답변일: ${inquiry.answeredAt!.year}.${inquiry.answeredAt!.month.toString().padLeft(2, '0')}.${inquiry.answeredAt!.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _showInquiryDetailDialog(InquiryEntity inquiry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.blue[700],
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inquiry.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(inquiry.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    _getStatusText(inquiry.status),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(inquiry.status),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '${inquiry.createdAt.year}.${inquiry.createdAt.month.toString().padLeft(2, '0')}.${inquiry.createdAt.day.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 내용
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 문의 내용
                        Text(
                          '문의 내용',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            inquiry.content,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                        
                        // 답변 내용
                        if (inquiry.status == InquiryStatus.answered && inquiry.answer != null) ...[
                          SizedBox(height: 24.h),
                          Text(
                            '답변',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Text(
                              inquiry.answer!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (inquiry.answeredAt != null) ...[
                            SizedBox(height: 8.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '답변일: ${inquiry.answeredAt!.year}.${inquiry.answeredAt!.month.toString().padLeft(2, '0')}.${inquiry.answeredAt!.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ] else if (inquiry.status == InquiryStatus.pending) ...[
                          SizedBox(height: 24.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.orange[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.orange[600],
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '답변을 기다리고 있습니다.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // 하단 버튼
                Container(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.pending:
        return '답변 대기중';
      case InquiryStatus.answered:
        return '답변 완료';
      case InquiryStatus.closed:
        return '종료';
    }
  }

  Color _getStatusColor(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.pending:
        return Colors.orange;
      case InquiryStatus.answered:
        return Colors.green;
      case InquiryStatus.closed:
        return Colors.grey;
    }
  }

  String _getPostStatusText(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return '임시저장';
      case PostStatus.published:
        return '게시중';
      case PostStatus.hidden:
        return '숨김';
      case PostStatus.deleted:
        return '삭제됨';
    }
  }

  Color _getPostStatusColor(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return Colors.grey;
      case PostStatus.published:
        return Colors.green;
      case PostStatus.hidden:
        return Colors.orange;
      case PostStatus.deleted:
        return Colors.red;
    }
  }


  Widget _buildOtherSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: _logout,
            child: Text(
              '로그아웃',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _showDeleteAccountDialog,
            child: Container(
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
              GestureDetector(
                onTap: !_isEditMode ? _enableEditMode : null,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 120.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: _isEditMode ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
                    ),
                  ),
                  child: TextFormField(
                    controller: _featuresController,
                    readOnly: !_isEditMode,
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText: _featuresController.text.isEmpty 
                          ? '특징을 입력해주세요' 
                          : null,
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _isEditMode ? Colors.black : Colors.black87,
                    ),
                  ),
                ),
              ),
              if (!_isEditMode && _featuresController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    '클릭하여 수정',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[500],
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
        } else if (label == '되돌가기') {
          if (context.canPop()) {
            context.pop();
          } else {
            // 루트에서도 비활성화하지 않고 메인으로 이동
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
  
  // New methods for backend integration
  Widget _buildTextFieldWithController(String label, String hint, TextEditingController controller, {bool isRequired = false, bool readOnly = false}) {
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
          controller: controller,
          readOnly: readOnly,
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
            fillColor: readOnly ? Colors.grey[50] : Colors.white,
            filled: readOnly,
          ),
        ),
      ],
    );
  }
  

  
  Future<void> _saveAccountInfo() async {
    if (_isAccountSaving) return;
    
    setState(() {
      _isAccountSaving = true;
    });
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }
      
      // 비밀번호 변경이 요청된 경우
      if (_newPasswordController.text.isNotEmpty) {
        // 비밀번호 검증
        if (_currentPasswordController.text.isEmpty) {
          throw Exception('현재 비밀번호를 입력해주세요.');
        }
        
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw Exception('새 비밀번호가 일치하지 않습니다.');
        }
        
        if (_newPasswordController.text.length < 8) {
          throw Exception('새 비밀번호는 8자 이상이어야 합니다.');
        }
        
        // Firebase Authentication으로 비밀번호 재인증
        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: _currentPasswordController.text,
        );
        
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.updatePassword(_newPasswordController.text);
      }
      
      // 전화번호 업데이트
      Map<String, dynamic> updateData = {};
      if (_accountPhoneController.text.trim() != currentUser.phoneNumber) {
        updateData['phone'] = _accountPhoneController.text.trim();
      }
      
      // Firestore users 컬렉션 업데이트
      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(updateData);
      }
      
      // 성공 메시지
      if (mounted) {
        setState(() {
          _isAccountEditMode = false;
          _isAccountSaving = false;
        });
        
        // 비밀번호 필드 초기화
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정 정보가 성공적으로 저장되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAccountSaving = false;
        });
        
        String errorMessage = '계정 정보 저장 중 오류가 발생했습니다.';
        if (e.toString().contains('wrong-password')) {
          errorMessage = '현재 비밀번호가 올바르지 않습니다.';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = '새 비밀번호가 너무 약합니다.';
        } else if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  

  
  void _logout() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.signOut();
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그아웃 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회원탈퇴'),
          content: const Text('정말로 회원탈퇴를 하시겠습니까?\n\n탈퇴 후에는 모든 데이터가 삭제되며 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('탈퇴'),
            ),
          ],
        );
      },
    );
  }
  
  void _deleteAccount() async {
    try {
      // TODO: Implement account deletion
      // await authViewModel.deleteAccount();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원탈퇴가 완료되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원탈퇴 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Edit/Save button
  Widget _buildEditSaveButton() {
    if (!_isEditMode) {
      // Show "수정" button only when not in edit mode
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _enableEditMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              '수정',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    
    // Show "완료" button only in edit mode
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveCompanyData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A5F),
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  '완료',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _enableEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  // Company images section
  Widget _buildCompanyImagesSection() {
    if (_companyData == null) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회사 이미지',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Company Photo
            Expanded(
              child: _buildImageContainer(
                title: '회사사진',
                imageUrl: _companyData!['photo'],
                selectedFile: _selectedCompanyPhoto,
                height: 120.h,
                onTap: _pickCompanyPhoto,
              ),
            ),
            SizedBox(width: 16.w),
            // Company Logo
            Expanded(
              child: _buildImageContainer(
                title: '회사로고',
                imageUrl: _companyData!['logo'],
                selectedFile: _selectedCompanyLogo,
                height: 120.h,
                onTap: _pickCompanyLogo,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Business License
        _buildImageContainer(
          title: '사업자등록증',
          imageUrl: _getBusinessLicenseUrl(),
          selectedFile: _selectedBusinessLicense,
          height: 200.h,
          fullWidth: true,
          onTap: _pickBusinessLicense,
        ),
      ],
    );
  }

  Widget _buildImageContainer({
    required String title,
    String? imageUrl,
    File? selectedFile,
    required double height,
    bool fullWidth = false,
    VoidCallback? onTap,
  }) {
    final hasImage = selectedFile != null || (imageUrl != null && imageUrl.isNotEmpty);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: _isEditMode ? onTap : null,
          child: Container(
            width: fullWidth ? double.infinity : null,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isEditMode 
                    ? (hasImage ? const Color(0xFF1E3A5F) : Colors.grey[300]!)
                    : Colors.grey[300]!,
                width: _isEditMode && hasImage ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[50],
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: selectedFile != null
                        ? Image.file(
                            selectedFile,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 32.sp,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      '이미지 로드 실패',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditMode ? Icons.add_photo_alternate : Icons.image_outlined,
                          size: 32.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _isEditMode ? '클릭하여 이미지 선택' : '이미지 없음',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
  
  Future<void> _pickCompanyPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        setState(() {
          _selectedCompanyPhoto = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  Future<void> _pickCompanyLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        setState(() {
          _selectedCompanyLogo = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  Future<void> _pickBusinessLicense() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        setState(() {
          _selectedBusinessLicense = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 사업자 등록증 URL 가져오기 (두 필드 모두 확인)
  String? _getBusinessLicenseUrl() {
    if (_companyData == null) return null;
    
    // businessLicenseImage 필드 확인
    final businessLicenseImage = _companyData!['businessLicenseImage'];
    if (businessLicenseImage != null && businessLicenseImage.toString().isNotEmpty) {
      return businessLicenseImage.toString();
    }
    
    // businessLicenseUrl 필드 확인 (회원가입 시 사용)
    final businessLicenseUrl = _companyData!['businessLicenseUrl'];
    if (businessLicenseUrl != null && businessLicenseUrl.toString().isNotEmpty) {
      return businessLicenseUrl.toString();
    }
    
    return null;
  }

  Future<String> _uploadImage(File image, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  Future<void> _saveCompanyData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('사용자가 로그인되지 않았습니다.');
      }

      // Upload images if selected
      String? photoUrl = _companyData?['photo'];
      String? logoUrl = _companyData?['logo'];
      String? businessLicenseUrl = _getBusinessLicenseUrl();

      if (_selectedCompanyPhoto != null) {
        photoUrl = await _uploadImage(
          _selectedCompanyPhoto!,
          'company_photos/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      if (_selectedCompanyLogo != null) {
        logoUrl = await _uploadImage(
          _selectedCompanyLogo!,
          'company_logos/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      if (_selectedBusinessLicense != null) {
        businessLicenseUrl = await _uploadImage(
          _selectedBusinessLicense!,
          'business_licenses/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Prepare updated company data
      final updatedData = {
        'companyName': _companyNameController.text.trim(),
        'ceoName': _ceoNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'detailAddress': _detailAddressController.text.trim(),
        'website': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        'greeting': _greetingController.text.trim().isEmpty ? null : _greetingController.text.trim(),
        'features': _featuresController.text.trim().isEmpty ? null : _featuresController.text.trim(),
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'subSubcategory': _selectedSubSubcategory,
        'history': historyItems.map((item) => {
          'year': item['year'] ?? '',
          'content': item['content'] ?? '',
        }).where((item) => item['year']!.isNotEmpty || item['content']!.isNotEmpty).toList(),
        'clients': partnerItems.map((item) => {
          'name': item['name'] ?? '',
          'details': item['details'] ?? '',
        }).where((item) => item['name']!.isNotEmpty || item['details']!.isNotEmpty).toList(),
        'photo': photoUrl,
        'logo': logoUrl,
        'businessLicenseImage': businessLicenseUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(currentUser.uid)
          .update(updatedData);

      // Clear selected images after upload
      setState(() {
        _companyData = {..._companyData!, ...updatedData};
        _selectedCompanyPhoto = null;
        _selectedCompanyLogo = null;
        _selectedBusinessLicense = null;
        _isEditMode = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기업 정보가 성공적으로 업데이트되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업데이트 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Edit mode sections
  Widget _buildCategoryEditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '업종',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _isValidCategory(_selectedCategory) ? _selectedCategory : null,
          decoration: InputDecoration(
            hintText: '업종을 선택해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          ),
          items: _buildCategoryItemsWithDividers(_categories.map((category) => category.title).toList()),
          onChanged: (value) {
            if (value != null && 
                value != '__category_divider__' && 
                value != '__section_divider__' && 
                value != '__item_divider__') {
              setState(() {
                _selectedCategory = value;
                _selectedSubcategory = null; // 카테고리 변경 시 세부카테고리 초기화
                _selectedSubSubcategory = null;
              });
            }
          },
        ),
        SizedBox(height: 16.h),
        Text(
          '세부업종',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _isValidSubcategory(_selectedSubcategory) ? _selectedSubcategory : null,
          decoration: InputDecoration(
            hintText: '세부업종을 선택해주세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          ),
          items: _buildItemsWithDividers(_getSubcategoriesForSelectedCategory()),
          onChanged: (value) {
            setState(() {
              _selectedSubcategory = value;
              _selectedSubSubcategory = null;
            });
          },
        ),
        SizedBox(height: 16.h),
        if (_selectedCategory != null &&
            _selectedSubcategory != null &&
            CategoryData.hasSubSubcategories(_selectedCategory!, _selectedSubcategory!)) ...[
          Text(
            '3차 세부업종',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _isValidSubSubcategory(_selectedSubSubcategory) ? _selectedSubSubcategory : null,
            decoration: InputDecoration(
              hintText: '3차 세부업종을 선택해주세요 (선택)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            ),
            items: _buildItemsWithDividers(_getSubSubcategoriesForSelected()),
            onChanged: (value) {
              setState(() {
                _selectedSubSubcategory = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryEditSection() {
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
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60.w,
                  child: TextFormField(
                    initialValue: item['year'] ?? '',
                    onChanged: (value) => item['year'] = value,
                    decoration: const InputDecoration(
                      hintText: 'YYYY',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    initialValue: item['content'] ?? '',
                    onChanged: (value) => item['content'] = value,
                    decoration: const InputDecoration(
                      hintText: '연혁 내용을 입력하세요',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      historyItems.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              historyItems.add({'year': '', 'content': ''});
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('연혁 추가'),
        ),
      ],
    );
  }

  Widget _buildClientsEditSection() {
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
          final index = entry.key;
          final item = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: item['name'] ?? '',
                        onChanged: (value) => item['name'] = value,
                        decoration: const InputDecoration(
                          hintText: '거래처명',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          partnerItems.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: item['details'] ?? '',
                  onChanged: (value) => item['details'] = value,
                  decoration: const InputDecoration(
                    hintText: '거래 상세내용',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  maxLines: 2,
                  style: TextStyle(fontSize: 13.sp),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              partnerItems.add({'name': '', 'details': ''});
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('거래처 추가'),
        ),
      ],
    );
  }

  // Display methods for existing UI structure
  Widget _buildCategoryDisplaySection() {
    if (_companyData == null) return SizedBox();
    
    final category = _companyData!['category']?.toString() ?? '';
    final subcategory = _companyData!['subcategory']?.toString() ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '업종',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.grey[50],
          ),
          child: Text(
            '$category > $subcategory',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHistoryDisplaySection() {
    if (_companyData == null || _companyData!['history'] == null || (_companyData!['history'] as List).isEmpty) {
      return SizedBox();
    }
    
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
        ...(_companyData!['history'] as List<dynamic>).map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[50],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60.w,
                  child: Text(
                    item['year']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A5F),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item['content']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
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
  
  Widget _buildClientsDisplaySection() {
    if (_companyData == null || _companyData!['clients'] == null || (_companyData!['clients'] as List).isEmpty) {
      return SizedBox();
    }
    
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
        ...(_companyData!['clients'] as List<dynamic>).map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[50],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (item['details'] != null && item['details'].toString().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item['details'].toString(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // 업종 드롭다운용: 각 카테고리 사이에 구분선 추가 (세부업종과 동일한 스타일)
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
      // 마지막 항목이 아니면 구분선 추가 (세부업종과 동일한 스타일)
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

}