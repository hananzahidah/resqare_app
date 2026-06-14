import 'package:intl/intl.dart';

class DateFormatter {
  static String toReadableDateTime(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
    } catch (e) {
      return '-';
    }
  }

  static String toTimeOnly(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(parsedDate);
    } catch (e) {
      return '-';
    }
  }
}
