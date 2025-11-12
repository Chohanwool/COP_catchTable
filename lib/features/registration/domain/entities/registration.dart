import 'package:catch_table/core/extensions/string_extensions.dart';

/// Domain Entity - 대기 등록 정보
///
/// nullable 필드를 사용하여 점진적인 폼 작성을 지원합니다.
/// 완전한 데이터가 입력되면 isComplete로 검증할 수 있습니다.
class Registration {
  const Registration({this.phoneNumber, this.groupSize});

  final String? phoneNumber;
  final int? groupSize;

  // 비즈니스 검증 로직
  bool get isValidPhoneNumber =>
      phoneNumber != null &&
      phoneNumber!.length == 11 &&
      phoneNumber!.startsWith('09');

  bool get isValidGroupSize =>
      groupSize != null && groupSize! >= 1 && groupSize! <= 20;

  bool get isComplete => phoneNumber != null && groupSize != null;

  bool get isValid => isValidPhoneNumber && isValidGroupSize;

  // 비즈니스 규칙
  bool get isLargeGroup => groupSize != null && groupSize! > 10;

  bool get isSmallGroup => groupSize != null && groupSize! <= 2;

  // 불변 객체 업데이트 패턴
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
