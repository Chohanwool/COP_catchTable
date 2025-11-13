import 'package:catch_table/core/errors/failures.dart';
import 'package:catch_table/core/utils/result.dart';

import 'package:catch_table/features/store/domain/entities/store.dart';
import 'package:catch_table/features/store/domain/repositories/store_repository.dart';

/// GetStoreByPin UseCase
///
/// PIN 번호로 매장 정보를 조회하는 비즈니스 로직
class GetStoreByPin {
  const GetStoreByPin(this.repository);

  final StoreRepository repository;

  /// PIN 번호로 매장 정보 조회
  ///
  /// [pin] - 매장 PIN 번호
  /// Returns: Success<Store> 또는 Error<Failure>
  Future<Result<Store>> call(String pin) async {
    // PIN 포맷 검증
    if (pin.isEmpty || !RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      return const Error(ValidationFailure('PIN 번호는 4~6자리 숫자여야 합니다.'));
    }

    return await repository.getStoreByPin(pin);
  }
}
