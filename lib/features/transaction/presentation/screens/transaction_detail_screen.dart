import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_detail_card.dart';
import '../../../../core/widgets/widget_detail_card_item.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../../printer/presentation/screens/print_transaction_invoice_screen.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_bottom_bar.dart';
import '../widgets/widget_delete_transaction.dart';
import '../widgets/widget_payment_status_badge.dart';
import '../widgets/widget_transaction_status_badge.dart';
import 'manage_transaction_screen.dart';

Future<bool> pushViewTransaction({
  required BuildContext context,
  required String transactionId,
}) async {
  await context.pushNamed(
    RouteNames.viewTransaction,
    pathParameters: {
      'id': transactionId,
    },
  );

  return true;
}

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late final TransactionBloc _transactionBloc;

  late TransactionStatus _transactionStatus;
  late PaymentStatus _paymentStatus;

  @override
  void initState() {
    super.initState();

    _transactionBloc = serviceLocator<TransactionBloc>();
    _getTransactionById(
      transactionId: widget.transactionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is TransactionStateSuccessUpdateTransaction) {
            setState(() {
              _transactionBloc.add(
                TransactionEventGetTransactionById(id: widget.transactionId),
              );
            });
          } else if (state is TransactionStateSuccessDeleteTransaction) {
            context.showSnackbar(context.appText.transaction_delete_success_message);
            context.pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: WidgetAppBar(
              title: context.appText.transaction_detail_screen_title,
              action: RoleManager.hasPermission(Permission.trackTransactions) &&
                      !RoleManager.hasPermission(Permission.manageTransactions)
                  ? null
                  : IconButton(
                      onPressed: () => pushPrintTransactionInvoiceScreen(
                        context: context,
                        transactionId: widget.transactionId,
                      ),
                      icon: const Icon(Icons.print),
                      tooltip: context.appText.printer_print_invoice,
                    ),
            ),
            body: _buildBody(state),
            bottomNavigationBar: state is TransactionStateSuccessGetTransactionById ? _buildBottomBar(state.transaction) : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(TransactionState state) {
    if (state is TransactionStateLoading) {
      return const WidgetLoading(usingPadding: true);
    } else if (state is TransactionStateSuccessGetTransactionById) {
      final transaction = state.transaction;

      _transactionStatus = transaction.transactionStatus!;
      _paymentStatus = transaction.paymentStatus!;

      return SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSizes.size16,
            right: AppSizes.size16,
            top: AppSizes.size16,
          ),
          child: _buildTransactionDetailView(transaction),
        ),
      );
    } else if (state is TransactionStateFailure) {
      return Center(
        child: Text(
          state.message,
          style: AppTextStyle.body1,
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return WidgetEmptyList(
        emptyMessage: context.appText.transaction_empty_message,
      );
    }
  }

  Widget _buildBottomBar(Transaction transaction) {
    if (RoleManager.hasPermission(Permission.trackTransactions) &&
        !RoleManager.hasPermission(Permission.manageTransactions)) {
      return const SizedBox.shrink();
    }

    return WidgetBottomBar(
      content: [
        // Button edit
        Row(
          children: [
            Expanded(
              child: WidgetButton(
                label: context.appText.button_edit,
                isLoading: _transactionBloc.state is TransactionStateLoading,
                onPressed: () async {
                  final result = await pushEditTransaction(
                    context: context,
                    transactionId: transaction.id!,
                  );

                  if (result && context.mounted) {
                    _getTransactionById(
                      transactionId: transaction.id!,
                    );
                  }
                },
              ),
            ),
          ],
        ),

        AppSizes.spaceHeight12,

        // Button delete
        Row(
          children: [
            Expanded(
              child: WidgetButton(
                label: context.appText.button_delete,
                backgroundColor: AppColors.warning,
                isLoading: _transactionBloc.state is TransactionStateLoading,
                onPressed: () {
                  deleteTransaction(
                    context: context,
                    transaction: transaction,
                    transactionBloc: _transactionBloc,
                  );
                },
              ),
            ),
          ],
        ),

        // Button hard delete for Super Admin
        if (RoleManager.hasPermission(Permission.hardDeleteTransaction))
          Column(
            children: [
              AppSizes.spaceHeight12,
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label: context.appText.button_hard_delete,
                      backgroundColor: AppColors.error,
                      isLoading: _transactionBloc.state is TransactionStateLoading,
                      onPressed: () {
                        deleteTransaction(
                          context: context,
                          transaction: transaction,
                          transactionBloc: _transactionBloc,
                          isHardDelete: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTransactionDetailView(Transaction transaction) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: AppSizes.size80,
                height: AppSizes.size80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: AppSizes.size40,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSizes.size16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => _showTransactionStatusOptions(),
                    child: WidgetTransactionStatusBadge(
                      status: transaction.transactionStatus!,
                    ),
                  ),
                  AppSizes.spaceWidth8,
                  InkWell(
                    onTap: () => _showPaymentStatusOptions(),
                    child: WidgetPaymentStatusBadge(
                      status: transaction.paymentStatus!,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.size8),
              Text(
                '#${transaction.id!.toUpperCase()}',
                style: AppTextStyle.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        AppSizes.spaceHeight16,

        // Transaction details
        WidgetDetailCard(
          title: context.appText.card_title_transaction_details,
          content: [
            WidgetDetailCardItem(
              icon: Icons.person,
              label: context.appText.card_item_title_customer,
              value: transaction.customerName ?? '-',
            ),
            WidgetDetailCardItem(
              icon: Icons.design_services,
              label: context.appText.card_item_title_service,
              value: transaction.serviceName ?? '-',
            ),
            WidgetDetailCardItem(
              icon: Icons.scale,
              label: context.appText.card_item_title_weight,
              value: "${transaction.weight} kg",
            ),
            WidgetDetailCardItem(
              icon: Icons.attach_money,
              label: context.appText.card_item_title_amount,
              value: transaction.amount!.formatNumber(),
            ),
            WidgetDetailCardItem(
              icon: Icons.person_pin,
              label: context.appText.card_item_title_staff_name,
              value: transaction.userName ?? '-',
            ),
          ],
        ),

        SizedBox(height: AppSizes.size12),

        WidgetDetailCard(
          title: context.appText.card_title_transaction_dates,
          content: [
            WidgetDetailCardItem(
              icon: Icons.calendar_today,
              label: context.appText.card_item_title_start_date,
              value: transaction.startDate!.formatDateOnly(),
            ),
            WidgetDetailCardItem(
              icon: Icons.event,
              label: context.appText.card_item_title_end_date,
              value: transaction.endDate?.formatDateOnly() ?? '-',
            ),
            WidgetDetailCardItem(
              icon: Icons.access_time,
              label: context.appText.card_item_title_created_at,
              value: transaction.createdAt!.formatDateTime(),
            ),
          ],
        ),
        SizedBox(height: AppSizes.size12),

        WidgetDetailCard(
          title: context.appText.card_title_description,
          content: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.size8,
              ),
              child: Text(
                transaction.description ?? '-',
                style: AppTextStyle.body1,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSizes.size8),
      ],
    );
  }

  void _getTransactionById({
    required String transactionId,
  }) {
    _transactionBloc.add(TransactionEventGetTransactionById(
      id: transactionId,
    ));
  }

  void _showTransactionStatusOptions() {
    return showDropdownBottomSheet(context: context, title: context.appText.form_transaction_status_hint, items: [
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.onProgress,
        leadingIcon: TransactionStatus.onProgress.icon,
        title: getTransactionStatusValue(context, TransactionStatus.onProgress),
        onTap: () {
          _transactionBloc.add(
            TransactionEventUpdateTransactionStatus(
              id: widget.transactionId,
              status: TransactionStatus.onProgress,
            ),
          );
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.readyForPickup,
        leadingIcon: TransactionStatus.readyForPickup.icon,
        title: getTransactionStatusValue(context, TransactionStatus.readyForPickup),
        onTap: () {
          _transactionBloc.add(
            TransactionEventUpdateTransactionStatus(
              id: widget.transactionId,
              status: TransactionStatus.readyForPickup,
            ),
          );
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.pickedUp,
        leadingIcon: TransactionStatus.pickedUp.icon,
        title: getTransactionStatusValue(context, TransactionStatus.pickedUp),
        onTap: () {
          _transactionBloc.add(
            TransactionEventUpdateTransactionStatus(
              id: widget.transactionId,
              status: TransactionStatus.pickedUp,
            ),
          );
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.other,
        leadingIcon: TransactionStatus.other.icon,
        title: getTransactionStatusValue(context, TransactionStatus.other),
        onTap: () {
          _transactionBloc.add(
            TransactionEventUpdateTransactionStatus(
              id: widget.transactionId,
              status: TransactionStatus.other,
            ),
          );
        },
      ),
    ]);
  }

  void _showPaymentStatusOptions() {
    return showDropdownBottomSheet(context: context, title: context.appText.form_payment_status_hint, items: [
      WidgetDropdownBottomSheetItem(
        isSelected: _paymentStatus == PaymentStatus.notPaidYet,
        leadingIcon: PaymentStatus.notPaidYet.icon,
        title: getPaymentStatusValue(context, PaymentStatus.notPaidYet),
        onTap: () {
          _transactionBloc.add(
            TransactionEventUpdatePaymentStatus(
              id: widget.transactionId,
              status: PaymentStatus.notPaidYet,
            ),
          );
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _paymentStatus == PaymentStatus.paid,
        leadingIcon: PaymentStatus.paid.icon,
        title: getPaymentStatusValue(context, PaymentStatus.paid),
        onTap: () {
          _transactionBloc.add(
            TransactionEventUpdatePaymentStatus(
              id: widget.transactionId,
              status: PaymentStatus.paid,
            ),
          );
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _paymentStatus == PaymentStatus.other,
        leadingIcon: PaymentStatus.other.icon,
        title: getPaymentStatusValue(context, PaymentStatus.other),
        onTap: () {
          _transactionBloc.add(
            TransactionEventUpdatePaymentStatus(
              id: widget.transactionId,
              status: PaymentStatus.other,
            ),
          );
        },
      ),
    ]);
  }
}
