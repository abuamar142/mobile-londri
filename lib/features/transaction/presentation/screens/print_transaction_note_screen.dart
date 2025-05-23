import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import 'printer_settings_screen.dart';

void pushPrintTransactionNoteScreen({
  required BuildContext context,
  String? transactionId,
}) {
  context.pushNamed(
    'print-transaction',
    pathParameters: {
      'id': transactionId.toString(),
    },
  );
}

class PrintTransactionNoteScreen extends StatefulWidget {
  final String? transactionId;

  const PrintTransactionNoteScreen({
    super.key,
    this.transactionId,
  });

  @override
  State<PrintTransactionNoteScreen> createState() =>
      _PrintTransactionNoteScreenState();
}

class _PrintTransactionNoteScreenState
    extends State<PrintTransactionNoteScreen> {
  final PrinterService _printerService = PrinterService();
  late final TransactionBloc _transactionBloc;
  Transaction? _transaction;
  BluetoothInfo? _selectedPrinter;
  bool _isLoading = true;
  bool _isPrinting = false;
  final TextEditingController _businessNameController =
      TextEditingController(text: "LONDRI LAUNDRY");
  final TextEditingController _businessAddressController =
      TextEditingController(text: "Jl. Laundry No. 123");
  final TextEditingController _businessPhoneController =
      TextEditingController(text: "0812-3456-7890");

  @override
  void initState() {
    super.initState();
    _transactionBloc = serviceLocator<TransactionBloc>();
    _loadData();

    // Listen for printer device changes
    _printerService.selectedDeviceStream.listen((device) {
      if (mounted) {
        setState(() {
          _selectedPrinter = device;
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Initialize printer service
    await _printerService.init();
    _selectedPrinter = _printerService.selectedDevice;

    // Get transaction data
    if (widget.transactionId != null) {
      _transactionBloc.add(TransactionEventGetTransactionById(
        id: widget.transactionId!,
      ));
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    super.dispose();
  }

  Future<void> _printReceipt() async {
    if (_transaction == null) {
      showSnackbar(context, "Transaction data not available");
      return;
    }

    if (!_printerService.isConnected) {
      final bool reconnected = await _printerService.connectToSavedPrinter();
      if (!reconnected) {
        showSnackbar(context, "Please connect to a printer first");
        return;
      }
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      final result = await _printerService.printReceipt(
        transaction: _transaction!,
        businessName: _businessNameController.text,
        businessAddress: _businessAddressController.text,
        businessPhone: _businessPhoneController.text,
      );

      if (result) {
        showSnackbar(context, "Receipt printed successfully");
      } else {
        showSnackbar(context, "Failed to print receipt");
      }
    } catch (e) {
      showSnackbar(context, "Error while printing: $e");
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  void _navigateToPrinterSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrinterSettingsScreen(),
      ),
    );

    // Refresh printer status
    if (mounted) {
      setState(() {
        _selectedPrinter = _printerService.selectedDevice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateSuccessGetTransactionById) {
            setState(() {
              _transaction = state.transaction;
              _isLoading = false;
            });
          } else if (state is TransactionStateFailure) {
            showSnackbar(context, state.message);
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Print Transaction Receipt',
              style: AppTextStyle.heading3,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: _navigateToPrinterSettings,
                icon: Icon(Icons.settings),
                tooltip: 'Printer Settings',
              ),
            ],
          ),
          body: _isLoading
              ? WidgetLoading(usingPadding: true)
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.size16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Printer status
                        _buildPrinterStatus(),

                        AppSizes.spaceHeight16,

                        // Business information form
                        Text(
                          "Business Information",
                          style: AppTextStyle.heading3,
                        ),
                        AppSizes.spaceHeight8,

                        _buildBusinessForm(),

                        AppSizes.spaceHeight16,

                        // Receipt preview
                        Expanded(
                          child: _buildReceiptPreview(appText),
                        ),

                        AppSizes.spaceHeight16,

                        // Print button
                        SizedBox(
                          width: double.infinity,
                          child: WidgetButton(
                            label: "Print Receipt",
                            isLoading: _isPrinting,
                            onPressed: () => {
                              if (_transaction != null)
                                {_printReceipt()}
                              else
                                {
                                  showSnackbar(
                                    context,
                                    "No transaction data available",
                                  )
                                }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPrinterStatus() {
    final bool isConnected = _printerService.isConnected;

    return Container(
      padding: EdgeInsets.all(AppSizes.size12),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.size8),
        border: Border.all(
          color: isConnected ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isConnected ? AppColors.success : AppColors.warning,
          ),
          AppSizes.spaceWidth8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? "Printer Connected" : "No Printer Connected",
                  style: AppTextStyle.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isConnected && _selectedPrinter != null)
                  Text(
                    _selectedPrinter!.name,
                    style: AppTextStyle.body2,
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _navigateToPrinterSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isConnected ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.size12,
                vertical: AppSizes.size8,
              ),
            ),
            child: Text(isConnected ? "Change" : "Connect"),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      children: [
        TextFormField(
          controller: _businessNameController,
          decoration: InputDecoration(
            labelText: "Business Name",
            border: OutlineInputBorder(),
          ),
        ),
        AppSizes.spaceHeight8,
        TextFormField(
          controller: _businessAddressController,
          decoration: InputDecoration(
            labelText: "Business Address",
            border: OutlineInputBorder(),
          ),
        ),
        AppSizes.spaceHeight8,
        TextFormField(
          controller: _businessPhoneController,
          decoration: InputDecoration(
            labelText: "Business Phone",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptPreview(AppLocalizations appText) {
    if (_transaction == null) {
      return Center(
        child: Text("No transaction data available"),
      );
    }

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.size8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.size16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _businessNameController.text,
                style: AppTextStyle.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                _businessAddressController.text,
                style: AppTextStyle.body1,
                textAlign: TextAlign.center,
              ),
              Text(
                _businessPhoneController.text,
                style: AppTextStyle.body1,
                textAlign: TextAlign.center,
              ),
              AppSizes.spaceHeight16,

              Text(
                "RECEIPT",
                style: AppTextStyle.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(thickness: 1),

              // Transaction info
              _buildReceiptRow(
                label: "Trans ID:",
                value:
                    "#${_transaction!.id!.substring(0, min(8, _transaction!.id!.length)).toUpperCase()}",
              ),
              _buildReceiptRow(
                label: "Date:",
                value: _transaction!.createdAt?.formatDateOnly() ?? "-",
              ),
              _buildReceiptRow(
                label: "Customer:",
                value: _transaction!.customerName ?? "-",
              ),

              Divider(thickness: 1),

              // Service details
              _buildReceiptRow(
                label: "Service:",
                value: _transaction!.serviceName ?? "-",
              ),
              _buildReceiptRow(
                label: "Weight:",
                value: "${_transaction!.weight} kg",
              ),
              _buildReceiptRow(
                label: "Price:",
                value: "Rp ${_transaction!.amount?.formatNumber() ?? '0'}",
              ),

              Divider(thickness: 1),

              // Status information
              _buildReceiptRow(
                label: "Status:",
                value: _transaction!.transactionStatus?.value ?? "-",
              ),
              _buildReceiptRow(
                label: "Payment:",
                value: _transaction!.paymentStatus?.value ?? "-",
              ),

              if (_transaction!.startDate != null)
                _buildReceiptRow(
                  label: "Start Date:",
                  value: _transaction!.startDate?.formatDateOnly() ?? "-",
                ),

              if (_transaction!.endDate != null)
                _buildReceiptRow(
                  label: "End Date:",
                  value: _transaction!.endDate?.formatDateOnly() ?? "-",
                ),

              Divider(thickness: 1),

              // Notes
              if (_transaction!.description != null &&
                  _transaction!.description!.isNotEmpty) ...[
                AppSizes.spaceHeight8,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Notes:",
                    style: AppTextStyle.body1
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                AppSizes.spaceHeight4,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _transaction!.description!,
                    style: AppTextStyle.body1,
                  ),
                ),
                AppSizes.spaceHeight8,
              ],

              AppSizes.spaceHeight16,
              Text(
                "Thank you for your business!",
                style: AppTextStyle.body1.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyle.body1.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.body1,
            ),
          ),
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
