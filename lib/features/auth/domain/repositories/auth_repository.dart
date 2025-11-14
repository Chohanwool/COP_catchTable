import 'package:catch_table/core/utils/result.dart';

import 'package:catch_table/features/auth/domain/entities/user.dart';

/// Auth Repository 인터페이스
///
/// 인증 관련 데이터 액세스 계층의 추상화입니다.
/// Data 레이어에서 구현체를 제공합니다.
abstract class AuthRepository {
  /// 현재 로그인된 사용자 조회
  ///
  /// Returns: 로그인된 사용자 또는 null
  User? get currentUser;

  /// 인증 상태 변경 스트림
  ///
  /// Returns: User 스트림 (로그아웃 시 null)
  Stream<User?> authStateChanges();

  /// 이메일/비밀번호로 로그인
  ///
  /// [email] - 사용자 이메일
  /// [password] - 비밀번호
  /// Returns: Success<User> 또는 Error<Failure>
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// 로그아웃
  ///
  /// Returns: Success<void> 또는 Error<Failure>
  Future<Result<void>> signOut();

  /// 비밀번호 재설정 이메일 전송
  ///
  /// [email] - 사용자 이메일
  /// Returns: Success<void> 또는 Error<Failure>
  Future<Result<void>> sendPasswordResetEmail(String email);
}
