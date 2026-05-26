import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    
    // Navigate after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(RouteNames.main);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 이미지 크기를 화면 크기의 90%로 설정 (너비와 높이 중 작은 값 기준)
    final minScreenSize = screenWidth < screenHeight ? screenWidth : screenHeight;
    final imageSize = minScreenSize * 0.9;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash/@splash.png',
          fit: BoxFit.contain,
          width: imageSize,
          height: imageSize,
        ),
      ),
    );
  }
}