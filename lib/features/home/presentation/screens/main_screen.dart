import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_sizes.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../../customer/presentation/screens/customers_screen.dart';
import '../../../manage_employee/presentation/screens/manage_employee_screen.dart';
import '../../../service/presentation/screens/services_screen.dart';
import '../../../transaction/presentation/screens/track_transaction_screen.dart';
import '../../../transaction/presentation/screens/transactions_screen.dart';

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
              if (RoleManager.hasPermission(Permission.manageEmployees))
                WidgetButton(
                  label: appText.button_manage_employee,
                  onPressed: () => pushManageEmployee(context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.manageServices))
                WidgetButton(
                  label: appText.button_manage_service,
                  onPressed: () => pushServices(context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.manageCustomers))
                WidgetButton(
                  label: appText.button_manage_customer,
                  onPressed: () => pushCustomers(context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.manageTransactions))
                WidgetButton(
                  label: appText.button_manage_transaction,
                  onPressed: () => pushTransactions(context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.trackTransactions))
                TrackTransactionsScreen()
            ],
          ),
        ),
      ),
    );
  }
}
