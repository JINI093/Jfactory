import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'route_names.dart';
import '../../presentation/views/splash/splash_view.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/signup_view.dart';
import '../../presentation/views/main/main_view.dart';
import '../../presentation/views/company/company_detail_view.dart';
import '../../presentation/views/category/category_detail_view.dart';
import '../../presentation/views/category/subcategory_detail_view.dart';
import '../../presentation/views/post/premium_post_detail_view.dart';
import '../../presentation/views/company/company_page_view.dart';
import '../../presentation/views/favorites/favorites_view.dart';
import '../../presentation/views/profile/profile_view.dart';
import '../../presentation/views/advertisement/advertisement_registration_view.dart';
import '../../presentation/views/advertisement/post_registration_view.dart';
import '../../presentation/views/company/company_registration_view.dart';
import '../../presentation/views/purchase/ad_purchase_view.dart';
import '../../presentation/views/inquiry/inquiry_submission_view.dart';
import '../../presentation/views/admin/admin_main.dart';
import '../../presentation/viewmodels/auth_viewmodel.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: RouteNames.splash,
      redirect: (context, state) {
        final authViewModel = context.read<AuthViewModel>();
        final isLoggedIn = authViewModel.currentUser != null;
        final isLoggingIn = state.matchedLocation == RouteNames.login || 
                           state.matchedLocation == RouteNames.signup;
        
        // If not logged in and trying to access protected routes
        if (!isLoggedIn && !isLoggingIn && state.matchedLocation != RouteNames.splash) {
          return RouteNames.login;
        }
        
        // If logged in and trying to access auth routes
        if (isLoggedIn && isLoggingIn) {
          return RouteNames.main;
        }
        
        return null; // No redirect needed
      },
      routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: RouteNames.main,
        name: 'main',
        builder: (context, state) => const MainView(),
      ),
      GoRoute(
        path: RouteNames.companyDetail,
        name: 'company_detail',
        builder: (context, state) {
          final companyId = state.pathParameters['id']!;
          return CompanyDetailView(companyId: companyId);
        },
      ),
      GoRoute(
        path: RouteNames.categoryDetail,
        name: 'category_detail',
        builder: (context, state) {
          final categoryTitle = state.pathParameters['categoryTitle']!;
          return CategoryDetailView(categoryTitle: categoryTitle);
        },
      ),
      GoRoute(
        path: RouteNames.subcategoryDetail,
        name: 'subcategory_detail',
        builder: (context, state) {
          final categoryTitle = state.pathParameters['categoryTitle']!;
          final subcategoryTitle = state.pathParameters['subcategoryTitle']!;
          return SubcategoryDetailView(
            categoryTitle: categoryTitle,
            subcategoryTitle: subcategoryTitle,
          );
        },
      ),
      GoRoute(
        path: RouteNames.premiumPostDetail,
        name: 'premium_post_detail',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PremiumPostDetailView(postId: postId);
        },
      ),
      GoRoute(
        path: RouteNames.companyPage,
        name: 'company_page',
        builder: (context, state) {
          final companyId = state.pathParameters['companyId']!;
          return CompanyPageView(companyId: companyId);
        },
      ),
      GoRoute(
        path: RouteNames.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesView(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: RouteNames.advertisementRegistration,
        name: 'advertisement_registration',
        builder: (context, state) => const AdvertisementRegistrationView(),
      ),
      GoRoute(
        path: RouteNames.companyRegistration,
        name: 'company_registration',
        builder: (context, state) => const CompanyRegistrationView(),
      ),
      GoRoute(
        path: RouteNames.postRegistration,
        name: 'post_registration',
        builder: (context, state) => const PostRegistrationView(),
      ),
      GoRoute(
        path: '/ad-purchase',
        name: 'ad_purchase',
        builder: (context, state) => const AdPurchaseView(),
      ),
      GoRoute(
        path: '/inquiry-submission',
        name: 'inquiry_submission',
        builder: (context, state) => const InquirySubmissionView(),
      ),
      GoRoute(
        path: RouteNames.adminMain,
        name: 'admin_main',
        builder: (context, state) => const AdminMainView(),
      ),
      // Add error handling route
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) {
          final error = state.extra as String? ?? '알 수 없는 오류가 발생했습니다.';
          return Scaffold(
            appBar: AppBar(
              title: const Text('오류'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(RouteNames.main),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.main),
                    child: const Text('메인으로 돌아가기'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ],
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('404 - 페이지를 찾을 수 없습니다'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(RouteNames.main),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  '요청하신 페이지를 찾을 수 없습니다.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'URL: ${state.uri}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(RouteNames.main),
                  child: const Text('메인으로 돌아가기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Static router without auth guards
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: RouteNames.main,
        name: 'main',
        builder: (context, state) => const MainView(),
      ),
      GoRoute(
        path: RouteNames.companyDetail,
        name: 'company_detail',
        builder: (context, state) {
          final companyId = state.pathParameters['id']!;
          return CompanyDetailView(companyId: companyId);
        },
      ),
      GoRoute(
        path: RouteNames.categoryDetail,
        name: 'category_detail',
        builder: (context, state) {
          final categoryTitle = state.pathParameters['categoryTitle']!;
          return CategoryDetailView(categoryTitle: categoryTitle);
        },
      ),
      GoRoute(
        path: RouteNames.subcategoryDetail,
        name: 'subcategory_detail',
        builder: (context, state) {
          final categoryTitle = state.pathParameters['categoryTitle']!;
          final subcategoryTitle = state.pathParameters['subcategoryTitle']!;
          return SubcategoryDetailView(
            categoryTitle: categoryTitle,
            subcategoryTitle: subcategoryTitle,
          );
        },
      ),
      GoRoute(
        path: RouteNames.premiumPostDetail,
        name: 'premium_post_detail',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PremiumPostDetailView(postId: postId);
        },
      ),
      GoRoute(
        path: RouteNames.companyPage,
        name: 'company_page',
        builder: (context, state) {
          final companyId = state.pathParameters['companyId']!;
          return CompanyPageView(companyId: companyId);
        },
      ),
      GoRoute(
        path: RouteNames.favorites,
        name: 'favorites',
        builder: (context, state) => const FavoritesView(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: RouteNames.advertisementRegistration,
        name: 'advertisement_registration',
        builder: (context, state) => const AdvertisementRegistrationView(),
      ),
      GoRoute(
        path: RouteNames.companyRegistration,
        name: 'company_registration',
        builder: (context, state) => const CompanyRegistrationView(),
      ),
      GoRoute(
        path: RouteNames.postRegistration,
        name: 'post_registration',
        builder: (context, state) => const PostRegistrationView(),
      ),
      GoRoute(
        path: '/ad-purchase',
        name: 'ad_purchase',
        builder: (context, state) => const AdPurchaseView(),
      ),
      GoRoute(
        path: '/inquiry-submission',
        name: 'inquiry_submission',
        builder: (context, state) => const InquirySubmissionView(),
      ),
      GoRoute(
        path: RouteNames.adminMain,
        name: 'admin_main',
        builder: (context, state) => const AdminMainView(),
      ),
    ],
  );
}