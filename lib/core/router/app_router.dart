import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../presentation/views/splash/splash_view.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/signup_view.dart';
import '../../presentation/views/main/main_view.dart';
import '../../presentation/views/company/company_detail_view.dart';
import '../../presentation/views/category/category_detail_view.dart';
import '../../presentation/views/post/premium_post_detail_view.dart';
import '../../presentation/views/company/company_page_view.dart';
import '../../presentation/views/favorites/favorites_view.dart';
import '../../presentation/views/profile/profile_view.dart';
import '../../presentation/views/advertisement/advertisement_registration_view.dart';

class AppRouter {
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
    ],
  );
}