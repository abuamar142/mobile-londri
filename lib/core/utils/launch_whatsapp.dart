import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> launchWhatsapp({
  required String phone,
  required String? message,
}) async {
  phone = phone.replaceFirst('0', '62');

  String url() {
    if (isMobile) {
      return "https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message ?? '')}";
    } else {
      return "https://web.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message ?? '')}";
    }
  }

  if (await canLaunchUrlString(url())) {
    await launchUrlString(url());
  } else {
    await launchUrlString(
      "https://web.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message ?? '')}",
    );
  }
}

bool get isMobile => [
      TargetPlatform.iOS,
      TargetPlatform.android,
    ].contains(defaultTargetPlatform);
