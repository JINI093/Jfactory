import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/views/admin/admin_main.dart';
import 'presentation/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with fir-test-96091 project
  try {
    // 기존 앱이 있으면 삭제
    try {
      await Firebase.app().delete();
    } catch (e) {
      // 앱이 없으면 무시
    }
    
    // fir-test-96091 프로젝트로 초기화 ([DEFAULT] 이름 사용)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCFYUY93SUSMC7ZD9fhsH4YFFOs-3cl-vo',
        appId: '1:468556282634:web:a8c16384daad9e3406d8f3',
        messagingSenderId: '468556282634',
        projectId: 'fir-test-96091',
        authDomain: 'fir-test-96091.firebaseapp.com',
        storageBucket: 'fir-test-96091.firebasestorage.app',
      ),
    );
    debugPrint('✅ Admin App: Firebase initialized successfully with fir-test-96091');
  } catch (e) {
    debugPrint('❌ Admin App: Firebase initialization failed: $e');
  }
  
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: ScreenUtilInit(
        designSize: const Size(1920, 1080), // 웹 데스크톱 기준으로 변경
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: '제작소 Admin',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF1E3A5F),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                ),
              ),
            ),
            home: const AdminMainView(),
          );
        },
      ),
    );
  }
}
