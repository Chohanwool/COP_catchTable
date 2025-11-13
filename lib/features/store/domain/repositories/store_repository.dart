import 'package:catch_table/core/utils/result.dart';
import 'package:catch_table/features/store/domain/entities/store.dart';

/// Store Repository 인터페이스
///
/// 매장 정보 관련 데이터 액세스 계층의 추상화입니다.
/// Data 레이어에서 구현체를 제공합니다.
abstract class StoreRepository {
  /// PIN 번호로 매장 정보 조회
  ///
  /// [pin] - 매장 PIN 번호 (4~6자리 숫자)
  /// Returns: Success<Store> 또는 Error<Failure>
  Future<Result<Store>> getStoreByPin(String pin);

  /// 매장 ID로 매장 정보 조회
  ///
  /// [storeId] - 매장 고유 ID
  /// Returns: Success<Store> 또는 Error<Failure>
  Future<Result<Store>> getStoreById(String storeId);

  /// 매장 정보 업데이트
  ///
  /// [store] - 업데이트할 매장 정보
  /// Returns: Success<void> 또는 Error<Failure>
  Future<Result<void>> updateStore(Store store);
}
