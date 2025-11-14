import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_table/core/utils/result.dart';

import 'package:catch_table/features/auth/presentation/providers/auth_providers.dart';

import 'package:catch_table/features/store/data/datasources/store_remote_datasource.dart';
import 'package:catch_table/features/store/data/repositories/store_repository_impl.dart';

import 'package:catch_table/features/store/domain/entities/store.dart';
import 'package:catch_table/features/store/domain/repositories/store_repository.dart';
import 'package:catch_table/features/store/domain/usecases/get_store_by_pin.dart';

/// Store Remote DataSource Provider
final storeRemoteDataSourceProvider = Provider<StoreRemoteDataSource>((ref) {
  return StoreRemoteDataSourceImpl();
});

/// Store Repository Provider
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepositoryImpl(ref.read(storeRemoteDataSourceProvider));
});

/// GetStoreByPin UseCase Provider
final getStoreByPinProvider = Provider<GetStoreByPin>((ref) {
  return GetStoreByPin(ref.read(storeRepositoryProvider));
});

/// 현재 선택된 Store를 관리하는 StateProvider
final selectedStoreProvider = StateProvider<Store?>((ref) => null);

/// Auth 상태에 따라 자동으로 매장 정보를 로드하는 Provider
///
/// 사용자가 로그인되어 있으면 해당 UID로 매장 정보를 자동 로드합니다.
/// 로그인 상태가 아니면 null을 반환합니다.
final autoLoadStoreProvider = FutureProvider<Store?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);

  // 로그인되어 있지 않으면 null 반환
  if (authState == null) {
    ref.read(selectedStoreProvider.notifier).state = null;
    return null;
  }

  // UID로 매장 정보 조회
  final repository = ref.read(storeRepositoryProvider);
  final result = await repository.getStoreByUid(authState.uid);

  if (result.isSuccess) {
    final store = result.valueOrNull;
    // selectedStoreProvider에도 자동 저장
    ref.read(selectedStoreProvider.notifier).state = store;
    return store;
  }

  // 매장 정보 로드 실패
  ref.read(selectedStoreProvider.notifier).state = null;
  return null;
});
