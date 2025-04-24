import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widget_button.dart';
import '../../../auth/domain/entities/role_manager.dart';

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
              if (RoleManager.hasPermission(
                Permission.manageUserRoles,
              ))
                WidgetButton(
                  label: 'User Roles',
                  onPressed: () => context.pushNamed('user-roles'),
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
              SizedBox(height: 16),
              WidgetButton(
                label: 'Print',
                onPressed: () => context.pushNamed('print'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
