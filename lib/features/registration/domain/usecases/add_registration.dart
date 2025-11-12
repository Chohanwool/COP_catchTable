import 'package:catch_table/features/registration/domain/entities/registration.dart';
import 'package:catch_table/features/registration/domain/repositories/registration_repository.dart';

/// AddRegistration UseCase (Domain Layer)
///
/// 새로운 등록 정보를 추가하는 비즈니스 로직을 담당합니다.
class AddRegistration {
  const AddRegistration(this._repository);

  final RegistrationRepository _repository;

  /// 새로운 등록 정보를 추가합니다.
  ///
  /// [registration]이 유효하지 않으면 예외를 발생시킵니다.
  Future<void> call(Registration registration) async {
    // 비즈니스 규칙 검증
    if (!registration.isValid) {
      throw ArgumentError(
        '유효하지 않은 등록 정보입니다. '
        '전화번호 또는 인원 수를 확인해주세요.',
      );
    }

    // 중복 전화번호 검증 (선택적)
    final existing = await _repository.getRegistrationByPhone(
      registration.phoneNumber!,
    );
    if (existing != null) {
      // 당일 중복 등록 시, 이전 예약은 삭제되고 새로운 대기열로 덮어 씌워 진다는 것을 알림
    }

    await _repository.addRegistration(registration);
  }
}
