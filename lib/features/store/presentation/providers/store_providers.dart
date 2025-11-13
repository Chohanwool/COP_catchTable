import 'package:flutter_riverpod/flutter_riverpod.dart';

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
