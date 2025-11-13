/// Store Domain Entity - 매장 정보
///
/// 매장의 기본 정보를 담는 불변 객체입니다.
class Store {
  const Store({
    required this.id,
    required this.name,
    required this.pin,
    this.logoUrl,
    this.contact,
    this.address,
  });

  final String id;
  final String name;
  final String pin;
  final String? logoUrl;
  final String? contact;
  final String? address;

  /// PIN 번호 유효성 검증 (4~6자리 숫자)
  bool get isValidPin {
    final pinLength = pin.length;
    return pinLength >= 4 &&
        pinLength <= 6 &&
        RegExp(r'^\d+$').hasMatch(pin);
  }

  /// 매장 정보가 완전한지 검증
  bool get isComplete => name.isNotEmpty && isValidPin;

  /// 불변 객체 업데이트 패턴
  Store copyWith({
    String? id,
    String? name,
    String? pin,
    String? logoUrl,
    String? contact,
    String? address,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      pin: pin ?? this.pin,
      logoUrl: logoUrl ?? this.logoUrl,
      contact: contact ?? this.contact,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Store &&
        other.id == id &&
        other.name == name &&
        other.pin == pin &&
        other.logoUrl == logoUrl &&
        other.contact == contact &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        pin.hashCode ^
        logoUrl.hashCode ^
        contact.hashCode ^
        address.hashCode;
  }

  @override
  String toString() {
    return 'Store(id: $id, name: $name, pin: $pin, logoUrl: $logoUrl, contact: $contact, address: $address)';
  }
}
