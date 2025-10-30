import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
// Google Maps는 별도 초기화 불필요
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/app_providers.dart';
import 'utils/kakao_key_hash_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dotenv
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ dotenv (.env) 파일 로드 성공');
  } catch (e) {
    debugPrint('❌ dotenv 로드 실패: $e');
    // Continue execution even if dotenv fails to load
  }
  
  // Initialize Firebase with duplicate check
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase Core initialized successfully');
    }
  } catch (e) {
    // Firebase is already initialized
    debugPrint('Firebase already initialized: $e');
  }
  
  // Initialize Firebase Storage
  try {
    final storage = FirebaseStorage.instance;
    // Set timeouts
    storage.setMaxOperationRetryTime(const Duration(seconds: 10));
    storage.setMaxDownloadRetryTime(const Duration(seconds: 10));
    storage.setMaxUploadRetryTime(const Duration(seconds: 10));
    debugPrint('✅ Firebase Storage initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase Storage initialization failed: $e');
  }
  
  // Initialize Kakao SDK
  KakaoSdk.init(
    nativeAppKey: 'a22df9f48c7bd192fa4cc21ee0e8f923',
    javaScriptAppKey: 'a22df9f48c7bd192fa4cc21ee0e8f923',
  );
  
  // 키해시 정보 출력 (카카오 로그인 설정용)
  try {
    await KakaoKeyHashHelper.printKeyHash();
  } catch (e) {
    debugPrint('키해시 출력 실패: $e');
  }
  
  // Naver Login initialization is handled by the plugin automatically
  
  // Initialize Google Mobile Ads SDK with try-catch
  try {
    await MobileAds.instance.initialize();
    debugPrint('✅ Google Mobile Ads SDK initialized successfully');
  } catch (e) {
    debugPrint('❌ Google Mobile Ads SDK initialization failed: $e');
    // Continue app execution even if AdMob fails
  }
  
  // Google Maps는 자동으로 초기화됨
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Vendor Ads',
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}