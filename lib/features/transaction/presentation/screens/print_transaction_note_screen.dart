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
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_bottom_bar.dart';
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
  State<PrintTransactionNoteScreen> createState() => _PrintTransactionNoteScreenState();
}

class _PrintTransactionNoteScreenState extends State<PrintTransactionNoteScreen> {
  final PrinterService _printerService = serviceLocator<PrinterService>();
  late final TransactionBloc _transactionBloc;

  Transaction? _transaction;
  BluetoothInfo? _selectedPrinter;

  bool _isLoading = true;
  bool _isPrinting = false;

  final TextEditingController _businessNameController = TextEditingController(text: 'Londri');
  final TextEditingController _businessAddressController = TextEditingController(text: 'Jl. Raya No. 123, Jakarta');
  final TextEditingController _businessPhoneController = TextEditingController(text: '0812-3456-7890');

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
    final appText = AppLocalizations.of(context)!;

    if (_transaction == null) {
      showSnackbar(context, appText.printer_no_transaction_data);
      return;
    }

    if (!_printerService.isConnected) {
      final bool reconnected = await _printerService.connectToSavedPrinter();
      if (!reconnected) {
        if (mounted) showSnackbar(context, appText.printer_please_connect);
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
        if (mounted) showSnackbar(context, appText.printer_receipt_success);
      } else {
        if (mounted) showSnackbar(context, appText.printer_receipt_failed);
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(
          context,
          appText.printer_print_error(
            e.toString(),
          ),
        );
      }
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
          appBar: WidgetAppBar(
            label: appText.print_transaction_screen_title,
            action: IconButton(
              onPressed: _navigateToPrinterSettings,
              icon: Icon(Icons.settings),
              tooltip: appText.printer_settings_screen_title,
            ),
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
                        _buildPrinterStatus(appText),

                        AppSizes.spaceHeight16,

                        // Business information form
                        Text(
                          appText.printer_business_info,
                          style: AppTextStyle.heading3,
                        ),
                        AppSizes.spaceHeight8,

                        _buildBusinessForm(appText),

                        AppSizes.spaceHeight16,

                        // Receipt preview
                        Expanded(
                          child: _buildReceiptPreview(appText),
                        ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: WidgetBottomBar(content: [
            WidgetButton(
              label: appText.printer_print_receipt,
              isLoading: _isPrinting,
              onPressed: () => _transaction != null ? _printReceipt() : null,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPrinterStatus(AppLocalizations appText) {
    final bool isConnected = _printerService.isConnected;

    return Container(
      padding: EdgeInsets.all(AppSizes.size12),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.success.withValues(
                alpha: 0.1,
              )
            : AppColors.warning.withValues(
                alpha: 0.1,
              ),
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
                  isConnected ? appText.printer_status_connected(_selectedPrinter!.name) : appText.printer_status_not_connected,
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
          SizedBox(
            width: AppSizes.size96,
            height: AppSizes.size40,
            child: WidgetButton(
              label: isConnected ? appText.button_change : appText.button_connect,
              backgroundColor: isConnected ? AppColors.success : AppColors.primary,
              onPressed: _navigateToPrinterSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessForm(AppLocalizations appText) {
    return Column(
      children: [
        WidgetTextFormField(
          label: appText.printer_business_name,
          hint: appText.printer_business_name_hint,
          controller: _businessNameController,
        ),
        AppSizes.spaceHeight8,
        WidgetTextFormField(
          label: appText.printer_business_address,
          hint: appText.printer_business_address_hint,
          controller: _businessAddressController,
        ),
        AppSizes.spaceHeight8,
        WidgetTextFormField(
          label: appText.printer_business_phone,
          hint: appText.printer_business_phone_hint,
          controller: _businessPhoneController,
        ),
      ],
    );
  }

  Widget _buildReceiptPreview(AppLocalizations appText) {
    if (_transaction == null) {
      return Center(
        child: Text(appText.printer_no_transaction_data),
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
              color: Colors.black.withValues(
                alpha: 0.1,
              ),
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
                appText.invoice_print_title,
                style: AppTextStyle.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(thickness: 1),

              // Transaction info
              _buildReceiptRow(
                label: appText.invoice_print_transaction_id,
                value: "#${_transaction!.id!}",
              ),
              _buildReceiptRow(
                label: appText.invoice_print_date,
                value: _transaction!.createdAt?.formatDateOnly() ?? "-",
              ),
              _buildReceiptRow(
                label: appText.invoice_print_customer_name,
                value: _transaction!.customerName ?? "-",
              ),

              Divider(thickness: 1),

              // Service details
              _buildReceiptRow(
                label: appText.invoice_print_service_name,
                value: _transaction!.serviceName ?? "-",
              ),
              _buildReceiptRow(
                label: appText.invoice_print_weight,
                value: "${_transaction!.weight} kg",
              ),
              _buildReceiptRow(
                label: appText.invoice_print_amount,
                value: "Rp ${_transaction!.amount?.formatNumber() ?? '0'}",
              ),

              Divider(thickness: 1),

              // Status information
              _buildReceiptRow(
                label: appText.invoice_print_transaction_status,
                value: _transaction!.transactionStatus?.value ?? "-",
              ),
              _buildReceiptRow(
                label: appText.invoice_print_payment_status,
                value: _transaction!.paymentStatus?.value ?? "-",
              ),

              if (_transaction!.startDate != null)
                _buildReceiptRow(
                  label: appText.invoice_print_start_date,
                  value: _transaction!.startDate?.formatDateOnly() ?? "-",
                ),

              if (_transaction!.endDate != null)
                _buildReceiptRow(
                  label: appText.invoice_print_end_date,
                  value: _transaction!.endDate?.formatDateOnly() ?? "-",
                ),

              Divider(thickness: 1),

              // Notes
              if (_transaction!.description != null && _transaction!.description!.isNotEmpty) ...[
                AppSizes.spaceHeight8,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    appText.invoice_print_notes,
                    style: AppTextStyle.body1.copyWith(fontWeight: FontWeight.bold),
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
                appText.invoice_print_thank_you(
                  _businessNameController.text,
                ),
                style: AppTextStyle.body1.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              AppSizes.spaceHeight4,
              Text(
                '${appText.invoice_print_staff_name}: ${_transaction!.userName ?? "-"}',
                style: AppTextStyle.caption.copyWith(
                  fontStyle: FontStyle.italic,
                ),
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
      child: Text(
        '$label: $value',
        style: AppTextStyle.body1,
      ),
    );
  }
}
