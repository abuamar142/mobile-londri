import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_list_tile.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_scaffold_list.dart';
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

  void _getUsers() => _staffBloc.add(ManageStaffEventGetUsers());

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
        child: WidgetScaffoldList(
          title: context.appText.manage_staff_screen_title,
          searchController: _searchController,
          searchHint: context.appText.manage_staff_search_hint,
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
          onSortTap: () => _showSortOptions(),
          buildListItems: _buildStaffList(),
        ),
      ),
    );
  }

  void _showSortOptions() {
    return showDropdownBottomSheet(
      context: context,
      title: context.appText.sort_text,
      isAscending: _staffBloc.isAscending,
      items: [
        WidgetDropdownBottomSheetItem(
          isSelected: _staffBloc.currentSortField == 'name',
          leadingIcon: Icons.person,
          title: context.appText.sort_by_name,
          onTap: () {
            _staffBloc.add(
              ManageStaffEventSortUsers(
                sortBy: 'name',
                ascending: !_staffBloc.isAscending,
              ),
            );
          },
        ),
        WidgetDropdownBottomSheetItem(
          isSelected: _staffBloc.currentSortField == 'email',
          leadingIcon: Icons.email,
          title: context.appText.sort_by_email,
          onTap: () {
            _staffBloc.add(
              ManageStaffEventSortUsers(
                sortBy: 'email',
                ascending: !_staffBloc.isAscending,
              ),
            );
          },
        ),
        WidgetDropdownBottomSheetItem(
          isSelected: _staffBloc.currentSortField == 'role',
          leadingIcon: Icons.admin_panel_settings,
          title: context.appText.sort_by_role,
          onTap: () {
            _staffBloc.add(
              ManageStaffEventSortUsers(
                sortBy: 'role',
                ascending: !_staffBloc.isAscending,
              ),
            );
          },
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
}
