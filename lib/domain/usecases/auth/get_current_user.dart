import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<UserEntity?> call() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      throw Exception('현재 사용자 조회 실패: ${e.toString()}');
    }
  }
}