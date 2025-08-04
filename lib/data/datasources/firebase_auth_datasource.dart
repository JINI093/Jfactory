import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithKakao();
  Future<UserModel> signInWithNaver();
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
  Future<UserModel> signInWithKakao() async {
    try {
      // Check if KakaoTalk is installed and available
      bool isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();
      
      // Authenticate with Kakao
      if (isKakaoTalkInstalled) {
        try {
          // Login with KakaoTalk app
          await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          // If KakaoTalk login fails, fallback to web login
          await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // Login with web browser
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // Get user information from Kakao
      kakao.User kakaoUser = await kakao.UserApi.instance.me();
      
      // Create a custom token for Firebase (you'll need to implement server-side)
      // For now, we'll create a user directly with the Kakao user info
      // Note: This is a simplified approach - in production, you should use Firebase Custom Auth
      
      final String email = kakaoUser.kakaoAccount?.email ?? '${kakaoUser.id}@kakao.local';
      final String name = kakaoUser.kakaoAccount?.profile?.nickname ?? 'Kakao User';
      final String phone = kakaoUser.kakaoAccount?.phoneNumber ?? '';

      // Create or get Firebase user using anonymous auth and then link
      UserCredential userCredential;
      try {
        // Try to sign in with email (if user exists)
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, 
          password: 'kakao_${kakaoUser.id}',
        );
      } catch (e) {
        // User doesn't exist, create new user
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'kakao_${kakaoUser.id}',
        );
        
        // Update display name
        await userCredential.user?.updateDisplayName(name);
      }
      
      final user = userCredential.user;
      if (user == null) {
        throw Exception('카카오 로그인에 실패했습니다.');
      }

      return UserModel(
        uid: user.uid,
        email: email,
        name: name,
        phone: phone,
        userType: UserType.individual,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('카카오 로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithNaver() async {
    try {
      // Authenticate with Naver
      var result = await FlutterNaverLogin.logIn();
      
      // Check if login was successful
      if (result.account == null) {
        throw Exception('네이버 로그인이 취소되었습니다.');
      }

      // Get user information from result
      final account = result.account!;
      
      final String email = account.email ?? '${account.id}@naver.local';
      final String name = account.name ?? account.nickname ?? 'Naver User';
      final String phone = account.mobile ?? '';

      // Create or get Firebase user using email/password auth
      UserCredential userCredential;
      try {
        // Try to sign in with email (if user exists)
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, 
          password: 'naver_${account.id}',
        );
      } catch (e) {
        // User doesn't exist, create new user
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: 'naver_${account.id}',
        );
        
        // Update display name
        await userCredential.user?.updateDisplayName(name);
      }
      
      final user = userCredential.user;
      if (user == null) {
        throw Exception('네이버 로그인에 실패했습니다.');
      }

      return UserModel(
        uid: user.uid,
        email: email,
        name: name,
        phone: phone,
        userType: UserType.individual,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('네이버 로그인 중 오류가 발생했습니다: ${e.toString()}');
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
        _signOutKakao(),
        _signOutNaver(),
      ]);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> _signOutKakao() async {
    try {
      await kakao.UserApi.instance.logout();
    } catch (e) {
      // Kakao logout might fail if user is not logged in via Kakao
      // This is acceptable, so we don't throw an error
    }
  }

  Future<void> _signOutNaver() async {
    try {
      await FlutterNaverLogin.logOut();
    } catch (e) {
      // Naver logout might fail if user is not logged in via Naver
      // This is acceptable, so we don't throw an error
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