import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/router/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/category_model.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  // Regional area codes for landline numbers
  static const List<String> regionalCodes = [
    '032', '042', '051', '052', '053', '062', '064', 
    '031', '033', '041', '043', '054', '055', '061', '063'
  ];
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.isEmpty) {
      return TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    
    // 02 서울 지역번호 (02-xxx-xxxx)
    if (digits.startsWith('02')) {
      if (digits.length <= 2) {
        return TextEditingValue(
          text: digits,
          selection: TextSelection.collapsed(offset: digits.length),
        );
      } else if (digits.length <= 5) {
        final String formatted = '${digits.substring(0, 2)}-${digits.substring(2)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else if (digits.length <= 9) {
        final String formatted = '${digits.substring(0, 2)}-${digits.substring(2, 5)}-${digits.substring(5)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else {
        // Limit to 9 digits for 02 numbers
        final String limitedDigits = digits.substring(0, 9);
        final String formatted = '${limitedDigits.substring(0, 2)}-${limitedDigits.substring(2, 5)}-${limitedDigits.substring(5)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
    
    // 지역 번호 확인 (032, 042, 051 등)
    bool isRegionalCode = false;
    for (String code in regionalCodes) {
      if (digits.startsWith(code)) {
        isRegionalCode = true;
        break;
      }
    }
    
    // 지역번호 (000-xxx-xxxx)
    if (isRegionalCode) {
      if (digits.length <= 3) {
        return TextEditingValue(
          text: digits,
          selection: TextSelection.collapsed(offset: digits.length),
        );
      } else if (digits.length <= 6) {
        final String formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else if (digits.length <= 10) {
        final String formatted = '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      } else {
        // Limit to 10 digits for regional numbers
        final String limitedDigits = digits.substring(0, 10);
        final String formatted = '${limitedDigits.substring(0, 3)}-${limitedDigits.substring(3, 6)}-${limitedDigits.substring(6)}';
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
    
    // 휴대폰 번호 (010-xxxx-xxxx) - 기존 로직 유지
    if (digits.length <= 3) {
      return TextEditingValue(
        text: digits,
        selection: TextSelection.collapsed(offset: digits.length),
      );
    } else if (digits.length <= 7) {
      final String formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else if (digits.length <= 11) {
      final String formatted = '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      // Limit to 11 digits for mobile numbers
      final String limitedDigits = digits.substring(0, 11);
      final String formatted = '${limitedDigits.substring(0, 3)}-${limitedDigits.substring(3, 7)}-${limitedDigits.substring(7)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}

class CompanyRegistrationView extends StatefulWidget {
  const CompanyRegistrationView({super.key});

  @override
  State<CompanyRegistrationView> createState() => _CompanyRegistrationViewState();
}

class _CompanyRegistrationViewState extends State<CompanyRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _companyNameFromSignup;
  String? _businessLicenseUrlFromSignup;
  
  // Form controllers
  final _companyNameController = TextEditingController();
  final _ceoNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _greetingController = TextEditingController();
  final _featuresController = TextEditingController();
  
  // Dynamic lists for history and clients
  List<Map<String, TextEditingController>> historyItems = [];
  List<Map<String, TextEditingController>> partnerItems = [];
  
  // Category selections
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedSubSubcategory;
  
  // Categories data from CategoryData
  List<CategoryModel> get _categories => CategoryData.categories;
  
  // Get subcategories for selected category (평탄화된 리스트, 드롭다운 value 매칭용)
  // 가장 작은 단위의 세부 카테고리까지 평탄화하여 반환
  List<String> _getSubcategoriesForSelectedCategory() {
    if (_selectedCategory == null) return [];
    
    final selectedCategoryModel = _categories.firstWhere(
      (category) => category.title == _selectedCategory,
      orElse: () => CategoryModel(title: '', subcategories: []),
    );
    
    final List<String> result = [];
    final subSubcategories = selectedCategoryModel.subSubcategories;
    final subSubSubcategories = selectedCategoryModel.subSubSubcategories;
    
    if (subSubcategories != null && subSubcategories.isNotEmpty) {
      // 각 subcategory별로 세부 카테고리를 수집
      for (final subcategory in selectedCategoryModel.subcategories) {
        final subSubcats = subSubcategories[subcategory];
        if (subSubcats != null && subSubcats.isNotEmpty) {
          // 각 subSubcategory에 대해 4차 카테고리 확인
          for (final subSubcat in subSubcats) {
            final cleanedSubSubcat = subSubcat.replaceAll('*', '').trim();
            
            // 4차 카테고리(subSubSubcategories)가 있는지 확인
            if (subSubSubcategories != null && 
                subSubSubcategories.containsKey(subSubcat)) {
              // 4차 카테고리가 있으면 그것들을 추가
              final subSubSubcats = subSubSubcategories[subSubcat] ?? [];
              for (final subSubSubcat in subSubSubcats) {
                final cleaned = subSubSubcat.replaceAll('*', '').trim();
                if (cleaned.isNotEmpty && !result.contains(cleaned)) {
                  result.add(cleaned);
                }
              }
            } else {
              // 4차 카테고리가 없으면 3차 카테고리 자체를 추가
              if (cleanedSubSubcat.isNotEmpty && !result.contains(cleanedSubSubcat)) {
                result.add(cleanedSubSubcat);
              }
            }
          }
        } else {
          // subSubcategories가 없으면 subcategory의 첫 줄만 사용 (* 제거)
          final cleaned = subcategory.split('\n').first.trim().replaceAll('*', '').trim();
          if (cleaned.isNotEmpty && !result.contains(cleaned)) {
            result.add(cleaned);
          }
        }
      }
    } else {
      // subSubcategories가 없으면 subcategory의 첫 줄만 사용 (* 제거)
      for (final subcategory in selectedCategoryModel.subcategories) {
        final cleaned = subcategory.split('\n').first.trim().replaceAll('*', '').trim();
        if (cleaned.isNotEmpty && !result.contains(cleaned)) {
          result.add(cleaned);
        }
      }
    }
    
    return result;
  }
  
  // 섹션별로 그룹화된 세부업종 목록 (구분선용) - 가장 작은 단위까지 포함
  Map<String, List<String>> _getSubcategoriesGroupedBySection() {
    if (_selectedCategory == null) return {};
    
    final selectedCategoryModel = _categories.firstWhere(
      (category) => category.title == _selectedCategory,
      orElse: () => CategoryModel(title: '', subcategories: []),
    );
    
    final Map<String, List<String>> grouped = {};
    final subSubcategories = selectedCategoryModel.subSubcategories;
    final subSubSubcategories = selectedCategoryModel.subSubSubcategories;
    
    if (subSubcategories != null && subSubcategories.isNotEmpty) {
      // 각 subcategory별로 그룹화
      for (final subcategory in selectedCategoryModel.subcategories) {
        final subSubcats = subSubcategories[subcategory];
        if (subSubcats != null && subSubcats.isNotEmpty) {
          // 섹션 이름: 첫 줄만 사용 (예: "가공1\n*선반,밀링..." -> "가공1")
          final sectionName = subcategory.split('\n').first.trim().replaceAll('*', '').trim();
          final List<String> sectionItems = [];
          
          // 각 subSubcategory에 대해 4차 카테고리 확인
          for (final subSubcat in subSubcats) {
            final cleanedSubSubcat = subSubcat.replaceAll('*', '').trim();
            
            // 4차 카테고리(subSubSubcategories)가 있는지 확인
            if (subSubSubcategories != null && 
                subSubSubcategories.containsKey(subSubcat)) {
              // 4차 카테고리가 있으면 그것들을 추가
              final subSubSubcats = subSubSubcategories[subSubcat] ?? [];
              for (final subSubSubcat in subSubSubcats) {
                final cleaned = subSubSubcat.replaceAll('*', '').trim();
                if (cleaned.isNotEmpty && !sectionItems.contains(cleaned)) {
                  sectionItems.add(cleaned);
                }
              }
            } else {
              // 4차 카테고리가 없으면 3차 카테고리 자체를 추가
              if (cleanedSubSubcat.isNotEmpty && !sectionItems.contains(cleanedSubSubcat)) {
                sectionItems.add(cleanedSubSubcat);
              }
            }
          }
          
          if (sectionItems.isNotEmpty) {
            grouped[sectionName] = sectionItems;
          }
        } else {
          // subSubcategories가 없으면 subcategory 자체를 섹션으로
          final cleaned = subcategory.split('\n').first.trim().replaceAll('*', '').trim();
          if (cleaned.isNotEmpty) {
            grouped[cleaned] = [cleaned];
          }
        }
      }
    } else {
      // subSubcategories가 없으면 subcategory를 섹션으로
      for (final subcategory in selectedCategoryModel.subcategories) {
        final cleaned = subcategory.split('\n').first.trim().replaceAll('*', '').trim();
        if (cleaned.isNotEmpty) {
          grouped[cleaned] = [cleaned];
        }
      }
    }
    
    return grouped;
  }
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;
  File? _companyPhoto;

  // Dropdown helper: add dividers between sections for better readability
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
  
  // 섹션별로 그룹화된 드롭다운 아이템 생성 (구분선 포함)
  List<DropdownMenuItem<String>> _buildGroupedItemsWithDividers() {
    final List<DropdownMenuItem<String>> result = [];
    final grouped = _getSubcategoriesGroupedBySection();
    
    bool isFirstSection = true;
    for (final entry in grouped.entries) {
      // 섹션 구분선 (첫 번째 섹션 제외)
      if (!isFirstSection) {
        result.add(
          const DropdownMenuItem<String>(
            enabled: false,
            value: '__section_divider__',
            child: Divider(height: 2, thickness: 2),
          ),
        );
      }
      isFirstSection = false;
      
      // 섹션 내 아이템들
      for (int i = 0; i < entry.value.length; i++) {
        result.add(
          DropdownMenuItem<String>(
            value: entry.value[i],
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(entry.value[i]),
            ),
          ),
        );
        // 섹션 내 마지막 아이템이 아니면 구분선 추가
        if (i < entry.value.length - 1) {
          result.add(
            const DropdownMenuItem<String>(
              enabled: false,
              value: '__item_divider__',
              child: Divider(height: 1),
            ),
          );
        }
      }
    }
    
    return result;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  bool _isCompanyNameReadOnly = false; // 개인 계정으로 가입한 경우 입력 가능하도록

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData?['userType'] == 'company') {
            // 기업 계정으로 가입한 경우: 기업명 자동 입력, 읽기 전용
            setState(() {
              _companyNameFromSignup = userData?['companyName'];
              _companyNameController.text = _companyNameFromSignup ?? '';
              _businessLicenseUrlFromSignup = userData?['businessLicenseUrl'];
              _isCompanyNameReadOnly = true; // 읽기 전용
              _isLoading = false;
            });
          } else {
            // 개인 계정으로 가입한 경우: 기업명 입력 가능
            setState(() {
              _isCompanyNameReadOnly = false; // 입력 가능
              _isLoading = false;
            });
          }
        } else {
          // 문서가 없어도 로딩 완료 (개인 계정으로 간주)
          setState(() {
            _isCompanyNameReadOnly = false;
            _isLoading = false;
          });
        }
      } else {
        // 사용자가 없어도 로딩 완료 (개인 계정으로 간주)
        setState(() {
          _isCompanyNameReadOnly = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _isCompanyNameReadOnly = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _ceoNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _websiteController.dispose();
    _greetingController.dispose();
    _featuresController.dispose();
    
    // Dispose dynamic list controllers
    for (var item in historyItems) {
      item['year']?.dispose();
      item['content']?.dispose();
    }
    for (var item in partnerItems) {
      item['name']?.dispose();
      item['details']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.go(RouteNames.main),
        ),
        title: const Text(
          '기업회원 등록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기업정보를 입력해주세요',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '입력하신 정보는 검토 후 승인됩니다.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    
                    // 기업명 (기업 계정: 자동 입력/읽기 전용, 개인 계정: 입력 가능)
                    _buildTextField(
                      label: '기업명',
                      controller: _companyNameController,
                      hintText: '기업명을 입력해주세요',
                      isRequired: true,
                      readOnly: _isCompanyNameReadOnly,
                      suffixIcon: _isCompanyNameReadOnly 
                          ? const Icon(Icons.lock_outline, size: 20)
                          : null,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 기업 대표명
                    _buildTextField(
                      label: '기업 대표명',
                      controller: _ceoNameController,
                      hintText: '대표자명을 입력해주세요',
                      isRequired: true,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 업종 (토글) - 구분선 추가
                    _buildDropdown(
                      label: '업종',
                      value: _selectedCategory,
                      items: _categories.map((category) => category.title).toList(),
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
                      isRequired: true,
                      itemBuilderOverride: (items) => _buildCategoryItemsWithDividers(items),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 세부업종 (항상 표시, * 제거, 섹션별 구분선)
                    _buildDropdown(
                      label: '세부업종',
                      value: _selectedSubcategory,
                      items: _selectedCategory != null ? _getSubcategoriesForSelectedCategory() : [],
                      onChanged: (value) {
                        if (_selectedCategory != null) {
                          setState(() {
                            _selectedSubcategory = value;
                            _selectedSubSubcategory = null;
                          });
                        }
                      },
                      isRequired: true,
                      itemBuilderOverride: _selectedCategory != null
                          ? (items) => _buildGroupedItemsWithDividers()
                          : null,
                    ),
                    
                    // 3차 세부업종은 제거 (세부업종에서 가장 작은 단위까지 선택 가능하도록 변경)
                    
                    SizedBox(height: 16.h),
                    
                    // 홈페이지
                    _buildTextField(
                      label: '홈페이지',
                      controller: _websiteController,
                      hintText: 'www.example.com',
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 기업전화번호
                    _buildTextField(
                      label: '기업전화번호',
                      controller: _phoneController,
                      hintText: '010-1234-5678',
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      inputFormatters: [PhoneNumberFormatter()],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 기업주소 (메인페이지 지도에 표시)
                    _buildTextField(
                      label: '기업주소',
                      controller: _addressController,
                      hintText: '주소를 입력해주세요 (지도에 표시됩니다)',
                      isRequired: true,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 상세주소
                    _buildTextField(
                      label: '상세주소',
                      controller: _detailAddressController,
                      hintText: '상세주소를 입력해주세요',
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 인사말
                    _buildTextField(
                      label: '인사말',
                      controller: _greetingController,
                      hintText: '고객님께 전하는 인사말을 입력해주세요',
                      maxLines: 3,
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // 연혁
                    _buildHistorySection(),
                    
                    SizedBox(height: 16.h),
                    
                    // 주요거래처
                    _buildPartnersSection(),
                    
                    SizedBox(height: 16.h),
                    
                    // 특징
                    _buildTextField(
                      label: '특징',
                      controller: _featuresController,
                      hintText: '기업의 특징이나 강점을 입력해주세요',
                      maxLines: 3,
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // 회사사진과 회사로고 한 줄 배치
                    _buildPhotoAndLogoSection(),
                    
                    SizedBox(height: 16.h),
                    
                    // 사업자 등록증 (회원가입 시 업로드한 이미지 표시)
                    _buildBusinessLicenseSection(),
                    
                    SizedBox(height: 32.h),
                    
                    // 등록 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                '등록하기',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    bool readOnly = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
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
            if (readOnly)
              Text(
                ' (자동)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
            ),
            suffixIcon: suffixIcon,
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
              vertical: 14.h,
            ),
            fillColor: readOnly ? Colors.grey[50] : null,
            filled: readOnly,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label을(를) 입력해주세요.';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
  
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
    List<DropdownMenuItem<String>> Function(List<String> items)? itemBuilderOverride,
  }) {
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
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true, // 선택된 값이 칸에 맞춰서 보이도록
          items: itemBuilderOverride != null
              ? itemBuilderOverride(items)
              : items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis, // 긴 텍스트는 ... 처리
                    ),
                  );
                }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '$label을(를) 선택해주세요',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14.sp,
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
              vertical: 14.h,
            ),
          ),
          selectedItemBuilder: (context) {
            // 선택된 항목 표시용 빌더 (드롭다운이 열리지 않을 때 표시)
            return items.map((item) {
              return Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              );
            }).toList();
          },
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label을(를) 선택해주세요.';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPhotoAndLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회사사진 & 회사로고',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            // 회사사진
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '회사사진',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: _pickCompanyPhoto,
                    child: Container(
                      width: double.infinity,
                      height: 120.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.grey[50],
                      ),
                      child: _companyPhoto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                _companyPhoto!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 32.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '회사사진 선택',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // 회사로고
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '회사로고',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: _pickCompanyLogo,
                    child: Container(
                      width: double.infinity,
                      height: 120.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.grey[50],
                      ),
                      child: _logoImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                _logoImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 32.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '회사로고 선택',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildHistorySection() {
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
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 연도 입력
                      SizedBox(
                        width: 80.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '연도',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextFormField(
                                controller: item['year'],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'YYYY',
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 내용 입력
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '연혁 내용',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              height: 48.h, // 왼쪽 박스와 동일한 높이
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextFormField(
                                controller: item['content'],
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: '연혁 내용을 입력해주세요',
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12.w),
                                ),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // 삭제 버튼
                      Container(
                        margin: EdgeInsets.only(top: 20.h),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              item['year']?.dispose();
                              item['content']?.dispose();
                              historyItems.removeAt(index);
                            });
                          },
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                historyItems.add({
                  'year': TextEditingController(),
                  'content': TextEditingController(),
                });
              });
            },
            icon: Icon(Icons.add, size: 20.sp),
            label: Text('연혁 추가하기'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: const Color(0xFF1E3A5F)),
              foregroundColor: const Color(0xFF1E3A5F),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPartnersSection() {
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
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 거래처명 입력
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '거래처명',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextFormField(
                                controller: item['name'],
                                decoration: InputDecoration(
                                  hintText: '거래처명',
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 상세내용 입력
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '거래 상세내용',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              height: 48.h, // 왼쪽 박스와 동일한 높이
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextFormField(
                                controller: item['details'],
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: '기타 사항 입력',
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(12.w),
                                ),
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // 삭제 버튼
                      Container(
                        margin: EdgeInsets.only(top: 20.h),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              item['name']?.dispose();
                              item['details']?.dispose();
                              partnerItems.removeAt(index);
                            });
                          },
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                partnerItems.add({
                  'name': TextEditingController(),
                  'details': TextEditingController(),
                });
              });
            },
            icon: Icon(Icons.add, size: 20.sp),
            label: Text('주요 거래처 추가'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: const Color(0xFF1E3A5F)),
              foregroundColor: const Color(0xFF1E3A5F),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBusinessLicenseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '사업자 등록증',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
              ),
            ),
            Text(
              ' (회원가입 시 제출)',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.grey[50],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _businessLicenseUrlFromSignup != null
                ? Image.network(
                    _businessLicenseUrlFromSignup!,
                    fit: BoxFit.cover,
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
                              color: Colors.red,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '이미지 로드 실패',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 32.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '사업자등록증이 없습니다',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '선택사항 - 필요시 업로드',
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
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _companyPhoto = File(image.path);
      });
    }
  }
  
  Future<void> _pickCompanyLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _logoImage = File(image.path);
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    
    if (_selectedCategory == null || _selectedSubcategory == null) {
      _showError('업종과 세부업종을 선택해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // Upload images to Firebase Storage
      String? businessLicenseUrl = _businessLicenseUrlFromSignup; // 회원가입 시 업로드한 URL 사용 (선택적)
      String? logoUrl;
      String? photoUrl;

      // Upload logo if exists
      if (_logoImage != null) {
        try {
          logoUrl = await _uploadImage(
            _logoImage!,
            'company_logos/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        } catch (e) {
          debugPrint('로고 업로드 실패: $e');
          // Continue registration without logo
        }
      }
      
      // Upload company photo if exists
      if (_companyPhoto != null) {
        try {
          photoUrl = await _uploadImage(
            _companyPhoto!,
            'company_photos/${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        } catch (e) {
          debugPrint('회사사진 업로드 실패: $e');
          // Continue registration without photo
        }
      }

      // Validate required fields before saving
      final companyName = _companyNameController.text.trim();
      final ceoName = _ceoNameController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final category = _selectedCategory;
      final subcategory = _selectedSubcategory?.replaceAll('*', '').trim();

      if (companyName.isEmpty || companyName.length < 2) {
        throw Exception('회사명을 2자 이상 입력해주세요.');
      }
      if (ceoName.isEmpty || ceoName.length < 2) {
        throw Exception('대표자명을 2자 이상 입력해주세요.');
      }
      if (phone.isEmpty || phone.length < 10) {
        throw Exception('연락처를 올바르게 입력해주세요.');
      }
      if (address.isEmpty || address.length < 5) {
        throw Exception('주소를 올바르게 입력해주세요.');
      }
      if (category == null || category.isEmpty) {
        throw Exception('업종을 선택해주세요.');
      }
      if (subcategory == null || subcategory.isEmpty) {
        throw Exception('세부업종을 선택해주세요.');
      }

      // Determine if selected subcategory is a 4th level category
      String finalSubcategory = subcategory;
      String? finalSubSubcategory;
      
      final categoryModel = _categories.firstWhere(
        (cat) => cat.title == category,
        orElse: () => CategoryModel(title: '', subcategories: []),
      );
      
      // Check if selected value is a 4th level category
      if (categoryModel.subSubSubcategories != null) {
        for (final entry in categoryModel.subSubSubcategories!.entries) {
          final parentKey = entry.key.replaceAll('*', '').trim();
          final children = entry.value.map((s) => s.replaceAll('*', '').trim()).toList();
          
          if (children.contains(subcategory)) {
            // Selected value is a 4th level category
            finalSubcategory = parentKey;
            finalSubSubcategory = subcategory;
            break;
          }
        }
      }

      // Save company data to Firestore
      final companyData = {
        'userId': currentUser.uid, // This will be mapped to 'id' in the model
        'id': currentUser.uid, // Explicit id field
        'companyName': companyName,
        'businessLicenseImage': businessLicenseUrl,
        'ceoName': ceoName,
        'phone': phone,
        'address': address,
        'detailAddress': _detailAddressController.text.trim(),
        'category': category,
        'subcategory': finalSubcategory,
        'subSubcategory': finalSubSubcategory,
        'website': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        'greeting': _greetingController.text.trim().isEmpty ? null : _greetingController.text.trim(),
        'history': historyItems.map((item) => {
          'year': item['year']?.text.trim() ?? '',
          'content': item['content']?.text.trim() ?? '',
        }).where((item) => item['year']!.isNotEmpty || item['content']!.isNotEmpty).toList(),
        'clients': partnerItems.map((item) => {
          'name': item['name']?.text.trim() ?? '',
          'details': item['details']?.text.trim() ?? '',
        }).where((item) => item['name']!.isNotEmpty || item['details']!.isNotEmpty).toList(),
        'features': _featuresController.text.trim().isEmpty ? null : _featuresController.text.trim(),
        'logo': logoUrl,
        'photo': photoUrl, // Single photo field that model expects
        'photos': photoUrl != null ? [photoUrl] : [], // List of photos for compatibility
        'adPayment': 0.0,
        'isVerified': true,
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint('📝 기업 데이터 저장 시작: ${companyData.keys.toList()}');
      debugPrint('📝 필수 필드 확인: companyName=${companyName.length}자, ceoName=${ceoName.length}자, phone=${phone.length}자, address=${address.length}자');

      // Save to companies collection
      debugPrint('💾 Firestore에 기업 데이터 저장 중...');
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(currentUser.uid)
          .set(companyData, SetOptions(merge: false));
      debugPrint('✅ Firestore에 기업 데이터 저장 완료');

      // Update users collection to mark company registration as complete
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
              'companyRegistered': true,
              'companyRegistrationDate': FieldValue.serverTimestamp(),
            });
      } catch (e) {
        debugPrint('⚠️ users 컬렉션 업데이트 실패 (무시): $e');
        // Continue even if users update fails
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기업회원 등록이 완료되었습니다. 승인까지 1-2일 소요됩니다.')),
        );
        
        context.go(RouteNames.main);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ 기업회원 등록 실패: $e');
      debugPrint('❌ 스택 트레이스: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // 더 구체적인 에러 메시지 제공
        String errorMessage = '등록 중 오류가 발생했습니다';
        if (e.toString().contains('permission-denied')) {
          errorMessage = '권한이 없습니다. 관리자에게 문의해주세요.';
        } else if (e.toString().contains('network')) {
          errorMessage = '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
        } else if (e.toString().contains('invalid-argument')) {
          errorMessage = '입력한 정보를 확인해주세요.';
        } else {
          errorMessage = '등록 중 오류가 발생했습니다: ${e.toString()}';
        }
        
        _showError(errorMessage);
      }
    }
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}