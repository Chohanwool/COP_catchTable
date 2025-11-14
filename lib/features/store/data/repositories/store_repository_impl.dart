import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catch_table/core/utils/result.dart';
import 'package:catch_table/core/errors/failures.dart';

import 'package:catch_table/features/store/data/datasources/store_remote_datasource.dart';
import 'package:catch_table/features/store/data/models/store_model.dart';

import 'package:catch_table/features/store/domain/entities/store.dart';
import 'package:catch_table/features/store/domain/repositories/store_repository.dart';

/// Store Repository 구현체
class StoreRepositoryImpl implements StoreRepository {
  const StoreRepositoryImpl(this.remoteDataSource);

  final StoreRemoteDataSource remoteDataSource;

  @override
  Future<Result<Store>> getStoreByPin(String pin) async {
    try {
      final storeModel = await remoteDataSource.getStoreByPin(pin);
      return Success(storeModel.toEntity());
    } on FirebaseException catch (e) {
      return Error(FirestoreFailure(e.message ?? 'Firestore 오류가 발생했습니다.'));
    } catch (e) {
      return Error(ServerFailure('서버 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<Store>> getStoreById(String storeId) async {
    try {
      final storeModel = await remoteDataSource.getStoreById(storeId);
      return Success(storeModel.toEntity());
    } on FirebaseException catch (e) {
      return Error(FirestoreFailure(e.message ?? 'Firestore 오류가 발생했습니다.'));
    } catch (e) {
      return Error(ServerFailure('서버 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<Store>> getStoreByUid(String uid) async {
    try {
      final storeModel = await remoteDataSource.getStoreByUid(uid);
      return Success(storeModel.toEntity());
    } on FirebaseException catch (e) {
      return Error(FirestoreFailure(e.message ?? 'Firestore 오류가 발생했습니다.'));
    } catch (e) {
      return Error(ServerFailure('서버 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> updateStore(Store store) async {
    try {
      final storeModel = StoreModel.fromEntity(store);
      await remoteDataSource.updateStore(storeModel);
      return const Success(null);
    } on FirebaseException catch (e) {
      return Error(FirestoreFailure(e.message ?? 'Firestore 업데이트 오류가 발생했습니다.'));
    } catch (e) {
      return Error(ServerFailure('서버 오류가 발생했습니다: $e'));
    }
  }
}
