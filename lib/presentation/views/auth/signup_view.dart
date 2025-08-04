import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../domain/entities/user_entity.dart';

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

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _businessLicenseController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _businessLicenseController.dispose();
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
            _buildTermsItem(
              '서비스 이용약관 동의',
              _termsOfService,
              (value) {
                setState(() {
                  _termsOfService = value;
                  _updateAllTermsStatus();
                });
              },
              isRequired: true,
            ),
            
            SizedBox(height: 12.h),
            _buildTermsItem(
              '만 14세 이상 확인',
              _ageConfirmation,
              (value) {
                setState(() {
                  _ageConfirmation = value;
                  _updateAllTermsStatus();
                });
              },
              isRequired: true,
            ),
            
            SizedBox(height: 12.h),
            _buildTermsItem(
              '개인정보 수집 및 이용 동의',
              _personalInfo,
              (value) {
                setState(() {
                  _personalInfo = value;
                  _updateAllTermsStatus();
                });
              },
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
                    _buildInputField(
                      label: '이메일',
                      controller: _emailController,
                      hintText: '이메일을 입력해주세요.',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildInputField(
                      label: '비밀번호',
                      controller: _passwordController,
                      hintText: '비밀번호를 입력해주세요.',
                      isPassword: true,
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildInputField(
                      label: '비밀번호 확인',
                      controller: _confirmPasswordController,
                      hintText: '비밀번호를 다시 입력해주세요.',
                      isPassword: true,
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildInputField(
                      label: '이름',
                      controller: _nameController,
                      hintText: '이름을 입력해주세요.',
                    ),
                    
                    SizedBox(height: 16.h),
                    _buildInputField(
                      label: '휴대폰 번호',
                      controller: _phoneController,
                      hintText: '휴대폰 번호를 입력해주세요.',
                      keyboardType: TextInputType.phone,
                    ),
                    
                    // 기업 회원인 경우 추가 필드
                    if (_userType == UserType.company) ...[
                      SizedBox(height: 16.h),
                      _buildInputField(
                        label: '회사명',
                        controller: _companyNameController,
                        hintText: '회사명을 입력해주세요.',
                      ),
                      
                      SizedBox(height: 16.h),
                      _buildInputField(
                        label: '사업자 등록번호',
                        controller: _businessLicenseController,
                        hintText: '사업자 등록번호를 입력해주세요.',
                        keyboardType: TextInputType.number,
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
          if (!isMain)
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Colors.grey,
            ),
        ],
      ),
    );
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
          color: isSelected ? const Color(0xFF1E3A5F).withOpacity(0.05) : Colors.white,
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
    setState(() {
      _allTermsAccepted = _termsOfService && _ageConfirmation && _personalInfo && _marketing;
    });
  }

  bool _canProceedToSignup() {
    return _termsOfService && _ageConfirmation && _personalInfo;
  }

  void _proceedToSignup() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _handleSignup() {
    if (!_validateSignupForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual signup logic
    // For now, just simulate signup and navigate to main
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다!')),
      );
      
      context.go(RouteNames.main);
    });
  }

  bool _validateSignupForm() {
    if (_emailController.text.isEmpty) {
      _showError('이메일을 입력해주세요.');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showError('비밀번호를 입력해주세요.');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
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

    if (_userType == UserType.company) {
      if (_companyNameController.text.isEmpty) {
        _showError('회사명을 입력해주세요.');
        return false;
      }

      if (_businessLicenseController.text.isEmpty) {
        _showError('사업자 등록번호를 입력해주세요.');
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
}