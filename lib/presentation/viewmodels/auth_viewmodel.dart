import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/sign_in_with_email.dart';
import '../../domain/usecases/auth/sign_up_user.dart';
import '../../domain/usecases/auth/sign_out_user.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/send_password_reset_email.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error
}

class AuthViewModel extends ChangeNotifier {
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpUserUseCase _signUpUserUseCase;
  final SignOutUserUseCase _signOutUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;
  final AuthRepository _authRepository;

  AuthViewModel({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpUserUseCase signUpUserUseCase,
    required SignOutUserUseCase signOutUserUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase,
    required AuthRepository authRepository,
  })  : _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpUserUseCase = signUpUserUseCase,
        _signOutUserUseCase = signOutUserUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _sendPasswordResetEmailUseCase = sendPasswordResetEmailUseCase,
        _authRepository = authRepository {
    _init();
  }

  // 상태 변수들
  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // 회원가입 폼 상태
  UserType _selectedUserType = UserType.individual;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  // Getters
  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  UserType get selectedUserType => _selectedUserType;
  bool get termsAccepted => _termsAccepted;
  bool get privacyAccepted => _privacyAccepted;
  bool get allTermsAccepted => _termsAccepted && _privacyAccepted;

  // 초기화
  void _init() {
    // 인증 상태 변화 구독
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });

    // 현재 사용자 확인
    checkCurrentUser();
  }

  // 현재 사용자 확인
  Future<void> checkCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _getCurrentUserUseCase();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 이메일 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _status = AuthStatus.authenticating;
      notifyListeners();

      final params = SignInWithEmailParams(
        email: email.trim(),
        password: password,
      );

      final user = await _signInWithEmailUseCase(params);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    required String phone,
    String? companyName,
    String? businessLicense,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final params = SignUpUserParams(
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
        name: name.trim(),
        phone: phone.trim(),
        userType: _selectedUserType,
        companyName: companyName?.trim(),
        businessLicense: businessLicense?.trim(),
      );

      final user = await _signUpUserUseCase(params);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _signOutUserUseCase();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 비밀번호 재설정 이메일 전송
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _sendPasswordResetEmailUseCase(email.trim());
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 소셜 로그인 (구글)
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _status = AuthStatus.authenticating;
      notifyListeners();

      final user = await _authRepository.signInWithGoogle();
      _currentUser = user;
      _status = AuthStatus.authenticated;
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 소셜 로그인 (애플)
  Future<bool> signInWithApple() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _status = AuthStatus.authenticating;
      notifyListeners();

      // TODO: Apple Sign-In 구현
      throw UnimplementedError('Apple 로그인은 아직 구현되지 않았습니다.');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 소셜 로그인 (카카오)
  Future<bool> signInWithKakao() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _status = AuthStatus.authenticating;
      notifyListeners();

      // TODO: Kakao Sign-In 구현
      throw UnimplementedError('카카오 로그인은 아직 구현되지 않았습니다.');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 소셜 로그인 (네이버)
  Future<bool> signInWithNaver() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _status = AuthStatus.authenticating;
      notifyListeners();

      // TODO: Naver Sign-In 구현
      throw UnimplementedError('네이버 로그인은 아직 구현되지 않았습니다.');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 타입 변경
  void setUserType(UserType type) {
    _selectedUserType = type;
    notifyListeners();
  }

  // 약관 동의 상태 변경
  void setTermsAccepted(bool value) {
    _termsAccepted = value;
    notifyListeners();
  }

  void setPrivacyAccepted(bool value) {
    _privacyAccepted = value;
    notifyListeners();
  }

  void setAllTermsAccepted(bool value) {
    _termsAccepted = value;
    _privacyAccepted = value;
    notifyListeners();
  }

  // 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null 
          ? AuthStatus.authenticated 
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}