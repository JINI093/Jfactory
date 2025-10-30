import 'package:firebase_auth/firebase_auth.dart';
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

      // firestore에서 사용자 정보 가져오기
      final completeUserModel = await _firestoreDataSource.getUser(userModel.uid);
      return completeUserModel?.toEntity() ?? userModel.toEntity();
    } catch (e) {
      throw Exception('현재 사용자 정보 가져오기 중 오류 발생: $e');
    }
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final userModel = await _authDataSource.signInWithEmail(email, password);
      
      // firestore에서 사용자 정보 가져오기
      final completeUserModel = await _firestoreDataSource.getUser(userModel.uid);
      return completeUserModel?.toEntity() ?? userModel.toEntity();
    } catch (e) {
      throw Exception('이메일 로그인 중 오류 발생: $e');
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
      // Firebase Auth� ��� �1
      final userModel = await _authDataSource.signUpWithEmail(
        email,
        password,
        name,
        phone,
        userType,
      );

      // firestore에서 사용자 정보 가져오기
      final completeUserModel = userModel.copyWith(
        companyName: companyName,
        businessLicense: businessLicense,
      );

      // firestore에 사용자 정보 저장
      await _firestoreDataSource.createUser(completeUserModel);

      return completeUserModel.toEntity();
    } catch (e) {
      throw Exception('이메일 회원가입 중 오류 발생: $e');
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
      
      // Firebase Auth 사용자 정보 업데이트
      await _authDataSource.updateUserProfile(userModel);
      
      // Firestore 사용자 정보 업데이트
      await _firestoreDataSource.updateUser(userModel);
    } catch (e) {
      throw Exception('사용자 정보 업데이트 중 오류 발생: $e');
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authDataSource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      
      try {
        // firestore에서 사용자 정보 가져오기
        final userModel = await _firestoreDataSource.getUser(user.uid);
        return userModel?.toEntity();
      } catch (e) {
        // firestore에서 사용자 정보 가져오기 실패 시 Firebase Auth에서 사용자 정보 생성
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
    try {
      final currentUser = await _authDataSource.getCurrentUser();
      if (currentUser == null) {
        throw Exception('현재 사용자가 없습니다.');
      }

      // firestore에서 사용자 정보 삭제
      await _firestoreDataSource.deleteUser(currentUser.uid);
      
      // Firebase Auth에서 사용자 정보 삭제
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('사용자 삭제 중 오류 발생: $e');
    }
  }

  // Temporarily disabled methods due to Firebase Auth API changes
  /*
  Future<bool> checkEmailExists(String email) async {
    try {
      // Simplified check - just return false for now
      return false;
    } catch (e) {
      throw Exception('이메일 중복 확인 중 오류 발생: $e');
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('현재 사용자가 없습니다.');
      }

      await user.verifyBeforeUpdateEmail(newEmail);
      
      // firestore에서 사용자 정보 업데이트
      final userModel = await _firestoreDataSource.getUser(user.uid);
      if (userModel != null) {
        final updatedUser = userModel.copyWith(email: newEmail);
        await _firestoreDataSource.updateUser(updatedUser);
      }
    } catch (e) {
      throw Exception('이메일 업데이트 중 오류 발생: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('현재 사용자가 없습니다.');
      }

      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('비밀번호 업데이트 중 오류 발생: $e');
    }
  }
  */
}