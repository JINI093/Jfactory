import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../viewmodels/main_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/company_viewmodel.dart';
import '../viewmodels/favorite_viewmodel.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../data/repositories/inquiry_repository_impl.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/company_repository.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/repositories/inquiry_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/usecases/auth/sign_in_with_email.dart';
import '../../domain/usecases/auth/sign_up_user.dart';
import '../../domain/usecases/auth/sign_out_user.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/send_password_reset_email.dart';
import '../../domain/usecases/company/get_companies.dart';
import '../../domain/usecases/company/get_company_by_id.dart';
import '../../domain/usecases/favorite/get_favorite_companies.dart';
import '../../domain/usecases/favorite/toggle_favorite.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Data Sources
    Provider<FirebaseAuthDataSource>(
      create: (_) => FirebaseAuthDataSourceImpl(),
    ),
    Provider<FirestoreDataSource>(
      create: (_) => FirestoreDataSourceImpl(),
    ),
    
    // Repositories
    ProxyProvider2<FirebaseAuthDataSource, FirestoreDataSource, AuthRepository>(
      update: (_, authDataSource, firestoreDataSource, __) => AuthRepositoryImpl(
        authDataSource: authDataSource,
        firestoreDataSource: firestoreDataSource,
      ),
    ),
    ProxyProvider<FirestoreDataSource, CompanyRepository>(
      update: (_, firestoreDataSource, __) => CompanyRepositoryImpl(
        firestoreDataSource: firestoreDataSource,
      ),
    ),
    ProxyProvider<FirestoreDataSource, FavoriteRepository>(
      update: (_, firestoreDataSource, __) => FavoriteRepositoryImpl(
        firestoreDataSource: firestoreDataSource,
      ),
    ),
    Provider<InquiryRepository>(
      create: (_) => InquiryRepositoryImpl(),
    ),
    ProxyProvider<FirestoreDataSource, PostRepository>(
      update: (_, firestoreDataSource, __) => PostRepositoryImpl(firestoreDataSource),
    ),
    Provider<PurchaseRepository>(
      create: (_) => PurchaseRepositoryImpl(),
    ),
    
    // Use Cases
    ProxyProvider<AuthRepository, SignInWithEmailUseCase>(
      update: (_, authRepository, __) => SignInWithEmailUseCase(authRepository),
    ),
    ProxyProvider<AuthRepository, SignUpUserUseCase>(
      update: (_, authRepository, __) => SignUpUserUseCase(authRepository),
    ),
    ProxyProvider<AuthRepository, SignOutUserUseCase>(
      update: (_, authRepository, __) => SignOutUserUseCase(authRepository),
    ),
    ProxyProvider<AuthRepository, GetCurrentUserUseCase>(
      update: (_, authRepository, __) => GetCurrentUserUseCase(authRepository),
    ),
    ProxyProvider<AuthRepository, SendPasswordResetEmailUseCase>(
      update: (_, authRepository, __) => SendPasswordResetEmailUseCase(authRepository),
    ),
    
    // Company Use Cases
    ProxyProvider<CompanyRepository, GetCompaniesUseCase>(
      update: (_, companyRepository, __) => GetCompaniesUseCase(companyRepository),
    ),
    ProxyProvider<CompanyRepository, GetCompanyByIdUseCase>(
      update: (_, companyRepository, __) => GetCompanyByIdUseCase(companyRepository),
    ),
    
    // Favorite Use Cases
    ProxyProvider<FavoriteRepository, GetFavoriteCompaniesUseCase>(
      update: (_, favoriteRepository, __) => GetFavoriteCompaniesUseCase(favoriteRepository),
    ),
    ProxyProvider<FavoriteRepository, ToggleFavoriteUseCase>(
      update: (_, favoriteRepository, __) => ToggleFavoriteUseCase(favoriteRepository),
    ),
    
    // View Models
    ChangeNotifierProxyProvider6<
      SignInWithEmailUseCase,
      SignUpUserUseCase,
      SignOutUserUseCase,
      GetCurrentUserUseCase,
      SendPasswordResetEmailUseCase,
      AuthRepository,
      AuthViewModel
    >(
      create: (context) => AuthViewModel(
        signInWithEmailUseCase: context.read<SignInWithEmailUseCase>(),
        signUpUserUseCase: context.read<SignUpUserUseCase>(),
        signOutUserUseCase: context.read<SignOutUserUseCase>(),
        getCurrentUserUseCase: context.read<GetCurrentUserUseCase>(),
        sendPasswordResetEmailUseCase: context.read<SendPasswordResetEmailUseCase>(),
        authRepository: context.read<AuthRepository>(),
      ),
      update: (context, signInUseCase, signUpUseCase, signOutUseCase, getCurrentUseCase, resetPasswordUseCase, authRepository, previous) => 
        previous ?? AuthViewModel(
          signInWithEmailUseCase: signInUseCase,
          signUpUserUseCase: signUpUseCase,
          signOutUserUseCase: signOutUseCase,
          getCurrentUserUseCase: getCurrentUseCase,
          sendPasswordResetEmailUseCase: resetPasswordUseCase,
          authRepository: authRepository,
        ),
    ),
    
    // Company ViewModel
    ChangeNotifierProxyProvider2<GetCompaniesUseCase, GetCompanyByIdUseCase, CompanyViewModel>(
      create: (context) => CompanyViewModel(
        getCompaniesUseCase: context.read<GetCompaniesUseCase>(),
        getCompanyByIdUseCase: context.read<GetCompanyByIdUseCase>(),
      ),
      update: (context, getCompaniesUseCase, getCompanyByIdUseCase, previous) =>
        previous ?? CompanyViewModel(
          getCompaniesUseCase: getCompaniesUseCase,
          getCompanyByIdUseCase: getCompanyByIdUseCase,
        ),
    ),
    
    // Main ViewModel
    ChangeNotifierProxyProvider<GetCompaniesUseCase, MainViewModel>(
      create: (context) => MainViewModel(
        getCompaniesUseCase: context.read<GetCompaniesUseCase>(),
      ),
      update: (context, getCompaniesUseCase, previous) =>
        previous ?? MainViewModel(
          getCompaniesUseCase: getCompaniesUseCase,
        ),
    ),
    
    // Favorite ViewModel
    ChangeNotifierProxyProvider2<GetFavoriteCompaniesUseCase, ToggleFavoriteUseCase, FavoriteViewModel>(
      create: (context) => FavoriteViewModel(
        getFavoriteCompaniesUseCase: context.read<GetFavoriteCompaniesUseCase>(),
        toggleFavoriteUseCase: context.read<ToggleFavoriteUseCase>(),
      ),
      update: (context, getFavoriteCompaniesUseCase, toggleFavoriteUseCase, previous) =>
        previous ?? FavoriteViewModel(
          getFavoriteCompaniesUseCase: getFavoriteCompaniesUseCase,
          toggleFavoriteUseCase: toggleFavoriteUseCase,
        ),
    ),
  ];
  
  AppProviders._();
}