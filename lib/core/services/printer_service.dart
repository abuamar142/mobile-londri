import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/transaction/domain/entities/transaction.dart';

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

  Future<bool> printReceipt({
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
        await getReceiptBytes(
          transaction: transaction,
          businessName: businessName,
          businessAddress: businessAddress,
          businessPhone: businessPhone,
        ),
      );

      return true;
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      return false;
    }
  }

  Future<List<int>> getReceiptBytes({
    required Transaction transaction,
    required String businessName,
    required String businessAddress,
    required String businessPhone,
  }) async {
    List<int> bytes = [];

    // Add ESC/POS commands for receipt formatting
    // Center align and text size commands
    bytes += [27, 97, 1]; // Center align
    bytes += [27, 33, 16]; // Double height text

    // Business information
    bytes += latin1.encode('$businessName\n');
    bytes += [27, 33, 0]; // Normal text
    bytes += latin1.encode('$businessAddress\n');
    bytes += latin1.encode('$businessPhone\n\n');

    // Receipt title
    bytes += [27, 33, 16]; // Double height text
    bytes += latin1.encode('RECEIPT\n');
    bytes += [27, 33, 0]; // Normal text
    bytes += latin1.encode('--------------------------------\n');

    // Transaction details
    final transId = transaction.id != null ? "#${transaction.id!.substring(0, min(8, transaction.id!.length)).toUpperCase()}" : "-";

    bytes += latin1.encode('Trans ID: $transId\n');
    bytes += latin1.encode('Date: ${transaction.createdAt?.toString().substring(0, 10) ?? "-"}\n');
    bytes += latin1.encode('Customer: ${transaction.customerName ?? "-"}\n');
    bytes += latin1.encode('--------------------------------\n');

    // Service information
    bytes += latin1.encode('Service: ${transaction.serviceName ?? "-"}\n');
    bytes += latin1.encode('Weight: ${transaction.weight} kg\n');

    // Format amount with thousand separators
    final amount = transaction.amount ?? 0;
    final formattedAmount = amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    bytes += latin1.encode('Price: Rp $formattedAmount\n');
    bytes += latin1.encode('--------------------------------\n');

    // Status information
    bytes += latin1.encode('Status: ${transaction.transactionStatus?.value ?? "-"}\n');
    bytes += latin1.encode('Payment: ${transaction.paymentStatus?.value ?? "-"}\n');

    if (transaction.startDate != null) {
      bytes += latin1.encode('Start Date: ${transaction.startDate!.toString().substring(0, 10)}\n');
    }

    if (transaction.endDate != null) {
      bytes += latin1.encode('End Date: ${transaction.endDate!.toString().substring(0, 10)}\n');
    }

    bytes += latin1.encode('--------------------------------\n');

    // Notes section
    if (transaction.description != null && transaction.description!.isNotEmpty) {
      bytes += latin1.encode('Notes:\n${transaction.description}\n');
      bytes += latin1.encode('--------------------------------\n');
    }

    // Thank you message
    bytes += [27, 97, 1]; // Center align
    bytes += latin1.encode('\nThank you for your business!\n\n\n');

    // Cut paper command
    bytes += [29, 86, 66, 0];

    return bytes;
  }

  int min(int a, int b) => a < b ? a : b;
}
