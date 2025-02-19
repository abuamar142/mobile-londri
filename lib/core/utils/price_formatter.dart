import 'package:intl/intl.dart';

extension PriceFormatter on int {
  String formatNumber() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }
}
