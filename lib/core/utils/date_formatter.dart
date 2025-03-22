import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../config/i18n/i18n.dart';

extension DateFormatter on DateTime {
  String formatDateTime() {
    final localTime = tz.TZDateTime.from(
      this,
      tz.local,
    );

    return DateFormat(
      'EEEE, dd MMM, HH:mm',
      AppLocales.localeNotifier.value.toString(),
    ).format(
      localTime,
    );
  }
}
