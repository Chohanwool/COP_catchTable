/// 애플리케이션 전역 에러 처리
///
/// Repository 레이어에서 발생하는 모든 에러를 추상화합니다.
abstract class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Firestore 관련 에러
class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message);
}

/// 인증 관련 에러
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// 유효성 검증 에러
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// 서버 에러
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// 캐시 에러
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
