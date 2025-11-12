import 'package:catch_table/features/registration/domain/entities/registration.dart';

/// Registration Repository Interface (Domain Layer)
///
/// 비즈니스 로직에서 필요한 데이터 작업을 정의
/// 실제 구현은 Data Layer에서 구현체가 담당
abstract class RegistrationRepository {
  /// 모든 대기열 등록 정보를 조회합니다.
  Future<List<Registration>> getRegistrations();

  /// 새로운 대기열 등록 정보를 추가합니다.
  Future<void> addRegistration(Registration registration);

  /// 특정 전화번호로 등록 정보를 조회합니다.
  Future<Registration?> getRegistrationByPhone(String phoneNumber);

  /// 특정 등록 정보를 삭제합니다.
  Future<void> removeRegistration(String phoneNumber);
}
