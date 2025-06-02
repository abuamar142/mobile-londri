import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/auth.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../../customer/presentation/screens/customers_screen.dart';
import '../../../customer/presentation/screens/manage_customer_screen.dart';
import '../../../export_report/presentation/screens/export_reports_screen.dart';
import '../../../manage_staff/presentation/screens/manage_staff_screen.dart';
import '../../../service/presentation/screens/services_screen.dart';
import '../../../transaction/domain/entities/transaction_status.dart';
import '../../../transaction/presentation/screens/manage_transaction_screen.dart';
import '../../../transaction/presentation/screens/transactions_screen.dart';
import '../bloc/home_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final HomeBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = serviceLocator<HomeBloc>();
    _getLast3DaysStatistics();
  }

  void _getLast3DaysStatistics() {
    _dashboardBloc.add(HomeEventGetTodayStatistics());
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: RefreshIndicator(
        onRefresh: () async => _getLast3DaysStatistics(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
        ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              context.appText.home_screen_statistic_today,
              style: AppTextStyle.heading3.copyWith(
                color: AppColors.primary,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateTime.now().subtract(Duration(days: 2)).formatDateOnly(),
                  style: AppTextStyle.body2.copyWith(
                    color: AppColors.gray.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  DateTime.now().formatDateOnly(),
                  style: AppTextStyle.body2.copyWith(
                    color: AppColors.gray.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
        AppSizes.spaceHeight12,
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeStateLoading) {
              return Center(child: const WidgetLoading(usingPadding: false));
            } else if (state is HomeStateFailure) {
              return WidgetEmptyList(
                emptyMessage: state.message,
                onRefresh: _getLast3DaysStatistics,
              );
            } else if (state is HomeStateSuccessLoadedData) {
              final statistics = state.statistic;
              return Column(
                children: [
                  _buildStatCard(
                    context.appText.home_screen_statistic_revenue,
                    statistics.last3DaysRevenue.toInt().formatNumber(),
                    Icons.attach_money,
                    AppColors.success,
                  ),
                  AppSizes.spaceHeight12,
                  _buildStatCard(
                    context.appText.home_screen_statistic_transaction_on_progress,
                    statistics.onProgressCount.toString(),
                    Icons.pending_actions,
                    AppColors.gray,
                    () async {
                      final result = await pushTransactions(
                        context: context,
                        tabName: TransactionStatus.onProgress.value,
                      );

                      if (result == true) {
                        _getLast3DaysStatistics();
                      }
                    },
                  ),
                  AppSizes.spaceHeight12,
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context.appText.home_screen_statistic_transaction_ready_for_pickup,
                          statistics.readyForPickupCount.toString(),
                          Icons.inventory,
                          AppColors.warning,
                          () async {
                            final result = await pushTransactions(
                              context: context,
                              tabName: TransactionStatus.readyForPickup.value,
                            );

                            if (result == true) {
                              _getLast3DaysStatistics();
                            }
                          },
                        ),
                      ),
                      AppSizes.spaceWidth12,
                      Expanded(
                        child: _buildStatCard(
                          context.appText.home_screen_statistic_transaction_picked_up,
                          statistics.pickedUpCount.toString(),
                          Icons.check_circle,
                          AppColors.success,
                          () async {
                            final result = await pushTransactions(
                              context: context,
                              tabName: TransactionStatus.pickedUp.value,
                            );

                            if (result == true) {
                              _getLast3DaysStatistics();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildStatCardSkeleton(),
                AppSizes.spaceHeight12,
                _buildStatCardSkeleton(),
                AppSizes.spaceHeight12,
                Row(
                  children: [
                    Expanded(child: _buildStatCardSkeleton()),
                    AppSizes.spaceWidth12,
                    Expanded(child: _buildStatCardSkeleton()),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
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
      ),
    );
  }

  Widget _buildStatCardSkeleton() {
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
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          AppSizes.spaceHeight8,
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.gray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
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
                  () async {
                    final result = await pushAddTransaction(context: context);

                    if (result == true) {
                      _getLast3DaysStatistics();
                    }
                  },
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
                () async {
                  final result = await pushTransactions(context: context);

                  if (result == true) {
                    _getLast3DaysStatistics();
                  }
                },
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
