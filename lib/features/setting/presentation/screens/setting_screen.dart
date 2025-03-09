import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Add this import

import '../../../../core/utils/show_snackbar.dart';
import '../../../transaction/domain/entities/transaction_status.dart';
import '../../../transaction/domain/usecases/transaction_get_transaction_status.dart';
import '../../../transaction/presentation/bloc/transaction_bloc.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _transactionStatusController =
      TextEditingController();

  TransactionStatusId transactionStatusId = TransactionStatusId.default_status;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
          TransactionEventGetDefaultTransactionStatus(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final getTransactionStatus = GetTransactionStatus();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TypeAheadField<TransactionStatus>(
                      suggestionsCallback: (pattern) {
                        return TransactionStatusId.values
                            .map((id) => getTransactionStatus(context, id))
                            .where(
                              (status) => status.status!.toLowerCase().contains(
                                    pattern.toLowerCase(),
                                  ),
                            )
                            .toList();
                      },
                      builder: (context, controller, focusNode) {
                        return BlocConsumer<TransactionBloc, TransactionState>(
                          listener: (context, state) {
                            if (state is TransactionStateFailure) {
                              showSnackbar(context, state.message);
                            } else if (state
                                is TransactionStateSuccessGetDefaultTransactionStatus) {
                              _transactionStatusController.text =
                                  getTransactionStatus(
                                context,
                                state.transactionStatus.id!,
                              ).status.toString();

                              transactionStatusId = state.transactionStatus.id!;
                            }
                          },
                          builder: (context, state) {
                            return TextField(
                              controller: _transactionStatusController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Transaction Status',
                              ),
                            );
                          },
                        );
                      },
                      listBuilder: (context, children) {
                        return SizedBox(
                          height: 200,
                          child: ListView(
                            children: children,
                          ),
                        );
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.status.toString()),
                        );
                      },
                      onSelected: (suggestion) {
                        _transactionStatusController.text =
                            suggestion.status.toString();

                        transactionStatusId = suggestion.id!;
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionBloc>().add(
                            TransactionEventUpdateDefaultTransactionStatus(
                              transactionStatus: getTransactionStatus(
                                context,
                                transactionStatusId,
                              ),
                            ),
                          );
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
