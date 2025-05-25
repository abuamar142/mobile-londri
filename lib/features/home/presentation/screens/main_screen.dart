import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_sizes.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../../customer/presentation/screens/customers_screen.dart';
import '../../../manage_staff/presentation/screens/manage_staff_screen.dart';
import '../../../service/presentation/screens/services_screen.dart';
import '../../../transaction/presentation/screens/track_transaction_screen.dart';
import '../../../transaction/presentation/screens/transactions_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (RoleManager.hasPermission(Permission.manageStaffs))
                WidgetButton(
                  label: context.appText.button_manage_staff,
                  onPressed: () => pushManageStaff(context: context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.manageServices))
                WidgetButton(
                  label: context.appText.button_manage_service,
                  onPressed: () => pushServices(context: context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.manageCustomers))
                WidgetButton(
                  label: context.appText.button_manage_customer,
                  onPressed: () => pushCustomers(context: context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.manageTransactions))
                WidgetButton(
                  label: context.appText.button_manage_transaction,
                  onPressed: () => pushTransactions(context: context),
                ),
              AppSizes.spaceHeight12,
              if (RoleManager.hasPermission(Permission.trackTransactions)) TrackTransactionsScreen()
            ],
          ),
        ),
      ),
    );
  }
}
