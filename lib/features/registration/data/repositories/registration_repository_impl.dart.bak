import 'package:catch_table/features/registration/data/datasources/dummy_data.dart';
import 'package:catch_table/features/registration/domain/entities/registration.dart';
import 'package:catch_table/features/registration/domain/repositories/registration_repository.dart';

/// Registration Repository 구현 (Data Layer)
///
/// 현재는 in-memory 방식으로 구현
/// 향후 Firebase나 다른 데이터 소스로 교체 예정
class RegistrationRepositoryImpl implements RegistrationRepository {
  // In-memory 데이터 저장소
  final List<Registration> _registrations = List.from(dummyRegistrations);

  @override
  Future<List<Registration>> getRegistrations() async {
    // Firebase 연결 시: await _firestore.collection('registrations').get()
    return List.unmodifiable(_registrations);
  }

  @override
  Future<void> addRegistration(Registration registration) async {
    if (!registration.isValid) {
      throw ArgumentError('유효하지 않은 등록 정보입니다.');
    }

    // Firebase 연결 시: await _firestore.collection('registrations').add()
    _registrations.add(registration);
  }

  @override
  Future<Registration?> getRegistrationByPhone(String phoneNumber) async {
    // Firebase 연결 시: await _firestore.collection('registrations').where()
    try {
      return _registrations.firstWhere(
        (r) => r.phoneNumber == phoneNumber,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> removeRegistration(String phoneNumber) async {
    // Firebase 연결 시: await _firestore.collection('registrations').doc().delete()
    _registrations.removeWhere((r) => r.phoneNumber == phoneNumber);
  }
}
