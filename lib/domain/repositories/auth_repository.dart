import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithKakao();
  Future<UserEntity> signInWithNaver();
  Future<UserEntity> signInWithApple();
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
    String? companyName,
    String? businessLicense,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserProfile(UserEntity user);
  Stream<UserEntity?> get authStateChanges;
  Future<void> deleteAccount();
  // Future<bool> checkEmailExists(String email);
  // Future<void> updateEmail(String newEmail);
  // Future<void> updatePassword(String newPassword);
}