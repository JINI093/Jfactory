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
  bool _autoLogin = false;
  bool _isLoading = false;

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
          onPressed: () => context.go(RouteNames.main),
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
                      
                      SizedBox(height: 16.h),
                      
                      // Password Field
                      _buildInputField(
                        label: '비밀번호',
                        controller: _passwordController,
                        hintText: '비밀번호를 입력해주세요.',
                        isPassword: true,
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      // 이메일 / 비밀번호 찾기
                      _buildFindAccountLinks(),
                      
                      SizedBox(height: 20.h),
                      
                      // Divider with "SNS 로그인"
                      _buildSNSDivider(),
                      
                      SizedBox(height: 16.h),
                      
                      // Social Login Icons
                      _buildSocialIcons(),
                      
                      SizedBox(height: 24.h),
                      
                      // Login Button
                      _buildLoginButton(),
                      
                      SizedBox(height: 24.h),
                      
                      // Bottom Links
                      _buildBottomLinks(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        SizedBox(height: 60.h),
        // J제작소 로고
        Image.asset(
          'assets/icons/logo2.png',
          width: 120.w,
          height: 120.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildEmailFieldWithAutoLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email title with auto-login on same line
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '이메일',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _autoLogin = !_autoLogin;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _autoLogin ? const Color(0xFF1E3A5F) : Colors.grey,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                      color: _autoLogin ? const Color(0xFF1E3A5F) : Colors.transparent,
                    ),
                    child: _autoLogin
                        ? Icon(
                            Icons.check,
                            size: 14.sp,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '자동 로그인',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // Email input field
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: '이메일을 입력해주세요.',
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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

  Widget _buildFindAccountLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _handleForgotPassword,
          child: Text(
            '이메일 / 비밀번호 찾기',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.go(RouteNames.signup),
          child: Text(
            '회원가입',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1E3A5F),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSNSDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'SNS 로그인',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
          'assets/icons/google.png',
          () => _handleSocialLogin('google'),
        ),
        SizedBox(width: 16.w),
        _buildSocialIcon(
          'assets/icons/apple.png',
          () => _handleSocialLogin('apple'),
        ),
        SizedBox(width: 16.w),
        _buildSocialIcon(
          'assets/icons/kakao.png',
          () => _handleSocialLogin('kakao'),
        ),
        SizedBox(width: 16.w),
        _buildSocialIcon(
          'assets/icons/naver.png',
          () => _handleSocialLogin('naver'),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
    String iconPath,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        iconPath,
        width: 36.w,  // 1.5배 크기 (24 * 1.5 = 36)
        height: 36.w,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildBottomLinks() {
    return SizedBox(height: 20.h);
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      context.go(RouteNames.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authViewModel.errorMessage ?? '로그인에 실패했습니다.')),
      );
    }
  }

  void _handleSocialLogin(String provider) async {
    final authViewModel = context.read<AuthViewModel>();
    bool success = false;

    switch (provider) {
      case 'google':
        success = await authViewModel.signInWithGoogle();
        break;
      case 'kakao':
        success = await authViewModel.signInWithKakao();
        break;
      case 'naver':
        success = await authViewModel.signInWithNaver();
        break;
      case 'apple':
        success = await authViewModel.signInWithApple();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$provider 로그인 기능은 준비 중입니다.')),
        );
        return;
    }

    if (success) {
      context.go(RouteNames.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authViewModel.errorMessage ?? '$provider 로그인에 실패했습니다.')),
      );
    }
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('비밀번호 재설정 기능은 준비 중입니다.')),
    );
  }
}