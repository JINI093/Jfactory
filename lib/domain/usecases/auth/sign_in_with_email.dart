import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInWithEmailUseCase {
  final AuthRepository _authRepository;

  SignInWithEmailUseCase(this._authRepository);

  Future<UserEntity> call(SignInWithEmailParams params) async {
    // 입력 값 유효성 검사
    if (params.email.isEmpty) {
      throw Exception('이메일을 입력해주세요.');
    }

    if (params.password.isEmpty) {
      throw Exception('비밀번호를 입력해주세요.');
    }

    if (!_isValidEmail(params.email)) {
      throw Exception('올바른 이메일 형식이 아닙니다.');
    }

    if (params.password.length < 6) {
      throw Exception('비밀번호는 6자 이상이어야 합니다.');
    }

    try {
      return await _authRepository.signInWithEmail(
        params.email,
        params.password,
      );
    } catch (e) {
      // 에러 메시지를 더 사용자 친화적으로 변환
      if (e.toString().contains('user-not-found')) {
        throw Exception('등록되지 않은 이메일입니다.');
      } else if (e.toString().contains('wrong-password')) {
        throw Exception('비밀번호가 올바르지 않습니다.');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('올바르지 않은 이메일 형식입니다.');
      } else if (e.toString().contains('user-disabled')) {
        throw Exception('비활성화된 계정입니다.');
      } else if (e.toString().contains('too-many-requests')) {
        throw Exception('너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.');
      }
      
      rethrow;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class SignInWithEmailParams {
  final String email;
  final String password;

  SignInWithEmailParams({
    required this.email,
    required this.password,
  });
}