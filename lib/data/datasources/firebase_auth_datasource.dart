import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signUpWithEmail(String email, String password, String name, String phone, UserType userType);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserProfile(UserModel user);
  Stream<User?> get authStateChanges;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    // Firestore에서 추가 사용자 정보를 가져와야 함
    // 여기서는 기본 정보만 반환
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      phone: user.phoneNumber ?? '',
      userType: UserType.individual, // 기본값, Firestore에서 실제 값을 가져와야 함
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('로그인에 실패했습니다.');
      }

      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        phone: user.phoneNumber ?? '',
        userType: UserType.individual,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('구글 로그인이 취소되었습니다.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      final user = userCredential.user;
      if (user == null) {
        throw Exception('구글 로그인에 실패했습니다.');
      }

      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        phone: user.phoneNumber ?? '',
        userType: UserType.individual,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('구글 로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
    UserType userType,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      // 사용자 프로필 업데이트
      await user.updateDisplayName(name);

      return UserModel(
        uid: user.uid,
        email: email,
        name: name,
        phone: phone,
        userType: userType,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  @override
  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('로그인된 사용자가 없습니다.');
      }

      await user.updateDisplayName(userModel.name);
      // 추가적인 사용자 정보는 Firestore에 저장해야 함
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '등록되지 않은 이메일입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다.';
      case 'invalid-email':
        return '올바르지 않은 이메일 형식입니다.';
      case 'too-many-requests':
        return '너무 많은 요청이 있었습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 연결을 확인해주세요.';
      default:
        return '인증 오류가 발생했습니다: ${e.message}';
    }
  }
}