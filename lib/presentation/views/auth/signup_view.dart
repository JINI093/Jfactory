import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../core/router/route_names.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  int _currentStep = 0; // 0: terms, 1: signup form with user type selection
  String _userType = 'individual'; // 'individual' or 'corporate'
  
  // Terms agreement states
  bool _allTermsAccepted = false;
  bool _termsOfService = false;
  bool _ageConfirmation = false;
  bool _personalInfo = false;
  bool _marketing = false;

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _companyNameController = TextEditingController();
  
  // Validation states
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordConfirmValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void _updateAllTermsAccepted() {
    setState(() {
      _allTermsAccepted = _termsOfService && _ageConfirmation && _personalInfo;
    });
  }

  void _proceedToSignupForm() {
    if (_allTermsAccepted) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _selectUserType(String type) {
    setState(() {
      _userType = type;
    });
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
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              context.go(RouteNames.login);
            }
          },
        ),
        title: Text(
          '뒤로가기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildTermsAgreementView();
      case 1:
        return _buildSignupFormView();
      default:
        return _buildTermsAgreementView();
    }
  }

  Widget _buildTermsAgreementView() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  '이용약관 동의',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30.h),
                
                // All terms agreement
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: Checkbox(
                          value: _allTermsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _allTermsAccepted = value ?? false;
                              _termsOfService = _allTermsAccepted;
                              _ageConfirmation = _allTermsAccepted;
                              _personalInfo = _allTermsAccepted;
                              _marketing = _allTermsAccepted;
                            });
                          },
                          fillColor: WidgetStateProperty.all(Colors.white),
                          checkColor: const Color(0xFF1E3A5F),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '이용약관 전체 동의',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                // Individual terms
                _buildTermItem(
                  '만 14세 이상입니다. (필수)',
                  _ageConfirmation,
                  (value) {
                    setState(() {
                      _ageConfirmation = value ?? false;
                      _updateAllTermsAccepted();
                    });
                  },
                ),
                
                SizedBox(height: 16.h),
                
                _buildTermItem(
                  '이용약관 (필수)',
                  _termsOfService,
                  (value) {
                    setState(() {
                      _termsOfService = value ?? false;
                      _updateAllTermsAccepted();
                    });
                  },
                  hasArrow: true,
                ),
                
                SizedBox(height: 16.h),
                
                _buildTermItem(
                  '개인정보 수집 및 이용 동의 (필수)',
                  _personalInfo,
                  (value) {
                    setState(() {
                      _personalInfo = value ?? false;
                      _updateAllTermsAccepted();
                    });
                  },
                  hasArrow: true,
                ),
                
                SizedBox(height: 16.h),
                
                _buildTermItem(
                  '마케팅 정보 수신동의 (선택)',
                  _marketing,
                  (value) {
                    setState(() {
                      _marketing = value ?? false;
                    });
                  },
                  hasArrow: true,
                ),
              ],
            ),
          ),
        ),
        
        // Next button
        Padding(
          padding: EdgeInsets.all(24.w),
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _allTermsAccepted ? _proceedToSignupForm : null,
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
        ),
      ],
    );
  }

  Widget _buildTermItem(String title, bool value, Function(bool?) onChanged, {bool hasArrow = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.r),
              ),
              activeColor: const Color(0xFF1E3A5F),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
          if (hasArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey[400],
            ),
        ],
      ),
    );
  }

  Widget _buildSignupFormView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30.h),
                
                // User type selection buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectUserType('individual'),
                        child: Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: _userType == 'individual' ? const Color(0xFF1E3A5F) : Colors.white,
                            border: Border.all(color: _userType == 'individual' ? const Color(0xFF1E3A5F) : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '일반회원',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: _userType == 'individual' ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectUserType('corporate'),
                        child: Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: _userType == 'corporate' ? const Color(0xFF1E3A5F) : Colors.white,
                            border: Border.all(color: _userType == 'corporate' ? const Color(0xFF1E3A5F) : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '기업회원',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: _userType == 'corporate' ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 30.h),
                
                // Form fields based on user type
                _buildFormField('이메일', _emailController, '이메일을 입력해주세요', keyboardType: TextInputType.emailAddress),
                SizedBox(height: 16.h),
                _buildFormField('비밀번호', _passwordController, '비밀번호를 입력해주세요', isPassword: true),
                SizedBox(height: 16.h),
                _buildFormField('비밀번호 확인', _confirmPasswordController, '비밀번호를 다시 입력해주세요', isPassword: true),
                SizedBox(height: 16.h),
                
                if (_userType == 'individual') ...[
                  _buildFormField('이름', _nameController, '이름을 입력해주세요'),
                  SizedBox(height: 16.h),
                ],
                
                _buildFormField('핸드폰 번호', _phoneController, '핸드폰 번호를 입력해주세요', keyboardType: TextInputType.phone),
                SizedBox(height: 16.h),
                _buildFormField('인증번호', _verificationCodeController, '인증번호를 입력해주세요'),
                
                if (_userType == 'corporate') ...[
                  SizedBox(height: 16.h),
                  _buildFormField('기업명', _companyNameController, '기업명을 입력해주세요'),
                  SizedBox(height: 16.h),
                  _buildFileUploadField(),
                ],
                
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
        
        // Signup button
        Padding(
          padding: EdgeInsets.all(24.w),
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                '가입하기',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildFormField(String label, TextEditingController controller, String hintText, {
    bool isPassword = false,
    TextInputType? keyboardType,
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
                color: Colors.black87,
              ),
            ),
            // Validation message - only show when valid
            if ((label == '이메일' && _isEmailValid)) ...[
              SizedBox(width: 8.w),
              Text(
                '사용 가능한 이메일입니다.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                ),
              ),
            ],
            if ((label == '비밀번호' && _isPasswordValid)) ...[
              SizedBox(width: 8.w),
              Text(
                '안전한 비밀번호 입니다.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                ),
              ),
            ],
            if ((label == '비밀번호 확인' && _isPasswordConfirmValid)) ...[
              SizedBox(width: 8.w),
              Text(
                '비밀번호가 일치합니다.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16.sp),
          onChanged: (value) {
            _validateField(label, value);
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: const Color(0xFFEFF5FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(
                color: Color(0xFF1E3A5F),
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사업자등록증',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5FF),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32.sp,
                  color: Colors.grey[500],
                ),
                SizedBox(height: 8.h),
                Text(
                  '이미지를 업로드하세요',
                  style: TextStyle(
                    fontSize: 14.sp,
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
  
  void _validateField(String label, String value) {
    setState(() {
      switch (label) {
        case '이메일':
          _isEmailValid = value.isNotEmpty && value.contains('@') && value.contains('.');
          break;
        case '비밀번호':
          _isPasswordValid = value.length >= 6;
          break;
        case '비밀번호 확인':
          _isPasswordConfirmValid = value.isNotEmpty && value == _passwordController.text;
          break;
      }
    });
  }

  void _handleSignup() {
    // Handle signup logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입이 완료되었습니다.')),
    );
    
    // Navigate back to login or main
    context.go(RouteNames.login);
  }
}