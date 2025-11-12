import 'package:catch_table/features/registration/domain/entities/registration.dart';
import 'package:catch_table/features/registration/domain/repositories/registration_repository.dart';

/// GetRegistrations UseCase (Domain Layer)
///
/// 모든 등록 정보를 조회하는 비즈니스 로직을 담당합니다.
class GetRegistrations {
  const GetRegistrations(this._repository);

  final RegistrationRepository _repository;

  /// 모든 등록 정보를 가져옵니다.
  Future<List<Registration>> call() async {
    return await _repository.getRegistrations();
  }
}
