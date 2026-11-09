import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// Zero-Float Monetary Architecture:
  /// Amount MUST be an integer in minor unit (Rupiah bulat, e.g. 50000 -> "Rp50.000").
  static String formatRupiah(int amountInMinor) {
    return _rupiahFormat.format(amountInMinor);
  }

  /// Optional BigInt support for massive transactions
  static String formatRupiahBigInt(BigInt amount) {
    return _rupiahFormat.format(amount.toInt());
  }

  /// Compact format for large numbers in badges/analytics (e.g. 1.2jt)
  static String formatCompactRupiah(int amountInMinor) {
    if (amountInMinor >= 1000000000) {
      final val = amountInMinor / 1000000000.0;
      return 'Rp${val.toStringAsFixed(1)}M';
    } else if (amountInMinor >= 1000000) {
      final val = amountInMinor / 1000000.0;
      return 'Rp${val.toStringAsFixed(1)}jt';
    } else if (amountInMinor >= 1000) {
      final val = amountInMinor / 1000.0;
      return 'Rp${val.toStringAsFixed(0)}rb';
    }
    return formatRupiah(amountInMinor);
  }
}
