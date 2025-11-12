extension PhoneExtension on String {
  String formatPhilippinePhoneNumber() {
    final digits = replaceAll(RegExp(r'\D'), '');

    String local;

    if (digits.startsWith('63') && digits.length == 12) {
      local = '0${digits.substring(2)}'; // 63917... → 0917...
    } else if (digits.startsWith('9') && digits.length == 10) {
      local = '0$digits'; // 917... → 0917...
    } else if (digits.startsWith('09') && digits.length == 11) {
      local = digits;
    } else {
      return this;
    }

    if (local.length != 11) return this;

    final part1 = local.substring(0, 4);
    final part2 = local.substring(4, 7);
    final part3 = local.substring(7, 11);

    return '$part1-$part2-$part3';
  }
}
