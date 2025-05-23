import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final PrinterService _printerService = serviceLocator<PrinterService>();
  final PermissionService _permissionService =
      serviceLocator<PermissionService>();
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _isLoading = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    setState(() {
      _isLoading = true;
    });

    // Request Bluetooth permissions using the permission service
    final permissionStatuses =
        await _permissionService.requestBluetoothPermissions();

    // Check if any permission was denied
    if (permissionStatuses.values.any((status) => !status.isGranted)) {
      if (mounted) {
        showSnackbar(context,
            "Bluetooth permissions are required for printer functionality");
      }
    }

    await _printerService.init();
    _selectedDevice = _printerService.selectedDevice;
    await _refreshDevices();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshDevices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _devices = await _printerService.getBondedDevices();
    } catch (e) {
      showSnackbar(context, "Failed to get devices: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _connectToDevice(BluetoothInfo device) async {
    setState(() {
      _isConnecting = true;
    });

    final bool connected = await _printerService.connectToDevice(device);

    setState(() {
      _isConnecting = false;
      _selectedDevice = connected ? device : _selectedDevice;
    });

    if (connected) {
      showSnackbar(context, "Connected to ${device.name}");
    } else {
      showSnackbar(context, "Failed to connect to ${device.name}");
    }
  }

  Future<void> _disconnectPrinter() async {
    await _printerService.disconnect();
    await _printerService.clearSavedPrinter();
    setState(() {
      _selectedDevice = null;
    });
    showSnackbar(context, "Disconnected from printer");
  }

  Future<void> _testPrint() async {
    if (!_printerService.isConnected) {
      showSnackbar(context, "Please connect to a printer first");
      return;
    }

    print('cobain');

    try {
      // Create a sample transaction for test printing
      final sampleTransaction = Transaction(
        id: "TEST12345",
        customerName: "Test Customer",
        serviceName: "Regular Wash",
        weight: 3.5,
        amount: 70000,
        description: "Test receipt printing",
        transactionStatus: TransactionStatus.onProgress,
        paymentStatus: PaymentStatus.paid,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now(),
      );

      final result = await _printerService.printReceipt(
        transaction: sampleTransaction,
        businessName: "LONDRI LAUNDRY",
        businessAddress: "Jl. Laundry No. 123, Jakarta",
        businessPhone: "0812-3456-7890",
      );

      if (result) {
        showSnackbar(context, "Test print successful");
      } else {
        showSnackbar(context, "Failed to print test receipt");
      }
    } catch (e) {
      showSnackbar(context, "Error while printing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Printer Settings",
          style: AppTextStyle.heading3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshDevices,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.size16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current printer status
              _buildCurrentPrinterStatus(),

              AppSizes.spaceHeight16,

              // Available devices
              Text(
                "Available Printers",
                style: AppTextStyle.heading3,
              ),
              AppSizes.spaceHeight8,

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildDevicesList(),
              ),

              AppSizes.spaceHeight16,

              // Test print button
              SizedBox(
                width: double.infinity,
                child: WidgetButton(
                  label: "Test Print",
                  onPressed: () => {
                    _printerService.isConnected ? _testPrint() : null,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPrinterStatus() {
    final bool isConnected = _printerService.isConnected;

    return Container(
      padding: EdgeInsets.all(AppSizes.size16),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.size12),
        border: Border.all(
          color: isConnected ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: isConnected ? AppColors.success : AppColors.warning,
              ),
              AppSizes.spaceWidth8,
              Text(
                "Printer Status",
                style: AppTextStyle.heading3,
              ),
            ],
          ),
          AppSizes.spaceHeight8,
          Text(
            isConnected
                ? "Connected to: ${_selectedDevice?.name ?? 'Unknown'}"
                : "Not connected to any printer",
            style: AppTextStyle.body1,
          ),
          if (isConnected) ...[
            AppSizes.spaceHeight8,
            GestureDetector(
              onTap: _disconnectPrinter,
              child: Text(
                "Disconnect",
                style: AppTextStyle.body2.copyWith(
                  color: AppColors.error,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    if (_devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 48,
              color: AppColors.gray,
            ),
            AppSizes.spaceHeight16,
            Text(
              "No bonded printers found",
              style: AppTextStyle.body1.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            AppSizes.spaceHeight8,
            Text(
              "Pair your printer in Bluetooth settings first,\nthen refresh this list",
              style: AppTextStyle.body2.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _devices.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final device = _devices[index];
        final bool isSelected = _selectedDevice?.macAdress == device.macAdress;

        return ListTile(
          leading: Icon(
            Icons.print,
            color: isSelected ? AppColors.primary : AppColors.gray,
          ),
          title: Text(
            device.name ?? "Unknown Device",
            style: AppTextStyle.body1.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : null,
            ),
          ),
          subtitle: Text(device.macAdress ?? ""),
          trailing: ElevatedButton(
            onPressed: _isConnecting ? null : () => _connectToDevice(device),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSelected ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(isSelected ? "Connected" : "Connect"),
          ),
          onTap: () => _connectToDevice(device),
        );
      },
    );
  }
}
