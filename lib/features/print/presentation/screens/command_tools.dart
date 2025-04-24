import 'dart:typed_data';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';

class CommandTool {
  static final escCommand = EscCommand();

  static Future<Uint8List?> escTemplateCmd(String content) async {
    await escCommand.cleanCommand();
    await escCommand.sound();
    await escCommand.text(content: content);
    await escCommand.print(feedLines: 3);
    final cmd = await escCommand.getCommand();
    return cmd;
  }
}
