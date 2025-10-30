import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'presentation/views/admin/admin_main.dart';
import 'presentation/views/admin/user_management_view.dart';
import 'presentation/views/admin/post_management_view.dart';
import 'presentation/views/admin/post_registration_view.dart';
import 'presentation/views/admin/ad_management_view.dart';
import 'presentation/views/admin/inquiry_management_view.dart';
import 'presentation/providers/app_providers.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Vendor Ads Admin',
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
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
            routes: {
              '/user-management': (context) => const UserManagementView(),
              '/post-management': (context) => const PostManagementView(),
              '/post-registration': (context) => const PostRegistrationView(),
              '/ad-management': (context) => const AdManagementView(),
              '/inquiry-management': (context) => const InquiryManagementView(),
            },
          );
        },
      ),
    );
  }
}
