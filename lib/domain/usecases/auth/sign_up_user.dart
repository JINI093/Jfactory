import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignUpUserUseCase {
  final AuthRepository _authRepository;

  SignUpUserUseCase(this._authRepository);

  Future<UserEntity> call(SignUpUserParams params) async {
    // 입력 값 유효성 검사
    _validateInput(params);

    try {
      // 이메일 중복 확인은 Firebase Auth에서 자동으로 처리됨

      // 회원가입 처리
      return await _authRepository.signUpWithEmail(
        email: params.email,
        password: params.password,
        name: params.name,
        phone: params.phone,
        userType: params.userType,
        companyName: params.companyName,
        businessLicense: params.businessLicense,
      );
    } catch (e) {
      // 에러 메시지를 더 사용자 친화적으로 변환
      if (e.toString().contains('email-already-in-use')) {
        throw Exception('이미 사용 중인 이메일입니다.');
      } else if (e.toString().contains('weak-password')) {
        throw Exception('비밀번호가 너무 약합니다. 더 강한 비밀번호를 사용해주세요.');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('올바르지 않은 이메일 형식입니다.');
      } else if (e.toString().contains('operation-not-allowed')) {
        throw Exception('이메일/비밀번호 회원가입이 비활성화되어 있습니다.');
      }
      
      rethrow;
    }
  }

  void _validateInput(SignUpUserParams params) {
    if (params.email.isEmpty) {
      throw Exception('이메일을 입력해주세요.');
    }

    if (params.password.isEmpty) {
      throw Exception('비밀번호를 입력해주세요.');
    }

    if (params.confirmPassword.isEmpty) {
      throw Exception('비밀번호 확인을 입력해주세요.');
    }

    if (params.name.isEmpty) {
      throw Exception('이름을 입력해주세요.');
    }

    if (params.phone.isEmpty) {
      throw Exception('전화번호를 입력해주세요.');
    }

    // 이메일 형식 검증
    if (!_isValidEmail(params.email)) {
      throw Exception('올바른 이메일 형식이 아닙니다.');
    }

    // 비밀번호 검증
    if (params.password.length < 6) {
      throw Exception('비밀번호는 6자 이상이어야 합니다.');
    }

    if (params.password != params.confirmPassword) {
      throw Exception('비밀번호가 일치하지 않습니다.');
    }

    // 비밀번호 강도 검증
    if (!_isStrongPassword(params.password)) {
      throw Exception('비밀번호는 영문, 숫자를 포함해야 합니다.');
    }

    // 전화번호 형식 검증
    if (!_isValidPhoneNumber(params.phone)) {
      throw Exception('올바른 전화번호 형식이 아닙니다.');
    }

    // 이름 길이 검증
    if (params.name.length < 2) {
      throw Exception('이름은 2자 이상이어야 합니다.');
    }

    // 기업 회원인 경우 추가 검증
    if (params.userType == UserType.company) {
      if (params.companyName == null || params.companyName!.isEmpty) {
        throw Exception('기업명을 입력해주세요.');
      }

      if (params.businessLicense == null || params.businessLicense!.isEmpty) {
        throw Exception('사업자등록번호를 입력해주세요.');
      }

      if (!_isValidBusinessLicense(params.businessLicense!)) {
        throw Exception('올바른 사업자등록번호 형식이 아닙니다.');
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    // 영문과 숫자를 포함하는지 검증
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password);
  }

  bool _isValidPhoneNumber(String phone) {
    // 한국 전화번호 형식 검증 (010-1234-5678 또는 01012345678)
    return RegExp(r'^010-?\d{4}-?\d{4}$').hasMatch(phone);
  }

  bool _isValidBusinessLicense(String license) {
    // 사업자등록번호 형식 검증 (123-45-67890 또는 1234567890)
    final cleanLicense = license.replaceAll('-', '');
    if (cleanLicense.length != 10) return false;
    
    // 사업자등록번호 검증 로직 (체크섬 계산)
    final digits = cleanLicense.split('').map(int.parse).toList();
    final checkDigits = [1, 3, 7, 1, 3, 7, 1, 3, 5];
    
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * checkDigits[i];
    }
    
    sum += (digits[8] * 5) ~/ 10;
    final checkSum = (10 - (sum % 10)) % 10;
    
    return checkSum == digits[9];
  }
}

class SignUpUserParams {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final String phone;
  final UserType userType;
  final String? companyName;
  final String? businessLicense;

  SignUpUserParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.name,
    required this.phone,
    required this.userType,
    this.companyName,
    this.businessLicense,
  });
}