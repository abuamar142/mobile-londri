import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../../customer/presentation/screens/customers_screen.dart';
import '../../../customer/presentation/screens/manage_customer_screen.dart';
import '../../../export_report/presentation/screens/export_reports_screen.dart';
import '../../../manage_staff/presentation/screens/manage_staff_screen.dart';
import '../../../service/presentation/screens/services_screen.dart';
import '../../../transaction/presentation/screens/manage_transaction_screen.dart';
import '../../../transaction/presentation/screens/transactions_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(context),
          AppSizes.spaceHeight16,

          // Statistics Cards
          if (RoleManager.hasPermission(Permission.manageCustomers)) _buildStatisticsSection(context),
          AppSizes.spaceHeight24,

          // Quick Actions Section
          _buildQuickActionsSection(context),
          AppSizes.spaceHeight24,

          // Menu Grid Section
          if (RoleManager.hasPermission(Permission.accessMainMenu)) _buildMenuGridSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.appText.home_screen_welcome_text(AuthManager.currentUser!.name),
          style: AppTextStyle.heading1.copyWith(color: AppColors.primary),
          maxLines: 2,
          overflow: TextOverflow.visible,
        ),
        AppSizes.spaceHeight4,
        Text(
          context.appText.home_screen_role_text(RoleManager.currentUserRole!.value),
          style: AppTextStyle.body1.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              context.appText.home_screen_statistic_today,
              style: AppTextStyle.heading3.copyWith(
                color: AppColors.primary,
              ),
            ),
            Text(
              DateTime.now().formatDateOnly(),
              style: AppTextStyle.body1.copyWith(
                color: AppColors.gray.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        AppSizes.spaceHeight12,
        _buildStatCard(
          context.appText.home_screen_statistic_revenue,
          'Rp 850.000', // TODO: Replace with actual data
          Icons.attach_money,
          AppColors.success,
        ),
        AppSizes.spaceHeight12,
        _buildStatCard(
          context.appText.home_screen_statistic_transaction_on_progress,
          '12', // TODO: Replace with actual data
          Icons.pending_actions,
          AppColors.gray,
        ),
        AppSizes.spaceHeight12,
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context.appText.home_screen_statistic_transaction_ready_for_pickup,
                '8', // TODO: Replace with actual data
                Icons.inventory,
                AppColors.warning,
              ),
            ),
            AppSizes.spaceWidth12,
            Expanded(
              child: _buildStatCard(
                context.appText.home_screen_statistic_transaction_picked_up,
                '15', // TODO: Replace with actual data
                Icons.check_circle,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(value, style: AppTextStyle.heading3.copyWith(color: AppColors.primary)),
            ],
          ),
          AppSizes.spaceHeight8,
          Text(
            title,
            style: AppTextStyle.body1.copyWith(
              color: AppColors.gray.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.appText.home_screen_button_quick_actions_title,
          style: AppTextStyle.heading3.copyWith(
            color: AppColors.primary,
          ),
        ),
        AppSizes.spaceHeight12,
        Row(
          children: [
            if (RoleManager.hasPermission(Permission.manageTransactions))
              Expanded(
                child: _buildQuickActionCard(
                  context.appText.home_screen_button_quick_actions_add_transaction,
                  Icons.add_circle,
                  AppColors.primary,
                  () => pushAddTransaction(context: context),
                ),
              ),
            if (RoleManager.hasPermission(Permission.manageCustomers)) AppSizes.spaceWidth12,
            if (RoleManager.hasPermission(Permission.manageCustomers))
              Expanded(
                child: _buildQuickActionCard(
                  context.appText.home_screen_button_quick_actions_add_customer,
                  Icons.add_circle,
                  AppColors.primary,
                  () => pushAddCustomer(context: context),
                ),
              ),
            if (RoleManager.hasPermission(Permission.trackTransactions))
              Expanded(
                child: _buildQuickActionCard(
                  context.appText.home_screen_button_quick_actions_track_transaction,
                  Icons.search,
                  AppColors.success,
                  () => context.pushNamed(RouteNames.trackTransactions),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: 0.1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.size12),
          border: Border.all(
              color: color.withValues(
            alpha: 0.3,
          )),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.size32),
            AppSizes.spaceHeight8,
            Text(
              title,
              style: AppTextStyle.body1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGridSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.appText.home_screen_button_main_menu_title,
          style: AppTextStyle.heading3.copyWith(
            color: AppColors.primary,
          ),
        ),
        AppSizes.spaceHeight12,
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            if (RoleManager.hasPermission(Permission.manageStaffs))
              _buildMenuCard(
                context.appText.home_screen_button_main_menu_manage_staff,
                Icons.people,
                AppColors.primary,
                () => pushManageStaff(context: context),
              ),
            if (RoleManager.hasPermission(Permission.manageServices))
              _buildMenuCard(
                context.appText.home_screen_button_main_menu_manage_service,
                Icons.local_laundry_service,
                AppColors.primary,
                () => pushServices(context: context),
              ),
            if (RoleManager.hasPermission(Permission.manageCustomers))
              _buildMenuCard(
                context.appText.home_screen_button_main_menu_manage_customer,
                Icons.group,
                AppColors.primary,
                () => pushCustomers(context: context),
              ),
            if (RoleManager.hasPermission(Permission.manageTransactions))
              _buildMenuCard(
                context.appText.home_screen_button_main_menu_manage_transaction,
                Icons.receipt_long,
                AppColors.primary,
                () => pushTransactions(context: context),
              ),
            if (RoleManager.hasPermission(Permission.exportReports))
              _buildMenuCard(
                context.appText.home_screen_button_main_menu_export_report,
                Icons.file_download,
                AppColors.primary,
                () => pushExportReports(context: context),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSizes.paddingAll16,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            AppSizes.spaceHeight12,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: AppTextStyle.body1.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
