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
import '../bloc/manage_employee_bloc.dart';
import '../widgets/widget_activate_employee.dart';
import '../widgets/widget_deactivate_employee.dart';

void pushManageEmployee({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.manageEmployee);
}

class ManageEmployeeScreen extends StatefulWidget {
  const ManageEmployeeScreen({super.key});

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

class _ManageEmployeeScreenState extends State<ManageEmployeeScreen> {
  late final ManageEmployeeBloc _employeeBloc;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _employeeBloc = serviceLocator<ManageEmployeeBloc>();
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
      value: _employeeBloc,
      child: BlocListener<ManageEmployeeBloc, ManageEmployeeState>(
        listener: (context, state) {
          if (state is ManageEmployeeFailure) {
            context.showSnackbar(state.message);
          } else if (state is ManageEmployeeSuccessActivateEmployee) {
            context.showSnackbar(context.appText.manage_employee_success_activate_message(state.name));
          } else if (state is ManageEmployeeSuccessDeactivateEmployee) {
            context.showSnackbar(context.appText.manage_employee_success_deactivate_message(state.name));
          }
        },
        child: Scaffold(
          appBar: WidgetAppBar(
            label: context.appText.manage_employee_screen_title,
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
                    child: _buildEmployeeList(),
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
          hintText: context.appText.manage_employee_search_hint,
          onChanged: (value) {
            setState(() {
              _employeeBloc.add(
                ManageEmployeeEventSearchUser(
                  query: value,
                ),
              );
            });
          },
          onClear: () {
            setState(() {
              _employeeBloc.add(
                ManageEmployeeEventSearchUser(
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

  Widget _buildEmployeeList() {
    return BlocBuilder<ManageEmployeeBloc, ManageEmployeeState>(
      builder: (context, state) {
        if (state is ManageEmployeeLoading) {
          return WidgetLoading(usingPadding: true);
        } else if (state is ManageEmployeeFailure) {
          return WidgetError(message: state.message);
        } else if (state is ManageEmployeeStateWithFilteredUsers) {
          List<User> filteredUsers = state.filteredUsers;

          if (filteredUsers.isEmpty) {
            return WidgetEmptyList(
              emptyMessage: context.appText.manage_employee_empty_message,
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
                      ? context.showSnackbar(context.appText.manage_employee_active_tap_info(user.name))
                      : context.showSnackbar(context.appText.manage_employee_non_active_tap_info(user.name)),
                  onLongPress: () => isAdmin
                      ? deactivateEmployee(
                          context: context,
                          user: user,
                        )
                      : activateEmployee(
                          context: context,
                          user: user,
                        ),
                );
              },
            ),
          );
        } else {
          return WidgetError(
            message: context.appText.manage_employee_empty_message,
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

        _employeeBloc.add(
          ManageEmployeeEventSortUsers(
            sortBy: field,
            ascending: newAscending,
          ),
        );

        context.pop();
      },
    );
  }

  void _getUsers() => _employeeBloc.add(ManageEmployeeEventGetUsers());

  void _showSortOptions() {
    final blocState = _employeeBloc.state;
    String currentSortField = 'name';
    bool isAscending = true;

    if (blocState is ManageEmployeeStateWithFilteredUsers) {
      currentSortField = _employeeBloc.currentSortField;
      isAscending = _employeeBloc.isAscending;
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
