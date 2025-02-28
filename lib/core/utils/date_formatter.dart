import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../config/l10n/l10n.dart';

extension DateFormatter on DateTime {
  String formatDateTime() {
    final localTime = tz.TZDateTime.from(
      this,
      tz.local,
    );

    return DateFormat(
      'EEEE, dd MMM, HH:mm',
      AppLocales.getLocale.toString(),
    ).format(
      localTime,
    );
  }
}
