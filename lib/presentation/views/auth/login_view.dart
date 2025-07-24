import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/router/route_names.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '뒤로가기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      
                      // Logo and Title
                      _buildLogoSection(),
                      
                      SizedBox(height: 20.h),
                      
                      // Email Field with Auto Login
                      _buildEmailFieldWithAutoLogin(),
                      
                      SizedBox(height: 8.h),
                      
                      // Password Field
                      _buildInputField(
                        label: '비밀번호',
                        controller: _passwordController,
                        hintText: '비밀번호를 입력해주세요.',
                        isPassword: true,
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // Links Row
                      _buildLinksRow(),
                      
                      SizedBox(height: 15.h),
                      
                      // Social Login Section
                      _buildSocialLoginSection(),
                      
                      SizedBox(height: 15.h),
                    ],
                  ),
                ),
              ),
              
              // Login Button
              _buildLoginButton(),
              
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLogoSection() {
    return Image.asset(
      'assets/icons/main_logo.png',
      width: 300.w,
      height: 150.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image is missing
        return Column(
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Center(
                child: Text(
                  'J',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16.sp),
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

  Widget _buildEmailFieldWithAutoLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '이메일',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    activeColor: const Color(0xFF1E3A5F),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  '자동 로그인',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: '이메일을 입력해주세요.',
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

  Widget _buildLinksRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            // Navigate to find email/password
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '이메일 / 비밀번호 찾기',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            context.go(RouteNames.signup);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '회원가입',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
            activeColor: const Color(0xFF1E3A5F),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '자동 로그인',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey[300],
        ),
        SizedBox(height: 16.h),
        Text(
          'SNS 로그인',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton('assets/icons/google.png', () {
              _handleSocialLogin('google');
            }),
            SizedBox(width: 16.w),
            _buildSocialButton('assets/icons/apple.png', () {
              _handleSocialLogin('apple');
            }),
            SizedBox(width: 16.w),
            _buildSocialButton('assets/icons/kakao.png', () {
              _handleSocialLogin('kakao');
            }),
            SizedBox(width: 16.w),
            _buildSocialButton('assets/icons/naver.png', () {
              _handleSocialLogin('naver');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String assetPath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 24.w,
            height: 24.h,
            errorBuilder: (context, error, stackTrace) {
              // Fallback icons for social buttons
              String provider = assetPath.split('/').last.split('.').first;
              IconData iconData;
              Color iconColor;
              
              switch (provider) {
                case 'google':
                  iconData = Icons.g_mobiledata;
                  iconColor = Colors.red;
                  break;
                case 'apple':
                  iconData = Icons.apple;
                  iconColor = Colors.black;
                  break;
                case 'kakao':
                  iconData = Icons.chat_bubble;
                  iconColor = const Color(0xFFFEE500);
                  break;
                case 'naver':
                  iconData = Icons.navigation;
                  iconColor = const Color(0xFF03C75A);
                  break;
                default:
                  iconData = Icons.login;
                  iconColor = Colors.grey;
              }
              
              return Icon(
                iconData,
                size: 24.w,
                color: iconColor,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _agreeToTerms ? _handleLogin : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 0,
        ),
        child: Text(
          '로그인',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }
    
    _performLogin();
  }

  void _performLogin() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      
      await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (authViewModel.isLoggedIn) {
        context.go(RouteNames.main);
      } else if (authViewModel.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authViewModel.error ?? '로그인에 실패했습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider 로그인은 준비 중입니다.')),
    );
  }
}