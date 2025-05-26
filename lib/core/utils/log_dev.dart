import 'package:flutter/foundation.dart';

void logDev(
  String message, {
  bool isError = false,
}) {
  if (kDebugMode) {
    final logMessage = 'logdev: $message';
    if (isError) {
      print('ERROR: $logMessage');
    } else {
      print(logMessage);
    }
  }
}
