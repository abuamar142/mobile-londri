import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'command_tools.dart';

class FunctionPage extends StatefulWidget {
  final BluetoothDevice device;

  const FunctionPage(this.device, {super.key});

  @override
  State<FunctionPage> createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void deactivate() {
    super.deactivate();
    _disconnect();
  }

  void _disconnect() async {
    await BluetoothPrintPlus.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Input text",
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    Uint8List? cmd;
                    cmd = await CommandTool.escTemplateCmd(
                      _controller.text,
                    );

                    await BluetoothPrintPlus.write(cmd);
                  },
                  child: Text("Print"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
