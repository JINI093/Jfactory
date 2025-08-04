import '../../repositories/auth_repository.dart';

class SignOutUserUseCase {
  final AuthRepository _authRepository;

  SignOutUserUseCase(this._authRepository);

  Future<void> call() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      throw Exception('로그아웃 실패: ${e.toString()}');
    }
  }
}