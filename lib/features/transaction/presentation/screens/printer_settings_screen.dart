import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';

Future<bool> pushPrinterSettings({
  required BuildContext context,
}) async {
  await context.pushNamed(RouteNames.printerSettings);
  return true;
}

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final PrinterService _printerService = serviceLocator<PrinterService>();
  final PermissionService _permissionService = serviceLocator<PermissionService>();

  BluetoothInfo? _selectedDevice;

  List<BluetoothInfo> _devices = [];

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
    final permissionStatuses = await _permissionService.requestBluetoothPermissions();

    // Check if any permission was denied
    if (permissionStatuses.values.any((status) => !status.isGranted)) {
      if (mounted) {
        context.showSnackbar(context.appText.printer_permissions_required);
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
      if (mounted) {
        context.showSnackbar(context.appText.printer_print_error(e.toString()));
      }
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

    if (mounted) {
      if (connected) {
        context.showSnackbar(context.appText.printer_connect_success(device.name));
      } else {
        context.showSnackbar(context.appText.printer_connect_failed(device.name));
      }
    }
  }

  Future<void> _disconnectPrinter() async {
    await _printerService.disconnect();
    await _printerService.clearSavedPrinter();

    setState(() {
      _selectedDevice = null;
    });

    if (mounted) {
      context.showSnackbar(context.appText.printer_disconnect_success);
    }
  }

  Future<void> _testPrint() async {
    if (!_printerService.isConnected) {
      context.showSnackbar(context.appText.printer_please_connect);
      return;
    }

    try {
      // Create a sample transaction for test printing
      final sampleTransaction = Transaction(
        id: "TEST12345",
        customerName: "Test Customer",
        serviceName: "Regular Wash",
        weight: 3.5,
        amount: 70000,
        description: "Test invoice printing",
        transactionStatus: TransactionStatus.onProgress,
        paymentStatus: PaymentStatus.paid,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(
          const Duration(
            days: 3,
          ),
        ),
        createdAt: DateTime.now(),
      );

      final result = await _printerService.printInvoice(
        transaction: sampleTransaction,
        businessName: "Laundry Now",
        businessAddress: "Jl. Jalan",
        businessPhone: "0812-xxxx-xxxx",
      );

      if (mounted) {
        if (result) {
          context.showSnackbar(context.appText.printer_test_print_success);
        } else {
          context.showSnackbar(context.appText.printer_test_print_failed);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackbar(context.appText.printer_print_error(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(
        title: context.appText.printer_settings_screen_title,
        action: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _refreshDevices,
          tooltip: context.appText.printer_refresh_devices,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.size16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentPrinterStatus(),

              AppSizes.spaceHeight16,

              // Available devices
              Text(
                context.appText.printer_available_printers,
                style: AppTextStyle.heading3,
              ),
              AppSizes.spaceHeight8,

              Expanded(
                child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildDevicesList(),
              ),

              AppSizes.spaceHeight16,

              // Test print button
              SizedBox(
                width: double.infinity,
                child: WidgetButton(
                  label: context.appText.printer_test_print,
                  onPressed: () => _printerService.isConnected ? _testPrint() : null,
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
        color: isConnected ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
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
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: isConnected ? AppColors.success : AppColors.warning,
              ),
              AppSizes.spaceWidth8,
              Text(
                context.appText.printer_settings_screen_title,
                style: AppTextStyle.heading3,
              ),
            ],
          ),
          AppSizes.spaceHeight8,
          Text(
            isConnected ? context.appText.printer_status_connected(_selectedDevice?.name ?? '-') : context.appText.printer_status_not_connected,
            style: AppTextStyle.body1,
          ),
          if (isConnected) ...[
            AppSizes.spaceHeight8,
            GestureDetector(
              onTap: _disconnectPrinter,
              child: Text(
                context.appText.printer_disconnect,
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
              size: AppSizes.size64,
              color: AppColors.gray,
            ),
            AppSizes.spaceHeight16,
            Text(
              context.appText.printer_no_printers_found,
              style: AppTextStyle.body1.copyWith(color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            AppSizes.spaceHeight8,
            Text(
              context.appText.printer_pair_instruction,
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
            device.name,
            style: AppTextStyle.body1.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : null,
            ),
          ),
          subtitle: Text(device.macAdress),
          trailing: ElevatedButton(
            onPressed: _isConnecting ? null : () => _connectToDevice(device),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(isSelected ? context.appText.printer_connected : context.appText.printer_connect),
          ),
          onTap: () => _connectToDevice(device),
        );
      },
    );
  }
}
