import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
          TransactionEventGetTransactions(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText.transaction_screen_title,
          style: AppTextstyle.title,
        ),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            showSnackbar(context, state.message.toString());
          }
        },
        builder: (context, state) {
          if (state is TransactionStateLoading) {
            return WidgetLoading(usingPadding: true);
          } else if (state is TransactionStateSuccessGetTransactions) {
            return SafeArea(
              child: ListView.builder(
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  final Transaction transaction = state.transactions[index];

                  return ListTile(
                    key: ValueKey(transaction.id),
                    title: Text(
                      transaction.customerName ?? '',
                      style: AppTextstyle.tileTitle,
                    ),
                    subtitle: Text(
                      transaction.startDate.toString(),
                      style: AppTextstyle.tileSubtitle,
                    ),
                    trailing: Text(
                      transaction.amount!.formatNumber(),
                      style: AppTextstyle.tileTrailing,
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text(
                appText.transaction_empty_message,
                style: AppTextstyle.body,
              ),
            );
          }
        },
      ),
    );
  }
}
