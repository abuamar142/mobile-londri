import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../bloc/transaction_bloc.dart';
import 'transaction_detail_screen.dart';

void pushTrackTransactionsScreen(BuildContext context) {
  context.pushNamed(RouteNames.trackTransactions);
}

class TrackTransactionsScreen extends StatefulWidget {
  const TrackTransactionsScreen({super.key});

  @override
  State<TrackTransactionsScreen> createState() => _TrackTransactionsScreenState();
}

class _TrackTransactionsScreenState extends State<TrackTransactionsScreen> {
  late final TransactionBloc _transactionBloc;
  final TextEditingController _transactionIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _transactionBloc = serviceLocator<TransactionBloc>();
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    _transactionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is TransactionStateSuccessGetTransactionById) {
            // Navigate to transaction detail
            pushViewTransaction(
              context: context,
              transactionId: state.transaction.id!,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: WidgetAppBar(
              title: 'Track Transaction',
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.size16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        _buildHeaderSection(context),

                        AppSizes.spaceHeight24,

                        // Search Form
                        _buildSearchForm(context, state),

                        AppSizes.spaceHeight24,

                        // Instructions
                        _buildInstructions(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.size20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.size12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.search,
                size: AppSizes.size40,
                color: AppColors.primary,
              ),
              AppSizes.spaceHeight12,
              Text(
                'Track Your Transaction',
                style: AppTextStyle.heading2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              AppSizes.spaceHeight8,
              Text(
                'Enter your transaction ID to view details and status',
                style: AppTextStyle.body1.copyWith(
                  color: AppColors.gray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchForm(BuildContext context, TransactionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction ID',
          style: AppTextStyle.heading3.copyWith(
            color: AppColors.primary,
          ),
        ),
        AppSizes.spaceHeight12,
        WidgetTextFormField(
          controller: _transactionIdController,
          label: 'Transaction ID',
          hint: 'Enter transaction ID (e.g. abc123)',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Transaction ID is required';
            }
            return null;
          },
          onChanged: (value) {
            // Auto uppercase untuk konsistensi
            final upperValue = value.toUpperCase();
            if (upperValue != value) {
              _transactionIdController.value = _transactionIdController.value.copyWith(
                text: upperValue,
                selection: TextSelection.collapsed(offset: upperValue.length),
              );
            }
          },
          suffixIcon: IconButton(
            onPressed: () => _transactionIdController.clear(),
            icon: const Icon(Icons.clear),
          ),
        ),
        AppSizes.spaceHeight16,
        SizedBox(
          width: double.infinity,
          child: WidgetButton(
            label: 'Search Transaction',
            isLoading: state is TransactionStateLoading,
            onPressed: _searchTransaction,
            backgroundColor: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.size16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.size8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: AppSizes.size20,
              ),
              AppSizes.spaceWidth8,
              Text(
                'How to use',
                style: AppTextStyle.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSizes.spaceHeight8,
          Text(
            '• Enter your transaction ID in the field above\n'
            '• Tap "Search Transaction" to find your order\n'
            '• View detailed information about your laundry status\n'
            '• Contact us if you need help finding your transaction ID',
            style: AppTextStyle.body2.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  void _searchTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final transactionId = _transactionIdController.text.trim();

    _transactionBloc.add(
      TransactionEventGetTransactionById(id: transactionId),
    );
  }
}
