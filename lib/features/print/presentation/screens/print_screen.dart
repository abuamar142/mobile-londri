import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';

import 'function_page.dart';

class PrintScreen extends StatefulWidget {
  const PrintScreen({super.key});

  @override
  State<PrintScreen> createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  BluetoothDevice? _device;
  List<BluetoothDevice> _scanResults = [];
  late final StreamSubscription<bool> _isScanningSubscription;
  late final StreamSubscription<BlueState> _blueStateSubscription;
  late final StreamSubscription<ConnectState> _connectStateSubscription;
  late final StreamSubscription<Uint8List> _receivedDataSubscription;
  late final StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _initializeBluetoothListeners();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _scanResults.clear();
    super.dispose();
  }

  void _initializeBluetoothListeners() {
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((devices) {
      if (mounted) {
        setState(() => _scanResults = devices);
      }
    });

    _isScanningSubscription =
        BluetoothPrintPlus.isScanning.listen((isScanning) {
      debugPrint('Scanning: $isScanning');
      if (mounted) setState(() {});
    });

    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((state) {
      debugPrint('Bluetooth state: $state');
      if (mounted) setState(() {});
    });

    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((state) {
      debugPrint('Connection state: $state');
      _handleConnectionState(state);
    });

    _receivedDataSubscription = BluetoothPrintPlus.receivedData.listen((data) {
      debugPrint('Received data: $data');
      // Handle received data here
    });
  }

  void _cancelSubscriptions() {
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
  }

  void _handleConnectionState(ConnectState state) {
    switch (state) {
      case ConnectState.connected:
        if (_device != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FunctionPage(_device!)),
          );
        }
        break;
      case ConnectState.disconnected:
        setState(() => _device = null);
        break;
    }
  }

  Future<void> _startScan() async {
    try {
      await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _stopScan() {
    try {
      BluetoothPrintPlus.stopScan();
    } catch (e) {
      debugPrint('Stop scan error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BluetoothPrintPlus')),
      body: SafeArea(
        child: BluetoothPrintPlus.isBlueOn
            ? _buildDeviceList()
            : _buildBluetoothOffMessage(),
      ),
      floatingActionButton:
          BluetoothPrintPlus.isBlueOn ? _buildScanButton() : null,
    );
  }

  Widget _buildDeviceList() {
    return ListView(
      children: _scanResults.map((device) => _buildDeviceTile(device)).toList(),
    );
  }

  Widget _buildDeviceTile(BluetoothDevice device) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name),
                Text(
                  device.address,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () async {
              _device = device;
              await BluetoothPrintPlus.connect(device);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothOffMessage() {
    return const Center(
      child: Text(
        'Bluetooth is turned off\nPlease turn on Bluetooth...',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Colors.red,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildScanButton() {
    return FloatingActionButton(
      onPressed: BluetoothPrintPlus.isScanningNow ? _stopScan : _startScan,
      backgroundColor:
          BluetoothPrintPlus.isScanningNow ? Colors.red : Colors.green,
      child: Icon(
        BluetoothPrintPlus.isScanningNow ? Icons.stop : Icons.search,
      ),
    );
  }
}
