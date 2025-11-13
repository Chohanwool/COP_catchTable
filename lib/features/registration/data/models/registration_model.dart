import 'package:catch_table/core/constants/firebase_constants.dart';
import 'package:catch_table/features/registration/domain/entities/registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Registration Data Model
///
/// Firestore와 Domain Entity 간의 변환을 담당하는 DTO
class RegistrationModel {
  const RegistrationModel({
    required this.id,
    required this.storeId,
    required this.phoneNumber,
    required this.groupSize,
    required this.registeredAt,
    required this.date,
    required this.status,
  });

  final String id;
  final String storeId;
  final String phoneNumber;
  final int groupSize;
  final DateTime registeredAt;
  final String date; // YYYY-MM-DD 형식
  final String status;

  /// Firestore Document에서 Model로 변환
  factory RegistrationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return RegistrationModel(
      id: id,
      storeId: data[FirebaseFields.storeId] as String? ?? '',
      phoneNumber: data[FirebaseFields.phoneNumber] as String? ?? '',
      groupSize: data[FirebaseFields.groupSize] as int? ?? 0,
      registeredAt: (data[FirebaseFields.registeredAt] as Timestamp).toDate(),
      date: data[FirebaseFields.date] as String? ?? '',
      status: data[FirebaseFields.status] as String? ?? RegistrationStatus.waiting,
    );
  }

  /// Model을 Firestore Document로 변환
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseFields.storeId: storeId,
      FirebaseFields.phoneNumber: phoneNumber,
      FirebaseFields.groupSize: groupSize,
      FirebaseFields.registeredAt: Timestamp.fromDate(registeredAt),
      FirebaseFields.date: date,
      FirebaseFields.status: status,
    };
  }

  /// Model을 Domain Entity로 변환
  Registration toEntity() {
    return Registration(
      phoneNumber: phoneNumber,
      groupSize: groupSize,
    );
  }

  /// Domain Entity에서 Model로 변환
  factory RegistrationModel.fromEntity({
    required Registration registration,
    required String storeId,
    String? id,
    DateTime? registeredAt,
    String? date,
    String? status,
  }) {
    final now = registeredAt ?? DateTime.now();
    return RegistrationModel(
      id: id ?? '',
      storeId: storeId,
      phoneNumber: registration.phoneNumber ?? '',
      groupSize: registration.groupSize ?? 0,
      registeredAt: now,
      date: date ?? _formatDate(now),
      status: status ?? RegistrationStatus.waiting,
    );
  }

  /// DateTime을 YYYY-MM-DD 형식으로 변환
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// copyWith 메서드
  RegistrationModel copyWith({
    String? id,
    String? storeId,
    String? phoneNumber,
    int? groupSize,
    DateTime? registeredAt,
    String? date,
    String? status,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      groupSize: groupSize ?? this.groupSize,
      registeredAt: registeredAt ?? this.registeredAt,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
