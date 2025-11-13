import 'package:catch_table/core/utils/result.dart';
import 'package:catch_table/features/registration/domain/entities/registration.dart';

/// Registration Repository Interface (Domain Layer)
///
/// 비즈니스 로직에서 필요한 데이터 작업을 정의
/// 실제 구현은 Data Layer에서 구현체가 담당
abstract class RegistrationRepository {
  /// 특정 매장의 특정 날짜 대기열을 실시간으로 조회합니다.
  Stream<Result<List<Registration>>> watchRegistrations({
    required String storeId,
    required String date,
  });

  /// 새로운 대기열 등록 정보를 추가합니다.
  Future<Result<void>> addRegistration({
    required String storeId,
    required Registration registration,
  });

  /// 특정 등록 정보를 삭제합니다.
  Future<Result<void>> removeRegistration({
    required String storeId,
    required String registrationId,
  });

  /// 대기열 상태를 업데이트합니다.
  Future<Result<void>> updateRegistrationStatus({
    required String storeId,
    required String registrationId,
    required String status,
  });
}
