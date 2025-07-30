import 'package:flutter/foundation.dart';

@immutable
class Registration {
  const Registration({
    this.phoneNumber,
    this.groupSize,
  });

  final String? phoneNumber;
  final int? groupSize;

  Registration copyWith({
    String? phoneNumber,
    int? groupSize,
  }) {
    return Registration(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      groupSize: groupSize ?? this.groupSize,
    );
  }

  @override
  String toString() => 'Registration(phoneNumber: $phoneNumber, groupSize: $groupSize)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Registration &&
        other.phoneNumber == phoneNumber &&
        other.groupSize == groupSize;
  }

  @override
  int get hashCode => phoneNumber.hashCode ^ groupSize.hashCode;
}
