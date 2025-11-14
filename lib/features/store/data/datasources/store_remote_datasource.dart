import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catch_table/core/constants/firebase_constants.dart';

import 'package:catch_table/features/store/data/models/store_model.dart';

/// Store Remote DataSource 인터페이스
abstract class StoreRemoteDataSource {
  Future<StoreModel> getStoreByPin(String pin);
  Future<StoreModel> getStoreById(String storeId);
  Future<StoreModel> getStoreByUid(String uid);
  Future<void> updateStore(StoreModel store);
}

/// Store Remote DataSource 구현체 (Firestore)
class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  StoreRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get _storesCollection =>
      _firestore.collection(FirebaseCollections.stores);

  @override
  Future<StoreModel> getStoreByPin(String pin) async {
    try {
      final querySnapshot = await _storesCollection
          .where(FirebaseFields.storePin, isEqualTo: pin)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message: '해당 PIN 번호로 등록된 매장을 찾을 수 없습니다.',
        );
      }

      final doc = querySnapshot.docs.first;
      return StoreModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        message: e.message ?? 'Firestore 오류가 발생했습니다.',
      );
    }
  }

  @override
  Future<StoreModel> getStoreById(String storeId) async {
    try {
      final docSnapshot = await _storesCollection.doc(storeId).get();

      if (!docSnapshot.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message: '해당 ID의 매장을 찾을 수 없습니다.',
        );
      }

      return StoreModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        message: e.message ?? 'Firestore 오류가 발생했습니다.',
      );
    }
  }

  @override
  Future<StoreModel> getStoreByUid(String uid) async {
    try {
      final querySnapshot = await _storesCollection
          .where(FirebaseFields.storeUid, isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message: '해당 사용자 계정에 연결된 매장을 찾을 수 없습니다.',
        );
      }

      final doc = querySnapshot.docs.first;
      return StoreModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        message: e.message ?? 'Firestore 오류가 발생했습니다.',
      );
    }
  }

  @override
  Future<void> updateStore(StoreModel store) async {
    try {
      await _storesCollection.doc(store.id).update(store.toFirestore());
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        message: e.message ?? 'Firestore 업데이트 오류가 발생했습니다.',
      );
    }
  }
}
