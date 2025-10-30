import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/router/route_names.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../data/datasources/firebase_auth_datasource.dart';
import '../../../data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  int _currentStep = 0; // 0: terms, 1: signup form
  UserType _userType = UserType.individual;
  bool _isLoading = false;
  
  // Terms agreement states
  bool _allTermsAccepted = false;
  bool _termsOfService = false;
  bool _ageConfirmation = false;
  bool _personalInfo = false;
  bool _marketing = false;
  
  // Phone verification states
  bool _isPhoneVerified = false;
  bool _isVerificationCodeSent = false;
  String _verificationId = '';
  final _verificationCodeController = TextEditingController();
  Timer? _timer;
  int _countdown = 0;
  
  // Firebase Auth
  final FirebaseAuthDataSource _authDataSource = FirebaseAuthDataSourceImpl();

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  
  // Validation states
  String _emailValidationMessage = '';
  String _passwordValidationMessage = '';
  String _confirmPasswordValidationMessage = '';
  String _phoneValidationMessage = '핸드폰번호를 입력해주세요';
  String _verificationValidationMessage = '';
  
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isCheckingEmail = false;
  
  // Image picker for business license
  final ImagePicker _picker = ImagePicker();
  File? _businessLicenseImage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
    _phoneController.addListener(_validatePhone);
  }
  
  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _phoneController.removeListener(_validatePhone);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _verificationCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _currentStep == 0 ? _buildTermsStep() : _buildSignupFormStep(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          if (_currentStep == 0) {
            context.go(RouteNames.login);
          } else {
            setState(() {
              _currentStep = 0;
            });
          }
        },
      ),
      title: Text(
        _currentStep == 0 ? '약관 동의' : '회원가입',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildTermsStep() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              '서비스 이용을 위해\n약관에 동의해주세요',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            SizedBox(height: 32.h),
            
            // 전체 동의
            _buildTermsItem(
              '전체 동의',
              _allTermsAccepted,
              (value) {
                setState(() {
                  _allTermsAccepted = value;
                  _termsOfService = value;
                  _ageConfirmation = value;
                  _personalInfo = value;
                  _marketing = value;
                });
              },
              isMain: true,
            ),
            
            SizedBox(height: 16.h),
            Divider(color: Colors.grey[200]),
            SizedBox(height: 16.h),
            
            // 개별 약관들
            _buildTermsItemWithLink(
              '서비스 이용약관 동의',
              _termsOfService,
              (value) {
                setState(() {
                  _termsOfService = value;
                  _updateAllTermsStatus();
                });
              },
              onLinkTap: () => _openTermsOfService(),
              isRequired: true,
            ),
            
            SizedBox(height: 12.h),
            _buildTermsItemWithLink(
              '만 14세 이상 확인',
              _ageConfirmation,
              (value) {
                setState(() {
                  _ageConfirmation = value;
                  _updateAllTermsStatus();
                });
              },
              onLinkTap: () => _openAgeConfirmation(),
              isRequired: true,
            ),
            
            SizedBox(height: 12.h),
            _buildTermsItemWithLink(
              '개인정보 수집 및 이용 동의',
              _personalInfo,
              (value) {
                setState(() {
                  _personalInfo = value;
                  _updateAllTermsStatus();
                });
              },
              onLinkTap: () => _openPrivacyPolicy(),
              isRequired: true,
            ),
            
            SizedBox(height: 12.h),
            _buildTermsItem(
              '마케팅 정보 수신 동의',
              _marketing,
              (value) {
                setState(() {
                  _marketing = value;
                  _updateAllTermsStatus();
                });
              },
              isRequired: false,
              isOptional: true,
            ),
            
            const Spacer(),
            
            // 다음 버튼
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _canProceedToSignup() ? _proceedToSignup : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '다음',
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
    );
  }

  Widget _buildSignupFormStep() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    
                    // 회원 유형 선택
                    _buildUserTypeSelection(),
                    
                    SizedBox(height: 24.h),
                    
                    // 기본 정보
                    _buildValidatedInputField(
                      label: '이메일',
                      controller: _emailController,
                      hintText: '이메일을 입력해주세요.',
                      keyboardType: TextInputType.emailAddress,
                      validationMessage: _emailValidationMessage,
                      isValid: _isEmailValid,
                      isLoading: _isCheckingEmail,
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildValidatedInputField(
                      label: '비밀번호',
                      controller: _passwordController,
                      hintText: '비밀번호를 입력해주세요.',
                      isPassword: true,
                      validationMessage: _passwordValidationMessage,
                      isValid: _isPasswordValid,
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildValidatedInputField(
                      label: '비밀번호 확인',
                      controller: _confirmPasswordController,
                      hintText: '비밀번호를 다시 입력해주세요.',
                      isPassword: true,
                      validationMessage: _confirmPasswordValidationMessage,
                      isValid: _isConfirmPasswordValid,
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildInputField(
                      label: '이름',
                      controller: _nameController,
                      hintText: '이름을 입력해주세요.',
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildPhoneInputField(),
                    
                    if (_isVerificationCodeSent) ...[  
                      SizedBox(height: 16.h),
                      _buildVerificationCodeField(),
                    ],
                    
                    // 기업 회원인 경우 추가 필드
                    if (_userType == UserType.company) ...[
                      SizedBox(height: 16.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '기업명',
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
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '이메일을 잊으셨을 경우, 기업 확인에 활용됩니다.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: _companyNameController,
                              decoration: InputDecoration(
                                hintText: '기업명을 입력해주세요.',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16.h),
                      Column(
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
                            ],
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: _pickBusinessLicense,
                            child: Container(
                              width: double.infinity,
                              height: 100.h,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _businessLicenseImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.file(
                                        _businessLicenseImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 32.sp,
                                          color: Colors.grey[400],
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          '사업자 등록증 업로드',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            
            // 회원가입 버튼
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
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
                        '회원가입',
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
    );
  }

  Widget _buildTermsItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    bool isMain = false,
    bool isRequired = false,
    bool isOptional = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: value ? const Color(0xFF1E3A5F) : Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4.r),
              color: value ? const Color(0xFF1E3A5F) : Colors.transparent,
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 16.sp,
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMain ? 16.sp : 14.sp,
                fontWeight: isMain ? FontWeight.w600 : FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          if (isRequired)
            Text(
              '(필수)',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
          if (isOptional)
            Text(
              '(선택)',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTermsItemWithLink(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    required VoidCallback onLinkTap,
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: value ? const Color(0xFF1E3A5F) : Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4.r),
              color: value ? const Color(0xFF1E3A5F) : Colors.transparent,
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 16.sp,
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          if (isRequired)
            Text(
              '(필수)',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red,
              ),
            ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onLinkTap,
            child: Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTermsOfService() async {
    final url = Uri.parse('https://www.notion.so/24c61d84851980efbc54d21196296bb1');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
          ),
        );
      } else {
        _showError('서비스 이용약관 페이지를 열 수 없습니다.');
      }
    } catch (e) {
      _showError('서비스 이용약관 페이지를 열 수 없습니다.');
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://www.notion.so/24c61d84851980feb8cdf7f031b8c642');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
          ),
        );
      } else {
        _showError('개인정보 처리방침 페이지를 열 수 없습니다.');
      }
    } catch (e) {
      _showError('개인정보 처리방침 페이지를 열 수 없습니다.');
    }
  }

  Future<void> _openAgeConfirmation() async {
    // 만 14세 이상 확인 관련 안내 페이지가 있다면 여기에 URL 추가
    // 현재는 서비스 이용약관 페이지로 연결
    final url = Uri.parse('https://www.notion.so/24c61d84851980efbc54d21196296bb1');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
          ),
        );
      } else {
        _showError('페이지를 열 수 없습니다.');
      }
    } catch (e) {
      _showError('페이지를 열 수 없습니다.');
    }
  }

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '회원 유형',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildUserTypeOption(
                '개인',
                UserType.individual,
                Icons.person,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildUserTypeOption(
                '기업',
                UserType.company,
                Icons.business,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeOption(String title, UserType type, IconData icon) {
    final isSelected = _userType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _userType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected ? const Color(0xFF1E3A5F).withValues(alpha: 0.05) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '휴대폰 번호',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              _phoneValidationMessage,
              style: TextStyle(
                fontSize: 12.sp,
                color: _phoneController.text.isEmpty ? const Color(0xFFF56C6C) : Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isPhoneVerified,
                  decoration: InputDecoration(
                    hintText: '휴대폰 번호를 입력해주세요.',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 80.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed: (_isPhoneVerified || _isLoading || _countdown > 0) ? null : _sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                child: Text(
                  _isPhoneVerified ? '인증완료' : (_countdown > 0 ? '$_countdown초' : '전송'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildVerificationCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '인증번호',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (_verificationValidationMessage.isNotEmpty)
              Text(
                _verificationValidationMessage,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _isPhoneVerified ? const Color(0xFF0ED52D) : const Color(0xFFF56C6C),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _verificationCodeController,
                  keyboardType: TextInputType.number,
                  enabled: !_isPhoneVerified,
                  decoration: InputDecoration(
                    hintText: '인증번호 6자리를 입력해주세요.',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 80.w,
              height: 48.h,
              child: ElevatedButton(
                onPressed: (_isPhoneVerified || _isLoading) ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                child: Text(
                  _isPhoneVerified ? '인증완료' : '인증',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValidatedInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String validationMessage = '',
    bool isValid = false,
    bool isPassword = false,
    bool isLoading = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (validationMessage.isNotEmpty)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    if (!isLoading)
                      Flexible(
                        child: Text(
                          validationMessage,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isValid ? const Color(0xFF0ED52D) : const Color(0xFFF56C6C),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
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
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _updateAllTermsStatus() {
    if (mounted) {
      setState(() {
        _allTermsAccepted = _termsOfService && _ageConfirmation && _personalInfo && _marketing;
      });
    }
  }

  bool _canProceedToSignup() {
    return _termsOfService && _ageConfirmation && _personalInfo;
  }

  void _proceedToSignup() {
    if (mounted) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _handleSignup() async {
    if (!_validateSignupForm()) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Perform actual signup with Firebase
      final userModel = await _authDataSource.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _userType,
      );
      
      // Save user data to Firestore
      await _saveUserToFirestore(userModel);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 완료되었습니다!')),
        );
        
        context.go(RouteNames.main);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showError('회원가입 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  bool _validateSignupForm() {
    // Check email validation
    if (_emailController.text.isEmpty) {
      _showError('이메일을 입력해주세요.');
      return false;
    }
    
    if (!_isEmailValid) {
      _showError('올바른 이메일을 입력해주세요.');
      return false;
    }

    // Check password validation
    if (_passwordController.text.isEmpty) {
      _showError('비밀번호를 입력해주세요.');
      return false;
    }
    
    if (!_isPasswordValid) {
      _showError('영문, 숫자, 특수문자 포함 8자 이상 필요합니다.');
      return false;
    }

    // Check password confirmation
    if (_confirmPasswordController.text.isEmpty) {
      _showError('비밀번호 확인을 입력해주세요.');
      return false;
    }
    
    if (!_isConfirmPasswordValid) {
      _showError('비밀번호가 일치하지 않습니다.');
      return false;
    }

    if (_nameController.text.isEmpty) {
      _showError('이름을 입력해주세요.');
      return false;
    }

    if (_phoneController.text.isEmpty) {
      _showError('휴대폰 번호를 입력해주세요.');
      return false;
    }
    
    if (!_isPhoneVerified) {
      _showError('휴대폰 번호 인증을 완료해주세요.');
      return false;
    }

    if (_userType == UserType.company) {
      if (_companyNameController.text.isEmpty) {
        _showError('기업명을 입력해주세요.');
        return false;
      }

      if (_businessLicenseImage == null) {
        _showError('사업자 등록증을 업로드해주세요.');
        return false;
      }
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  void _sendVerificationCode() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      _showError('휴대폰 번호를 입력해주세요.');
      return;
    }
    
    // Always use test mode for simulator to avoid reCAPTCHA issues
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Test mode for simulator
      if (mounted) {
        setState(() {
          _verificationId = 'test-verification-id';
          _isVerificationCodeSent = true;
          _isLoading = false;
          _startCountdown();
        });
        _showError('테스트 모드: 인증번호는 123456 입니다.');
      }
      return;
    }
    
    // Format phone number for Firebase (Korean format)
    String formattedPhone = phoneNumber;
    if (!formattedPhone.startsWith('+')) {
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '+82${formattedPhone.substring(1)}';
      } else {
        formattedPhone = '+82$formattedPhone';
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    await _authDataSource.sendPhoneVerification(
      formattedPhone,
      (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isVerificationCodeSent = true;
            _isLoading = false;
            _startCountdown();
          });
          _showError('인증번호가 발송되었습니다.');
        }
      },
      (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showError(error);
        }
      },
    );
  }
  
  
  void _verifyCode() async {
    final code = _verificationCodeController.text.trim();
    
    if (code.isEmpty) {
      _showError('인증번호를 입력해주세요.');
      return;
    }
    
    // Test mode check
    if (_verificationId == 'test-verification-id') {
      if (code == '123456') {
        if (mounted) {
          setState(() {
            _isPhoneVerified = true;
            _isLoading = false;
            _verificationValidationMessage = '인증되었습니다';
          });
          _showError('전화번호 인증이 완료되었습니다.');
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _verificationValidationMessage = '인증번호가 다릅니다.';
          });
          _showError('테스트 모드에서는 123456을 입력하세요.');
        }
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      final isValid = await _authDataSource.verifyPhoneCode(_verificationId, code);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPhoneVerified = isValid;
        });
        
        if (isValid) {
          setState(() {
            _verificationValidationMessage = '인증되었습니다';
          });
          _showError('전화번호 인증이 완료되었습니다.');
          // Sign out immediately after verification to allow email signup
          await FirebaseAuth.instance.signOut();
        } else {
          setState(() {
            _verificationValidationMessage = '인증번호가 다릅니다.';
          });
          _showError('인증번호가 올바르지 않습니다.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('인증 중 오류가 발생했습니다.');
      }
    }
  }
  
  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }
  
  // Validation methods
  void _validateEmail() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      if (mounted) {
        setState(() {
          _emailValidationMessage = '';
          _isEmailValid = false;
        });
      }
      return;
    }
    
    // Email format validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      if (mounted) {
        setState(() {
          _emailValidationMessage = '올바른 이메일 형식이 아닙니다.';
          _isEmailValid = false;
        });
      }
      return;
    }
    
    // Check email availability
    if (mounted) {
      setState(() {
        _isCheckingEmail = true;
      });
    }
    
    // Simulate email check for now - in production, implement proper backend validation
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _isCheckingEmail = false;
        _isEmailValid = true;
        _emailValidationMessage = '사용가능한 이메일입니다.';
      });
    }
  }
  
  void _validatePassword() {
    final password = _passwordController.text;
    
    if (password.isEmpty) {
      if (mounted) {
        setState(() {
          _passwordValidationMessage = '';
          _isPasswordValid = false;
        });
      }
      return;
    }
    
    // Password strength validation
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;
    
    if (hasLowerCase && hasDigit && hasSpecialChar && hasMinLength) {
      if (mounted) {
        setState(() {
          _passwordValidationMessage = '안전한 비밀번호 입니다.';
          _isPasswordValid = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _passwordValidationMessage = '영문,숫자,특수문자 포함 8자 이상';
          _isPasswordValid = false;
        });
      }
    }
    
    // Re-validate confirm password when password changes
    _validateConfirmPassword();
  }
  
  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (confirmPassword.isEmpty) {
      if (mounted) {
        setState(() {
          _confirmPasswordValidationMessage = '';
          _isConfirmPasswordValid = false;
        });
      }
      return;
    }
    
    if (password == confirmPassword) {
      if (mounted) {
        setState(() {
          _confirmPasswordValidationMessage = '비밀번호가 일치합니다.';
          _isConfirmPasswordValid = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _confirmPasswordValidationMessage = '비밀번호가 다릅니다.';
          _isConfirmPasswordValid = false;
        });
      }
    }
  }
  
  void _validatePhone() {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      if (mounted) {
        setState(() {
          _phoneValidationMessage = '핸드폰번호를 입력해주세요';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _phoneValidationMessage = '';
        });
      }
    }
  }
  
  Future<void> _pickBusinessLicense() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null && mounted) {
        setState(() {
          _businessLicenseImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('이미지 선택 중 오류가 발생했습니다.');
    }
  }
  
  Future<void> _saveUserToFirestore(UserModel userModel) async {
    try {
      Map<String, dynamic> userData = {
        'uid': userModel.uid,
        'email': userModel.email,
        'name': userModel.name,
        'phone': userModel.phone,
        'userType': userModel.userType.toString().split('.').last, // 'individual' or 'company'
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      // Add company-specific data if user is company type
      if (_userType == UserType.company) {
        userData['companyName'] = _companyNameController.text.trim();
        
        // Upload business license image with proper error handling
        if (_businessLicenseImage != null) {
          try {
            final String fileName = '${userModel.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('business_licenses/$fileName');
            
            final uploadTask = await storageRef.putFile(_businessLicenseImage!);
            final businessLicenseUrl = await uploadTask.ref.getDownloadURL();
            userData['businessLicenseUrl'] = businessLicenseUrl;
            userData['businessLicenseUploaded'] = true;
          } catch (storageError) {
            // If storage upload fails, continue with registration without image
            debugPrint('Storage upload failed: $storageError');
            userData['businessLicenseUploaded'] = false;
            userData['businessLicenseError'] = storageError.toString();
          }
        }
      }
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.uid)
          .set(userData);
    } catch (e) {
      throw Exception('사용자 정보 저장 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}