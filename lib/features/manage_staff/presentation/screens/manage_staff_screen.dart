import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_list_tile.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_search_bar.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/user.dart';
import '../bloc/manage_staff_bloc.dart';
import '../widgets/widget_activate_staff.dart';
import '../widgets/widget_deactivate_staff.dart';

void pushManageStaff({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.manageStaff);
}

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  late final ManageStaffBloc _staffBloc;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _staffBloc = serviceLocator<ManageStaffBloc>();
    _getUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _staffBloc,
      child: BlocListener<ManageStaffBloc, ManageStaffState>(
        listener: (context, state) {
          if (state is ManageStaffFailure) {
            context.showSnackbar(state.message);
          } else if (state is ManageStaffSuccessActivateStaff) {
            context.showSnackbar(context.appText.manage_staff_success_activate_message(state.name));
          } else if (state is ManageStaffSuccessDeactivateStaff) {
            context.showSnackbar(context.appText.manage_staff_success_deactivate_message(state.name));
          }
        },
        child: Scaffold(
          appBar: WidgetAppBar(
            label: context.appText.manage_staff_screen_title,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSizes.size16,
                right: AppSizes.size16,
                bottom: AppSizes.size16,
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  AppSizes.spaceHeight16,
                  Expanded(
                    child: _buildStaffList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row _buildHeader() {
    return Row(
      children: [
        WidgetSearchBar(
          controller: _searchController,
          hintText: context.appText.manage_staff_search_hint,
          onChanged: (value) {
            setState(() {
              _staffBloc.add(
                ManageStaffEventSearchUser(
                  query: value,
                ),
              );
            });
          },
          onClear: () {
            setState(() {
              _staffBloc.add(
                ManageStaffEventSearchUser(
                  query: '',
                ),
              );
            });
          },
        ),
        AppSizes.spaceWidth8,
        IconButton(
          icon: Icon(Icons.sort, size: AppSizes.size24),
          onPressed: () => _showSortOptions(),
        ),
      ],
    );
  }

  Widget _buildStaffList() {
    return BlocBuilder<ManageStaffBloc, ManageStaffState>(
      builder: (context, state) {
        if (state is ManageStaffLoading) {
          return WidgetLoading(usingPadding: true);
        } else if (state is ManageStaffFailure) {
          return WidgetError(message: state.message);
        } else if (state is ManageStaffStateWithFilteredUsers) {
          List<User> filteredUsers = state.filteredUsers;

          if (filteredUsers.isEmpty) {
            return WidgetEmptyList(
              emptyMessage: context.appText.manage_staff_empty_message,
              onRefresh: _getUsers,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _getUsers(),
            child: ListView.separated(
              itemCount: filteredUsers.length,
              separatorBuilder: (_, __) => AppSizes.spaceHeight8,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final isAdmin = user.role == 'admin';

                return WidgetListTile(
                  title: user.name,
                  subtitle: user.email,
                  leadingIcon: isAdmin ? Icons.admin_panel_settings : Icons.person,
                  tileColor: isAdmin ? AppColors.success.withValues(alpha: 0.2) : null,
                  onTap: () => isAdmin
                      ? context.showSnackbar(context.appText.manage_staff_active_tap_info(user.name))
                      : context.showSnackbar(context.appText.manage_staff_non_active_tap_info(user.name)),
                  onLongPress: () => isAdmin
                      ? deactivateStaff(
                          context: context,
                          user: user,
                        )
                      : activateStaff(
                          context: context,
                          user: user,
                        ),
                );
              },
            ),
          );
        } else {
          return WidgetError(
            message: context.appText.manage_staff_empty_message,
          );
        }
      },
    );
  }

  Widget _buildSortOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required String field,
    required bool isAscending,
  }) {
    return ListTile(
      title: Text(
        title,
        style: isSelected
            ? AppTextStyle.body1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              )
            : AppTextStyle.body1,
      ),
      trailing: isSelected
          ? Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColors.primary,
            )
          : null,
      onTap: () {
        bool newAscending = isSelected ? !isAscending : true;

        _staffBloc.add(
          ManageStaffEventSortUsers(
            sortBy: field,
            ascending: newAscending,
          ),
        );

        context.pop();
      },
    );
  }

  void _getUsers() => _staffBloc.add(ManageStaffEventGetUsers());

  void _showSortOptions() {
    final blocState = _staffBloc.state;
    String currentSortField = 'name';
    bool isAscending = true;

    if (blocState is ManageStaffStateWithFilteredUsers) {
      currentSortField = _staffBloc.currentSortField;
      isAscending = _staffBloc.isAscending;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.size16),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppSizes.size16,
              left: AppSizes.size16,
              right: AppSizes.size16,
            ),
            child: Row(
              children: [
                Text(
                  context.appText.sort_text,
                  style: AppTextStyle.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  isAscending ? context.appText.sort_asc : context.appText.sort_desc,
                  style: AppTextStyle.body1.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSortOption(
                    context: context,
                    title: context.appText.sort_by_name,
                    isSelected: currentSortField == 'name',
                    field: 'name',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: context.appText.sort_by_email,
                    isSelected: currentSortField == 'email',
                    field: 'email',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: context.appText.sort_by_role,
                    isSelected: currentSortField == 'role',
                    field: 'role',
                    isAscending: isAscending,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
