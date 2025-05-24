import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../../config/i18n/i18n.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _transactionStatusController = TextEditingController();

  @override
  void initState() {
    super.initState();

    AppLocales.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    AppLocales.localeNotifier.removeListener(_onLocaleChanged);
    _transactionStatusController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                        context.appText.setting_language_label,
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

                              context.showSnackbar(context.appText.locale_change_success_message);
                            }
                          },
                          items: AppLocalizations.supportedLocales
                              .map<DropdownMenuItem<Locale>>(
                                (Locale locale) => DropdownMenuItem<Locale>(
                                  value: locale,
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSizes.size8),
                                    child: Text(
                                      locale.languageCode == 'en' ? context.appText.setting_language_en : context.appText.setting_language_id,
                                      style: AppTextStyle.body,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onLocaleChanged() {
    context.pushNamed('home');
  }
}
