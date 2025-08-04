import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/entities/user_entity.dart';

enum SplashStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error
}

class SplashViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  
  SplashViewModel({
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _getCurrentUserUseCase = getCurrentUserUseCase;

  // 상태 변수들
  SplashStatus _status = SplashStatus.initial;
  bool _isInitialized = false;
  String? _errorMessage;
  UserEntity? _currentUser;
  
  // Getters
  SplashStatus get status => _status;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  bool get shouldNavigateToHome => _status == SplashStatus.authenticated;
  bool get shouldNavigateToLogin => _status == SplashStatus.unauthenticated;
  
  // 앱 초기화
  Future<void> initializeApp() async {
    try {
      _status = SplashStatus.loading;
      notifyListeners();
      
      // 스플래시 화면 최소 표시 시간
      await Future.delayed(const Duration(seconds: 2));
      
      // Firebase는 이미 main.dart에서 초기화됨
      await _checkFirebaseInitialization();
      
      // 자동 로그인 체크
      await _checkAuthenticationStatus();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _status = SplashStatus.error;
      _errorMessage = '앱 초기화 실패: ${e.toString()}';
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  // Firebase 초기화 확인
  Future<void> _checkFirebaseInitialization() async {
    try {
      // Firebase가 이미 초기화되었는지 확인
      final apps = Firebase.apps;
      if (apps.isEmpty) {
        throw Exception('Firebase가 초기화되지 않았습니다.');
      }
    } catch (e) {
      throw Exception('Firebase 초기화 확인 실패: ${e.toString()}');
    }
  }
  
  // 인증 상태 확인
  Future<void> _checkAuthenticationStatus() async {
    try {
      // 현재 사용자 확인
      final user = await _getCurrentUserUseCase();
      
      if (user != null) {
        _currentUser = user;
        _status = SplashStatus.authenticated;
      } else {
        _status = SplashStatus.unauthenticated;
      }
    } catch (e) {
      // 인증 확인 실패 시 로그인 화면으로
      _status = SplashStatus.unauthenticated;
      _errorMessage = '인증 상태 확인 실패: ${e.toString()}';
    }
  }
  
  // 재시도
  Future<void> retry() async {
    _status = SplashStatus.initial;
    _isInitialized = false;
    _errorMessage = null;
    _currentUser = null;
    notifyListeners();
    
    await initializeApp();
  }
  
  // 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
}