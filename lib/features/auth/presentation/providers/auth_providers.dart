import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_table/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:catch_table/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:catch_table/features/auth/domain/entities/user.dart';
import 'package:catch_table/features/auth/domain/repositories/auth_repository.dart';

/// Auth Remote DataSource Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

/// Auth Repository Provider
///
/// AuthRepository의 구현체를 제공합니다.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
  );
});

/// 현재 로그인된 사용자 Provider
///
/// Firebase Auth의 authStateChanges를 구독하여
/// 실시간으로 로그인 상태를 추적합니다.
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// 현재 로그인된 사용자 (동기) Provider
///
/// StreamProvider와 달리 즉시 현재 사용자를 반환합니다.
final currentUserProvider = Provider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.currentUser;
});
