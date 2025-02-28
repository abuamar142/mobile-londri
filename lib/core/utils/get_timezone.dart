import 'dart:io';

import 'package:flutter_timezone/flutter_timezone.dart';

class AppTimezone {
  static Future<String> getCurrentTimezone() async {
    late String currentTimeZone;

    if (Platform.isAndroid || Platform.isIOS) {
      currentTimeZone = await FlutterTimezone.getLocalTimezone();
    } else if (Platform.isLinux) {
      currentTimeZone = 'Asia/Jakarta';
    } else {
      currentTimeZone = 'Asia/Jakarta';
    }
    return currentTimeZone;
  }
}
