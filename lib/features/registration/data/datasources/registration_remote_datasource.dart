import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:catch_table/core/constants/firebase_constants.dart';

import 'package:catch_table/features/registration/data/models/registration_model.dart';

/// Registration Remote DataSource 인터페이스
abstract class RegistrationRemoteDataSource {
  /// 특정 매장의 특정 날짜 대기열 조회 (실시간 스트림)
  Stream<List<RegistrationModel>> watchRegistrations({
    required String storeId,
    required String date,
  });

  /// 대기열 등록 추가
  Future<void> addRegistration(RegistrationModel registration);

  /// 대기열 등록 삭제
  Future<void> removeRegistration({
    required String storeId,
    required String registrationId,
  });

  /// 대기열 상태 업데이트
  Future<void> updateRegistrationStatus({
    required String storeId,
    required String registrationId,
    required String status,
  });
}

/// Registration Remote DataSource 구현체 (Firestore)
class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  RegistrationRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get _registrationsCollection =>
      _firestore.collection(FirebaseCollections.registrations);

  @override
  Stream<List<RegistrationModel>> watchRegistrations({
    required String storeId,
    required String date,
  }) {
    return _registrationsCollection
        .where(FirebaseFields.storeId, isEqualTo: storeId)
        .where(FirebaseFields.date, isEqualTo: date)
        .where(FirebaseFields.status, isEqualTo: RegistrationStatus.waiting)
        .orderBy(FirebaseFields.registeredAt, descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RegistrationModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  @override
  Future<void> addRegistration(RegistrationModel registration) async {
    try {
      await _registrationsCollection.add(registration.toFirestore());
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        message: e.message ?? 'Firestore 등록 추가 오류가 발생했습니다.',
      );
    }
  }

  @override
  Future<void> removeRegistration({
    required String storeId,
    required String registrationId,
  }) async {
    try {
      await _registrationsCollection.doc(registrationId).delete();
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        message: e.message ?? 'Firestore 등록 삭제 오류가 발생했습니다.',
      );
    }
  }

  @override
  Future<void> updateRegistrationStatus({
    required String storeId,
    required String registrationId,
    required String status,
  }) async {
    try {
      await _registrationsCollection.doc(registrationId).update({
        FirebaseFields.status: status,
      });
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: e.plugin,
        message: e.message ?? 'Firestore 상태 업데이트 오류가 발생했습니다.',
      );
    }
  }
}
