import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:catch_table/features/auth/domain/entities/user.dart';

/// User Data Model
///
/// Firebase Auth User와 Domain Entity 간의 변환을 담당하는 DTO
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;

  /// Firebase Auth User에서 Model로 변환
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
    );
  }

  /// Model을 Domain Entity로 변환
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
    );
  }

  /// Domain Entity에서 Model로 변환
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
