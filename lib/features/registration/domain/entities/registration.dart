import 'package:catch_table/core/extensions/string_extensions.dart';
import 'package:flutter/foundation.dart';

@immutable
class Registration {
  const Registration({this.phoneNumber, this.groupSize});

  final String? phoneNumber;
  final int? groupSize;

  Registration copyWith({String? phoneNumber, int? groupSize}) {
    return Registration(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      groupSize: groupSize ?? this.groupSize,
    );
  }

  // raw 번호를 포맷된 형식으로 반환
  // 예) 09171234567 -> 0917-123-4567
  String get formattedPhoneNumber {
    if (phoneNumber == null) return '';
    return phoneNumber!.formatPhilippinePhoneNumber();
  }

  @override
  String toString() =>
      'Registration(phoneNumber: $phoneNumber, groupSize: $groupSize)';

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
