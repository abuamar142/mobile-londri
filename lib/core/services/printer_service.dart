import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/post_code.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/transaction/domain/entities/payment_status.dart';
import '../../features/transaction/domain/entities/transaction.dart';
import '../../features/transaction/domain/entities/transaction_status.dart';
import '../utils/context_extensions.dart';
import '../utils/date_formatter.dart';
import '../utils/price_formatter.dart';

class PrinterService {
  static const String _printerKeyPref = 'selected_printer_address';

  List<BluetoothInfo> _devices = [];

  BluetoothInfo? _selectedDevice;

  bool _isConnected = false;

  final _selectedDeviceController = StreamController<BluetoothInfo?>.broadcast();

  Stream<BluetoothInfo?> get selectedDeviceStream => _selectedDeviceController.stream;
  bool get isConnected => _isConnected;
  BluetoothInfo? get selectedDevice => _selectedDevice;

  Future<void> init() async {
    try {
      debugPrint("Initializing Printer Service");

      // Check current connection status
      final bool isConnected = await PrintBluetoothThermal.connectionStatus;
      debugPrint("Initial connection status: $isConnected");
      _isConnected = isConnected;

      // Load saved printer from preferences
      await _loadSavedPrinter();

      // Automatically connect to saved printer if available
      if (_selectedDevice != null && !_isConnected) {
        debugPrint("Attempting to connect to saved printer: ${_selectedDevice?.name}");
        await connectToSavedPrinter();
      }
    } catch (e, stackTrace) {
      debugPrint('Printer initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPrinterAddress = prefs.getString(_printerKeyPref);
      debugPrint("Saved printer address: $savedPrinterAddress");

      if (savedPrinterAddress != null) {
        // Get list of bonded devices
        final devices = await getBondedDevices();

        // Find the saved device
        try {
          _selectedDevice = devices.firstWhere(
            (device) => device.macAdress == savedPrinterAddress,
          );
          debugPrint("Found saved printer: ${_selectedDevice?.name}");

          // Notify listeners
          _selectedDeviceController.add(_selectedDevice);
        } catch (e) {
          debugPrint("Saved printer not found in paired devices: $e");
        }
      }
    } catch (e) {
      debugPrint('Error loading saved printer: $e');
    }
  }

  Future<bool> _savePrinter(BluetoothInfo device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_printerKeyPref, device.macAdress);
      debugPrint("Saved printer: ${device.name} with address: ${device.macAdress}");
      return true;
    } catch (e) {
      debugPrint('Error saving printer: $e');
      return false;
    }
  }

  Future<bool> clearSavedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_printerKeyPref);
      debugPrint("Cleared saved printer");
      return true;
    } catch (e) {
      debugPrint('Error clearing saved printer: $e');
      return false;
    }
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      _devices = await PrintBluetoothThermal.pairedBluetooths;
      debugPrint("Found ${_devices.length} paired devices");
      for (var device in _devices) {
        debugPrint("Device: ${device.name}, Address: ${device.macAdress}");
      }
      return _devices;
    } catch (e, stackTrace) {
      debugPrint('Error getting bonded devices: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<bool> connectToDevice(BluetoothInfo device) async {
    try {
      debugPrint("Attempting to connect to: ${device.name} (${device.macAdress})");

      // Check if we need to disconnect first
      final bool currentlyConnected = await PrintBluetoothThermal.connectionStatus;
      if (currentlyConnected == true) {
        debugPrint("Already connected to a device, disconnecting first");
        await PrintBluetoothThermal.disconnect;
        // Short delay to ensure disconnect completes
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Try connecting with retries
      bool result = false;
      int retries = 0;
      const maxRetries = 3;

      while (!result && retries < maxRetries) {
        debugPrint("Connection attempt ${retries + 1}/$maxRetries");

        result = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macAdress,
        );

        debugPrint("Connection result: $result");

        if (!result) {
          retries++;
          if (retries < maxRetries) {
            debugPrint("Retrying in 1 second...");
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }

      if (result) {
        _isConnected = true;
        _selectedDevice = device;
        _selectedDeviceController.add(_selectedDevice);

        // Save printer for future use
        await _savePrinter(device);
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      debugPrint('Error connecting to device: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> connectToSavedPrinter() async {
    if (_selectedDevice == null) {
      debugPrint("No saved printer to connect to");
      return false;
    }

    debugPrint("Attempting to connect to saved printer: ${_selectedDevice?.name}");
    return await connectToDevice(_selectedDevice!);
  }

  Future<bool> disconnect() async {
    try {
      debugPrint("Disconnecting from printer");
      await PrintBluetoothThermal.disconnect;
      _isConnected = false;
      return true;
    } catch (e) {
      debugPrint('Error disconnecting printer: $e');
      return false;
    }
  }

  Future<bool> printInvoice({
    required BuildContext context,
    required Transaction transaction,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
  }) async {
    if (!_isConnected) {
      return false;
    }

    try {
      // Set printer configuration
      await PrintBluetoothThermal.writeBytes(
        await getInvoiceBytes(
          context: context,
          transaction: transaction,
          businessName: businessName,
          businessAddress: businessAddress,
          businessPhone: businessPhone,
        ),
      );

      return true;
    } catch (e) {
      debugPrint('Error printing invoice: $e');
      return false;
    }
  }

  Future<bool> printTest({required BuildContext context}) async {
    if (!_isConnected) {
      return false;
    }

    try {
      await PrintBluetoothThermal.writeBytes(
        PostCode.text(text: 'Test Print', fontSize: FontSize.normal, align: AlignPos.center, bold: true) +
            PostCode.text(text: 'This is a test print.', fontSize: FontSize.compressed, align: AlignPos.center) +
            PostCode.enter(),
      );

      return true;
    } catch (e) {
      if (context.mounted) {
        context.showSnackbar(context.appText.printer_print_error(e.toString()));
      }
      return false;
    }
  }

  Future<List<int>> getInvoiceBytes({
    required BuildContext context,
    required Transaction transaction,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
  }) async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    final userName = transaction.userName ?? '-';
    final transactionId = transaction.id?.toString() ?? '-';
    final dateToday = DateTime.now().formatDateOnly();

    final startDate = transaction.startDate?.formatddMMyyyy() ?? '-';
    final endDate = transaction.endDate?.formatddMMyyyy() ?? '-';

    // ======= Header =======
    bytes += generator.setGlobalFont(PosFontType.fontB);
    bytes += PostCode.text(text: businessName, fontSize: FontSize.normal, align: AlignPos.center, bold: true);
    bytes += PostCode.text(text: businessAddress, fontSize: FontSize.compressed, align: AlignPos.center);
    bytes += PostCode.text(text: businessPhone, fontSize: FontSize.compressed, align: AlignPos.center);

    bytes += generator.hr();
    if (context.mounted) bytes += PostCode.text(text: context.appText.invoice_print_title, fontSize: FontSize.normal, align: AlignPos.center, bold: true);
    bytes += PostCode.text(text: '$transactionId | $dateToday', fontSize: FontSize.compressed, align: AlignPos.center);
    bytes += generator.hr();

    // ======= Key-Value Detail =======
    if (context.mounted) {
      final Map<String, String> data = {
        context.appText.invoice_print_customer_name: transaction.customerName ?? '-',
        context.appText.invoice_print_service_name: transaction.serviceName ?? '-',
        context.appText.invoice_print_weight: '${transaction.weight ?? '-'} kg',
        context.appText.invoice_print_amount: transaction.amount?.formatNumber() ?? '-',
        context.appText.invoice_print_notes: transaction.description ?? '-',
        context.appText.invoice_print_staff_name: userName
      };

      final maxKeyLength = data.keys.map((k) => k.length).reduce((a, b) => a > b ? a : b);
      data.forEach((key, value) {
        final paddedKey = key.padRight(maxKeyLength);
        bytes += PostCode.text(text: '$paddedKey : $value', fontSize: FontSize.compressed);
      });
    }

    bytes += generator.setStyles(PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // ======= Dates & Status =======
    bytes += PostCode.text(text: '$startDate -> $endDate', fontSize: FontSize.compressed, align: AlignPos.center);

    if (context.mounted) {
      final transactionStatus = getTransactionStatusValue(context, transaction.transactionStatus ?? TransactionStatus.other);
      final paymentStatus = getPaymentStatusValue(context, transaction.paymentStatus ?? PaymentStatus.other);

      bytes += PostCode.text(
        text: '$transactionStatus | $paymentStatus',
        fontSize: FontSize.compressed,
        align: AlignPos.center,
      );
    }

    bytes += generator.hr();

    // ======= Thank You =======
    if (context.mounted) {
      final thankYouMessage = context.appText.invoice_print_thank_you;
      bytes += PostCode.text(text: thankYouMessage, fontSize: FontSize.compressed, align: AlignPos.center);
    }

    bytes += PostCode.enter();
    return bytes;
  }
}
