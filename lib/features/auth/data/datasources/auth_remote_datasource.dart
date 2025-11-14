import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:catch_table/features/auth/data/models/user_model.dart';

/// Auth Remote DataSource 인터페이스
abstract class AuthRemoteDataSource {
  /// 현재 로그인된 사용자
  UserModel? get currentUser;

  /// 인증 상태 변경 스트림
  Stream<UserModel?> authStateChanges();

  /// 이메일/비밀번호로 로그인
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// 로그아웃
  Future<void> signOut();

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email);
}

/// Auth Remote DataSource 구현체 (Firebase Auth)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;

  @override
  UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw firebase_auth.FirebaseAuthException(
          code: 'user-not-found',
          message: '사용자를 찾을 수 없습니다.',
        );
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    }
  }
}
