/// Firestore Collection 이름
class FirebaseCollections {
  static const String stores = 'stores';
  static const String registrations = 'registrations';
}

/// Firestore 필드 이름
class FirebaseFields {
  // Store fields
  static const String storeId = 'storeId';
  static const String storeName = 'name';
  static const String storePin = 'pin';
  static const String storeUid = 'storeUid'; // Firebase Auth User ID
  static const String storeLogoUrl = 'logoUrl';
  static const String storeContact = 'contact';
  static const String storeAddress = 'address';

  // Registration fields
  static const String registrationId = 'id';
  static const String phoneNumber = 'phoneNumber';
  static const String groupSize = 'groupSize';
  static const String registeredAt = 'registeredAt';
  static const String date = 'date';
  static const String status = 'status';
}

/// Registration 상태
class RegistrationStatus {
  static const String waiting = 'waiting';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String noShow = 'no_show';
}
