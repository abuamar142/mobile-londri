import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../../config/i18n/i18n.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
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

    AppLocales.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    AppLocales.localeNotifier.removeListener(_onLocaleChanged);
    _transactionStatusController.dispose();

    super.dispose();
  }

  void _onLocaleChanged() {
    context.pushNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    final getTransactionStatus = GetTransactionStatus();

    return Scaffold(
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            showSnackbar(context, state.message);
          } else if (state
              is TransactionStateSuccessGetDefaultTransactionStatus) {
            _transactionStatusController.text = getTransactionStatus(
              context,
              state.transactionStatus.id!,
            ).status.toString();

            transactionStatusId = state.transactionStatus.id!;
          } else if (state
              is TransactionStateSuccessUpdateDefaultTransactionStatus) {
            showSnackbar(
              context,
              appText.transaction_status_change_success_message,
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionStateLoading) {
            return WidgetLoading(usingPadding: true);
          } else {
            return SafeArea(
              child: Column(
                children: [
                  SettingsList(
                    shrinkWrap: true,
                    applicationType: ApplicationType.material,
                    sections: [
                      SettingsSection(
                        tiles: [
                          SettingsTile(
                            title: Text(
                              appText.setting_language_label,
                              style: AppTextStyle.label,
                            ),
                            trailing: SizedBox(
                              width: 200,
                              child: DropdownButton<Locale>(
                                isExpanded: true,
                                value: AppLocales.localeNotifier.value,
                                onChanged: (Locale? newLocale) {
                                  if (newLocale != null) {
                                    serviceLocator<AppLocales>().setLocale(
                                      newLocale,
                                    );

                                    showSnackbar(
                                      context,
                                      appText.locale_change_success_message,
                                    );
                                  }
                                },
                                items: AppLocalizations.supportedLocales
                                    .map<DropdownMenuItem<Locale>>(
                                      (Locale locale) =>
                                          DropdownMenuItem<Locale>(
                                        value: locale,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            locale.languageCode == 'en'
                                                ? appText.setting_language_en
                                                : appText.setting_language_id,
                                            style: AppTextStyle.body,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          SettingsTile(
                            title: Text(
                              appText.setting_transaction_status_label,
                              style: AppTextStyle.label,
                            ),
                            trailing: SizedBox(
                              width: 200,
                              child: DropdownButton<TransactionStatus>(
                                isExpanded: true,
                                value: getTransactionStatus(
                                  context,
                                  transactionStatusId,
                                ),
                                onChanged: (TransactionStatus? newStatus) {
                                  if (newStatus != null) {
                                    _transactionStatusController.text =
                                        newStatus.status.toString();
                                    transactionStatusId = newStatus.id!;

                                    context.read<TransactionBloc>().add(
                                          TransactionEventUpdateDefaultTransactionStatus(
                                            transactionStatus: newStatus,
                                          ),
                                        );
                                  }
                                },
                                items: TransactionStatusId.values.map((id) {
                                  final status =
                                      getTransactionStatus(context, id);
                                  return DropdownMenuItem<TransactionStatus>(
                                    value: status,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        status.status.toString(),
                                        style: AppTextStyle.body,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
