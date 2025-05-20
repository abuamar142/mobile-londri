import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widget_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../../manage_employee/presentation/screens/manage_employee_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (RoleManager.hasPermission(
                Permission.manageUserRoles,
              ))
                WidgetButton(
                  label: appText.button_manage_employee,
                  onPressed: () => pushManageEmployee(context),
                ),
              SizedBox(height: 16),
              if (RoleManager.hasPermission(
                Permission.manageServices,
              ))
                WidgetButton(
                  label: 'Services',
                  onPressed: () => context.pushNamed('services'),
                ),
              SizedBox(height: 16),
              WidgetButton(
                label: 'Customers',
                onPressed: () => context.pushNamed('customers'),
              ),
              SizedBox(height: 16),
              WidgetButton(
                label: 'Transactions',
                onPressed: () => context.pushNamed('transactions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
