import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_bottom_bar.dart';
import '../widgets/widget_delete_transaction.dart';
import '../widgets/widget_detail_card.dart';
import '../widgets/widget_payment_status_badge.dart';
import '../widgets/widget_transaction_status_badge.dart';
import 'manage_transaction_screen.dart';
import 'print_transaction_note_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isLoading = true;
  Transaction? _transaction;
  late final TransactionBloc _transactionBloc;

  @override
  void initState() {
    super.initState();
    _transactionBloc = serviceLocator<TransactionBloc>();
    _getTransactionById(
      context: context,
      transactionId: widget.transactionId,
    );
  }

  _getTransactionById({
    required BuildContext context,
    required String transactionId,
  }) {
    _transactionBloc.add(TransactionEventGetTransactionById(
      id: transactionId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            showSnackbar(context, state.message);
          } else if (state is TransactionStateSuccessDeleteTransaction) {
            showSnackbar(context, appText.transaction_delete_success_message);
            context.pop(true);
          } else if (state is TransactionStateSuccessGetTransactionById) {
            _handleTransactionDataLoaded(state);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                appText.transaction_detail_screen_title,
                style: AppTextStyle.heading3,
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () => pushPrintTransactionNoteScreen(
                    context: context,
                    transactionId: _transaction?.id,
                  ),
                  icon: const Icon(Icons.print),
                ),
              ],
            ),
            body: _isLoading
                ? WidgetLoading(usingPadding: true)
                : SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: AppSizes.size16,
                        right: AppSizes.size16,
                        top: AppSizes.size16,
                      ),
                      child: _buildTransactionDetailView(appText),
                    ),
                  ),
            bottomNavigationBar: WidgetBottomBar(
              content: [
                // Button edit
                Row(
                  children: [
                    Expanded(
                      child: WidgetButton(
                        label: appText.button_edit,
                        isLoading: state is TransactionStateLoading,
                        onPressed: () async {
                          if (_transaction != null) {
                            final result = await pushEditTransaction(
                              context,
                              _transaction!.id!,
                            );

                            if (result == true && context.mounted) {
                              _getTransactionById(
                                context: context,
                                transactionId: _transaction!.id!,
                              );
                            }
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
                        label: appText.button_delete,
                        backgroundColor: AppColors.warning,
                        isLoading: state is TransactionStateLoading,
                        onPressed: () {
                          deleteTransaction(
                            context: context,
                            transaction: _transaction!,
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
                              label: 'Hard Delete',
                              backgroundColor: AppColors.error,
                              isLoading: state is TransactionStateLoading,
                              onPressed: () {
                                deleteTransaction(
                                  context: context,
                                  transaction: _transaction!,
                                  transactionBloc: _transactionBloc,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionDetailView(AppLocalizations appText) {
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
                  // Transaction status badge
                  WidgetTransactionStatusBadge(
                    status: _transaction!.transactionStatus!,
                  ),

                  AppSizes.spaceWidth8,

                  // Payment status badge
                  WidgetPaymentStatusBadge(
                    status: _transaction!.paymentStatus!,
                  ),
                ],
              ),

              SizedBox(height: AppSizes.size8),

              // Transaction ID
              Text(
                '#${_transaction!.id!.toUpperCase()}',
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
          title: appText.card_title_transaction_details,
          content: [
            _buildDetailItem(
              icon: Icons.person,
              label: appText.card_item_title_customer,
              value: _transaction?.customerName ?? '-',
            ),
            _buildDetailItem(
              icon: Icons.design_services,
              label: appText.card_item_title_service,
              value: _transaction?.serviceName ?? '-',
            ),
            _buildDetailItem(
              icon: Icons.scale,
              label: appText.card_item_title_weight,
              value: "${_transaction!.weight} kg",
            ),
            _buildDetailItem(
              icon: Icons.attach_money,
              label: appText.card_item_title_amount,
              value: _transaction!.amount!.formatNumber(),
            ),
            _buildDetailItem(
              icon: Icons.person_pin,
              label: appText.card_item_title_staff_name,
              value: _transaction?.userName ?? '-',
            ),
          ],
        ),

        SizedBox(height: AppSizes.size12),

        // Transaction dates
        WidgetDetailCard(
          title: appText.card_title_transaction_dates,
          content: [
            // Start date
            _buildDetailItem(
              icon: Icons.calendar_today,
              label: appText.card_item_title_start_date,
              value: _transaction!.startDate!.formatDateOnly(),
            ),

            // End date
            _buildDetailItem(
              icon: Icons.event,
              label: appText.card_item_title_end_date,
              value: _transaction?.endDate?.formatDateOnly() ?? '-',
            ),

            // Created at
            _buildDetailItem(
              icon: Icons.access_time,
              label: appText.card_item_title_created_at,
              value: _transaction!.createdAt!.formatDateTime(),
            ),
          ],
        ),
        SizedBox(height: AppSizes.size12),

        // Description Card
        WidgetDetailCard(
          title: appText.card_title_description,
          content: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.size8,
              ),
              child: Text(
                _transaction?.description ?? '-',
                style: AppTextStyle.body1,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSizes.size8),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.size8),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.size20, color: AppColors.primary),
          SizedBox(width: AppSizes.size8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.body2.copyWith(
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: AppSizes.size4),
              Text(
                value,
                style: AppTextStyle.body1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _handleTransactionDataLoaded(
    TransactionStateSuccessGetTransactionById state,
  ) {
    try {
      final transaction = state.transaction;

      if (transaction.id != null) {
        setState(() {
          _transaction = transaction;
          _isLoading = false;
        });
      } else {
        showSnackbar(context, 'Transaction not found');
        context.pop();
      }
    } catch (e) {
      showSnackbar(context, 'Transaction not found');
      context.pop();
    }
  }
}
