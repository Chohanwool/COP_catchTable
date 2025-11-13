import 'package:catch_table/features/registration/data/datasources/registration_remote_datasource.dart';
import 'package:catch_table/features/registration/data/repositories/registration_repository_firestore_impl.dart';
import 'package:catch_table/features/registration/domain/repositories/registration_repository.dart';
import 'package:catch_table/features/registration/presentation/providers/registration_notifier.dart';
import 'package:catch_table/features/registration/presentation/providers/registration_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registration Remote DataSource Provider
final registrationRemoteDataSourceProvider =
    Provider<RegistrationRemoteDataSource>((ref) {
  return RegistrationRemoteDataSourceImpl();
});

/// Repository Provider (Firestore 버전)
///
/// RegistrationRepository의 Firestore 구현체를 제공합니다.
final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepositoryFirestoreImpl(
    ref.read(registrationRemoteDataSourceProvider),
  );
});

/// Registration Notifier Provider
///
/// 등록 화면의 상태와 비즈니스 로직을 관리하는 Provider
final registrationNotifierProvider =
    ChangeNotifierProvider<RegistrationNotifier>((ref) {
  return RegistrationNotifier(ref);
});
