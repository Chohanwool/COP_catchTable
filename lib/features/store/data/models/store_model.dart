import 'package:catch_table/core/constants/firebase_constants.dart';
import 'package:catch_table/features/store/domain/entities/store.dart';

/// Store Data Model
///
/// Firestore와 Domain Entity 간의 변환을 담당하는 DTO
class StoreModel {
  const StoreModel({
    required this.id,
    required this.name,
    required this.pin,
    required this.uid,
    this.logoUrl,
    this.contact,
    this.address,
  });

  final String id;
  final String name;
  final String pin;
  final String uid; // Firebase Auth User ID
  final String? logoUrl;
  final String? contact;
  final String? address;

  /// JSON에서 Model로 변환
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      pin: json['pin'] as String,
      uid: json['uid'] as String,
      logoUrl: json['logoUrl'] as String?,
      contact: json['contact'] as String?,
      address: json['address'] as String?,
    );
  }

  /// Model을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pin': pin,
      'uid': uid,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (contact != null) 'contact': contact,
      if (address != null) 'address': address,
    };
  }

  /// Firestore Document에서 Model로 변환
  factory StoreModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StoreModel(
      id: id,
      name: data[FirebaseFields.storeName] as String? ?? '',
      pin: data[FirebaseFields.storePin] as String? ?? '',
      uid: data[FirebaseFields.storeUid] as String? ?? '',
      logoUrl: data[FirebaseFields.storeLogoUrl] as String?,
      contact: data[FirebaseFields.storeContact] as String?,
      address: data[FirebaseFields.storeAddress] as String?,
    );
  }

  /// Model을 Firestore Document로 변환
  Map<String, dynamic> toFirestore() {
    return {
      FirebaseFields.storeName: name,
      FirebaseFields.storePin: pin,
      FirebaseFields.storeUid: uid,
      if (logoUrl != null) FirebaseFields.storeLogoUrl: logoUrl,
      if (contact != null) FirebaseFields.storeContact: contact,
      if (address != null) FirebaseFields.storeAddress: address,
    };
  }

  /// Model을 Domain Entity로 변환
  Store toEntity() {
    return Store(
      id: id,
      name: name,
      pin: pin,
      uid: uid,
      logoUrl: logoUrl,
      contact: contact,
      address: address,
    );
  }

  /// Domain Entity에서 Model로 변환
  factory StoreModel.fromEntity(Store store) {
    return StoreModel(
      id: store.id,
      name: store.name,
      pin: store.pin,
      uid: store.uid,
      logoUrl: store.logoUrl,
      contact: store.contact,
      address: store.address,
    );
  }
}
