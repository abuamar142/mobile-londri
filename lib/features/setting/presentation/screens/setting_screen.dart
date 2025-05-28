import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../../config/i18n/i18n.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../injection_container.dart';

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
  }

  @override
  void dispose() {
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
                      title: Text(context.appText.setting_language_label, style: AppTextStyle.label),
                      trailing: Text(
                        AppLocales.localeNotifier.value.languageCode == 'en' ? context.appText.setting_language_en : context.appText.setting_language_id,
                        style: AppTextStyle.body1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      onPressed: (BuildContext context) {
                        _showLanguageOptions();
                      },
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

  void _showLanguageOptions() {
    return showDropdownBottomSheet(
      context: context,
      title: context.appText.setting_language_label,
      items: [
        WidgetDropdownBottomSheetItem(
          isSelected: AppLocales.localeNotifier.value.languageCode == 'en',
          leadingIcon: Icons.language,
          title: context.appText.setting_language_en,
          onTap: () {
            setState(() {
              serviceLocator<AppLocales>().setLocale(const Locale('en', 'US'));
              context.showSnackbar(context.appText.locale_change_success_message);
            });
          },
        ),
        WidgetDropdownBottomSheetItem(
          isSelected: AppLocales.localeNotifier.value.languageCode == 'id',
          leadingIcon: Icons.language,
          title: context.appText.setting_language_id,
          onTap: () {
            setState(() {
              serviceLocator<AppLocales>().setLocale(const Locale('id', 'ID'));
              context.showSnackbar(context.appText.locale_change_success_message);
            });
          },
        ),
      ],
    );
  }
}
