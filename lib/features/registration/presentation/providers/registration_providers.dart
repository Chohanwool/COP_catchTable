import 'package:catch_table/features/registration/data/repositories/registration_repository_impl.dart';
import 'package:catch_table/features/registration/domain/repositories/registration_repository.dart';
import 'package:catch_table/features/registration/domain/usecases/add_registration.dart';
import 'package:catch_table/features/registration/domain/usecases/get_registrations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_providers.g.dart';

/// Repository Provider
///
/// RegistrationRepository의 구현체를 제공합니다.
/// 향후 Firebase 연결 시 구현체만 교체하면 됩니다.
@riverpod
RegistrationRepository registrationRepository(Ref ref) {
  return RegistrationRepositoryImpl();
}

/// GetRegistrations UseCase Provider
@riverpod
GetRegistrations getRegistrations(Ref ref) {
  return GetRegistrations(ref.watch(registrationRepositoryProvider));
}

/// AddRegistration UseCase Provider
@riverpod
AddRegistration addRegistration(Ref ref) {
  return AddRegistration(ref.watch(registrationRepositoryProvider));
}
