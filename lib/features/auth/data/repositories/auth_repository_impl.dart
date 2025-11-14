import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:catch_table/core/errors/failures.dart';
import 'package:catch_table/core/utils/result.dart';

import 'package:catch_table/features/auth/data/datasources/auth_remote_datasource.dart';

import 'package:catch_table/features/auth/domain/entities/user.dart';
import 'package:catch_table/features/auth/domain/repositories/auth_repository.dart';

/// Auth Repository 구현체
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

  @override
  User? get currentUser {
    final userModel = remoteDataSource.currentUser;
    return userModel?.toEntity();
  }

  @override
  Stream<User?> authStateChanges() {
    return remoteDataSource.authStateChanges().map((userModel) {
      return userModel?.toEntity();
    });
  }

  @override
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(userModel.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(_handleAuthException(e));
    } catch (e) {
      return Error(ServerFailure('로그인 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(_handleAuthException(e));
    } catch (e) {
      return Error(ServerFailure('로그아웃 중 오류가 발생했습니다: $e'));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Error(_handleAuthException(e));
    } catch (e) {
      return Error(ServerFailure('비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: $e'));
    }
  }

  /// Firebase Auth Exception을 Failure로 변환
  Failure _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure('등록되지 않은 이메일입니다.');
      case 'wrong-password':
        return const AuthFailure('비밀번호가 올바르지 않습니다.');
      case 'invalid-email':
        return const AuthFailure('올바른 이메일 형식이 아닙니다.');
      case 'user-disabled':
        return const AuthFailure('비활성화된 계정입니다.');
      case 'too-many-requests':
        return const AuthFailure('너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.');
      case 'network-request-failed':
        return const NetworkFailure('네트워크 연결을 확인해주세요.');
      default:
        return AuthFailure(e.message ?? '인증 오류가 발생했습니다.');
    }
  }
}
