import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../viewmodels/main_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/sign_in_with_email.dart';
import '../../domain/usecases/auth/sign_up_user.dart';
import '../../domain/usecases/auth/sign_out_user.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/send_password_reset_email.dart';

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
    
    ChangeNotifierProvider(create: (_) => MainViewModel()),
  ];
  
  AppProviders._();
}