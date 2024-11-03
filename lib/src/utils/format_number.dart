// lib/utils/format_number.dart
import 'package:intl/intl.dart';

String formatNumber(String number, {int decimalDigits = 0}) {
  final double? parsedNumber = double.tryParse(number);
  if (parsedNumber != null) {
    if (parsedNumber == parsedNumber.roundToDouble()) {
      return NumberFormat('#,###', 'en_US').format(parsedNumber);
    }
    return NumberFormat('###,###,##0.${'0' * decimalDigits}', 'en_US')
        .format(parsedNumber);
  }
  return number;
}
