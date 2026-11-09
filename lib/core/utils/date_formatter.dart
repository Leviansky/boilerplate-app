import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  static String formatDateTime(DateTime dateTime) {
    return _displayFormat.format(dateTime);
  }

  static String formatDateOnly(DateTime dateTime) {
    return _shortDateFormat.format(dateTime);
  }

  static String formatIso8601(DateTime dateTime) {
    return _isoFormat.format(dateTime.toUtc());
  }

  static DateTime? tryParseIso(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }
}
