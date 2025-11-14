/// User Domain Entity - 인증된 사용자 정보
///
/// Firebase Auth User를 도메인 계층에서 사용하는 불변 객체입니다.
class User {
  const User({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;

  /// 불변 객체 업데이트 패턴
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ email.hashCode ^ displayName.hashCode;
  }

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName)';
  }
}
