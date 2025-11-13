import 'package:catch_table/core/errors/failures.dart';
import 'package:catch_table/core/utils/result.dart';
import 'package:catch_table/features/registration/data/datasources/registration_remote_datasource.dart';
import 'package:catch_table/features/registration/data/models/registration_model.dart';
import 'package:catch_table/features/registration/domain/entities/registration.dart';
import 'package:catch_table/features/registration/domain/repositories/registration_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Registration Repository Firestore 구현체
class RegistrationRepositoryFirestoreImpl implements RegistrationRepository {
  const RegistrationRepositoryFirestoreImpl(this.remoteDataSource);

  final RegistrationRemoteDataSource remoteDataSource;

  @override
  Stream<Result<List<Registration>>> watchRegistrations({
    required String storeId,
    required String date,
  }) {
    try {
      return remoteDataSource
          .watchRegistrations(storeId: storeId, date: date)
          .map((models) {
        final entities = models.map((model) => model.toEntity()).toList();
        return Success(entities);
      }).handleError((error) {
        if (error is FirebaseException) {
          return Error(
            FirestoreFailure(error.message ?? 'Firestore 오류가 발생했습니다.'),
          );
        }
        return Error(ServerFailure('서버 오류가 발생했습니다: $error'));
      });
    } catch (e) {
      return Stream.value(
        Error(ServerFailure('스트림 생성 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Future<Result<void>> addRegistration({
    required String storeId,
    required Registration registration,
  }) async {
    try {
      if (!registration.isValid) {
        return const Error(
          ValidationFailure('유효하지 않은 등록 정보입니다.'),
        );
      }

      final model = RegistrationModel.fromEntity(
        registration: registration,
        storeId: storeId,
      );

      await remoteDataSource.addRegistration(model);
      return const Success(null);
    } on FirebaseException catch (e) {
      return Error(
        FirestoreFailure(e.message ?? 'Firestore 등록 추가 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Error(ServerFailure('서버 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> removeRegistration({
    required String storeId,
    required String registrationId,
  }) async {
    try {
      await remoteDataSource.removeRegistration(
        storeId: storeId,
        registrationId: registrationId,
      );
      return const Success(null);
    } on FirebaseException catch (e) {
      return Error(
        FirestoreFailure(e.message ?? 'Firestore 삭제 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Error(ServerFailure('서버 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> updateRegistrationStatus({
    required String storeId,
    required String registrationId,
    required String status,
  }) async {
    try {
      await remoteDataSource.updateRegistrationStatus(
        storeId: storeId,
        registrationId: registrationId,
        status: status,
      );
      return const Success(null);
    } on FirebaseException catch (e) {
      return Error(
        FirestoreFailure(e.message ?? 'Firestore 업데이트 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Error(ServerFailure('서버 오류가 발생했습니다: $e'));
    }
  }
}
