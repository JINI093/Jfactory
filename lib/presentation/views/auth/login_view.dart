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
                      
                      SizedBox(height: 8.h),
                      
                      // Password Field
                      _buildInputField(
                        label: '비밀번호',
                        controller: _passwordController,
                        hintText: '비밀번호를 입력해주세요.',
                        isPassword: true,
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Login Button
                      _buildLoginButton(),
                      
                      SizedBox(height: 16.h),
                      
                      // Divider with "또는"
                      _buildDivider(),
                      
                      SizedBox(height: 16.h),
                      
                      // Social Login Buttons
                      _buildSocialButtons(),
                      
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
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.business,
            color: Colors.white,
            size: 40.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          '로그인',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '계정에 로그인하여 서비스를 이용하세요',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailFieldWithAutoLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputField(
          label: '이메일',
          controller: _emailController,
          hintText: '이메일을 입력해주세요.',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '또는',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12.sp,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildSocialButton(
          '구글로 로그인',
          Colors.white,
          Colors.black,
          () => _handleSocialLogin('google'),
        ),
        SizedBox(height: 8.h),
        _buildSocialButton(
          '카카오로 로그인',
          const Color(0xFFFEE500),
          Colors.black,
          () => _handleSocialLogin('kakao'),
        ),
        SizedBox(height: 8.h),
        _buildSocialButton(
          '네이버로 로그인',
          const Color(0xFF03C75A),
          Colors.white,
          () => _handleSocialLogin('naver'),
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String text,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '계정이 없으신가요? ',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            GestureDetector(
              onTap: () => context.go(RouteNames.signup),
              child: Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1E3A5F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _handleForgotPassword,
          child: Text(
            '비밀번호를 잊으셨나요?',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
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