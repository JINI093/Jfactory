import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreDataSource _firestoreDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required FirestoreDataSource firestoreDataSource,
  })  : _authDataSource = authDataSource,
        _firestoreDataSource = firestoreDataSource;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await _authDataSource.getCurrentUser();
      if (userModel == null) return null;

      // Firestore에서 완전한 사용자 정보 가져오기
      final completeUserModel = await _firestoreDataSource.getUser(userModel.uid);
      return completeUserModel?.toEntity() ?? userModel.toEntity();
    } catch (e) {
      throw Exception('현재 사용자 조회 중 오류 발생: $e');
    }
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final userModel = await _authDataSource.signInWithEmail(email, password);
      
      // Firestore에서 완전한 사용자 정보 가져오기
      final completeUserModel = await _firestoreDataSource.getUser(userModel.uid);
      return completeUserModel?.toEntity() ?? userModel.toEntity();
    } catch (e) {
      throw Exception('로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final userModel = await _authDataSource.signInWithGoogle();
      
      // Firestore에서 기존 사용자 정보 확인
      final existingUser = await _firestoreDataSource.getUser(userModel.uid);
      
      if (existingUser != null) {
        // 기존 사용자인 경우
        return existingUser.toEntity();
      } else {
        // 새로운 사용자인 경우 Firestore에 저장
        await _firestoreDataSource.createUser(userModel);
        return userModel.toEntity();
      }
    } catch (e) {
      throw Exception('구글 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<UserEntity> signInWithKakao() async {
    try {
      final userModel = await _authDataSource.signInWithKakao();
      
      // Firestore에서 기존 사용자 정보 확인
      final existingUser = await _firestoreDataSource.getUser(userModel.uid);
      
      if (existingUser != null) {
        // 기존 사용자인 경우
        return existingUser.toEntity();
      } else {
        // 새로운 사용자인 경우 Firestore에 저장
        await _firestoreDataSource.createUser(userModel);
        return userModel.toEntity();
      }
    } catch (e) {
      throw Exception('카카오 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<UserEntity> signInWithNaver() async {
    try {
      final userModel = await _authDataSource.signInWithNaver();
      
      // Firestore에서 기존 사용자 정보 확인
      final existingUser = await _firestoreDataSource.getUser(userModel.uid);
      
      if (existingUser != null) {
        // 기존 사용자인 경우
        return existingUser.toEntity();
      } else {
        // 새로운 사용자인 경우 Firestore에 저장
        await _firestoreDataSource.createUser(userModel);
        return userModel.toEntity();
      }
    } catch (e) {
      throw Exception('네이버 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<UserEntity> signInWithApple() async {
    try {
      final userModel = await _authDataSource.signInWithApple();
      
      // Firestore에서 기존 사용자 정보 확인
      final existingUser = await _firestoreDataSource.getUser(userModel.uid);
      
      if (existingUser != null) {
        // 기존 사용자인 경우
        return existingUser.toEntity();
      } else {
        // 새로운 사용자인 경우 Firestore에 저장
        await _firestoreDataSource.createUser(userModel);
        return userModel.toEntity();
      }
    } catch (e) {
      throw Exception('애플 로그인 중 오류 발생: $e');
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
    String? companyName,
    String? businessLicense,
  }) async {
    try {
      // Firebase Auth에 사용자 생성
      final userModel = await _authDataSource.signUpWithEmail(
        email,
        password,
        name,
        phone,
        userType,
      );

      // 완전한 사용자 정보 생성
      final completeUserModel = userModel.copyWith(
        companyName: companyName,
        businessLicense: businessLicense,
      );

      // Firestore에 사용자 정보 저장
      await _firestoreDataSource.createUser(completeUserModel);

      return completeUserModel.toEntity();
    } catch (e) {
      throw Exception('회원가입 중 오류 발생: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDataSource.signOut();
    } catch (e) {
      throw Exception('로그아웃 중 오류 발생: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authDataSource.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception('비밀번호 재설정 이메일 전송 중 오류 발생: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      
      // Firebase Auth 프로필 업데이트
      await _authDataSource.updateUserProfile(userModel);
      
      // Firestore 사용자 정보 업데이트
      await _firestoreDataSource.updateUser(userModel);
    } catch (e) {
      throw Exception('사용자 프로필 업데이트 중 오류 발생: $e');
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      
      try {
        // Firestore에서 완전한 사용자 정보 가져오기
        final userModel = await _firestoreDataSource.getUser(user.uid);
        return userModel?.toEntity();
      } catch (e) {
        // Firestore 조회 실패 시 Firebase Auth 기본 정보 반환
        return UserEntity(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          phone: user.phoneNumber ?? '',
          userType: UserType.individual,
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      }
    });
  }

  @override
  Future<void> deleteAccount() async {
    final currentUser = await _authDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Firebase Auth 사용자가 없습니다.');
    }

    // Firebase Auth에서 사용자 삭제를 먼저 시도
    // 성공하면 Firestore 삭제, 실패하면 Firestore 삭제도 하지 않음
    try {
      await user.delete();
    } catch (e) {
      // Firebase Auth 삭제 실패 시 더 구체적인 오류 메시지 제공
      String errorMessage = '계정 삭제 중 오류가 발생했습니다.';
      
      if (e.toString().contains('requires-recent-login')) {
        errorMessage = '보안을 위해 최근에 로그인한 사용자만 계정을 삭제할 수 있습니다. 로그아웃 후 다시 로그인해주세요.';
      } else if (e.toString().contains('network')) {
        errorMessage = '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
      } else {
        errorMessage = '계정 삭제 중 오류가 발생했습니다: ${e.toString()}';
      }
      
      throw Exception(errorMessage);
    }

    // Firebase Auth 삭제 성공 후 Firestore에서 사용자 데이터 삭제
    try {
      await _firestoreDataSource.deleteUser(currentUser.uid);
    } catch (e) {
      // Firestore 삭제 실패는 로그만 남기고 계속 진행
      // Firebase Auth는 이미 삭제되었으므로
      debugPrint('Firestore 사용자 데이터 삭제 실패: $e');
    }
  }

  // Temporarily disabled methods due to Firebase Auth API changes
  /*
  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      // Simplified check - just return false for now
      return false;
    } catch (e) {
      throw Exception('이메일 확인 중 오류 발생: $e');
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      await user.verifyBeforeUpdateEmail(newEmail);
      
      // Firestore 사용자 정보 업데이트
      final userModel = await _firestoreDataSource.getUser(user.uid);
      if (userModel != null) {
        final updatedUser = userModel.copyWith(email: newEmail);
        await _firestoreDataSource.updateUser(updatedUser);
      }
    } catch (e) {
      throw Exception('이메일 변경 중 오류 발생: $e');
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('비밀번호 변경 중 오류 발생: $e');
    }
  }
  */
}