import '../../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository _authRepository;

  SendPasswordResetEmailUseCase(this._authRepository);

  Future<void> call(String email) async {
    // 입력 값 유효성 검사
    if (email.isEmpty) {
      throw Exception('이메일을 입력해주세요.');
    }

    if (!_isValidEmail(email)) {
      throw Exception('올바른 이메일 형식이 아닙니다.');
    }

    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      if (e.toString().contains('user-not-found')) {
        throw Exception('등록되지 않은 이메일입니다.');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('올바르지 않은 이메일 형식입니다.');
      }
      
      rethrow;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}