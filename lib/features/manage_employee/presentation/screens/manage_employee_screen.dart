import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_list_tile.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/user.dart';
import '../bloc/manage_employee_bloc.dart';
import '../widgets/widget_activate_employee.dart';
import '../widgets/widget_deactivate_employee.dart';

void pushManageEmployee(BuildContext context) {
  context.pushNamed('manage-employee');
}

class ManageEmployeeScreen extends StatefulWidget {
  const ManageEmployeeScreen({super.key});

  @override
  State<ManageEmployeeScreen> createState() => _ManageEmployeeScreenState();
}

class _ManageEmployeeScreenState extends State<ManageEmployeeScreen> {
  final TextEditingController _searchController = TextEditingController();

  late final ManageEmployeeBloc _employeeBloc;

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

  void _getUsers() {
    _employeeBloc.add(ManageEmployeeEventGetUsers());
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _employeeBloc,
      child: BlocListener<ManageEmployeeBloc, ManageEmployeeState>(
        listener: (context, state) {
          if (state is ManageEmployeeFailure) {
            showSnackbar(context, state.message);
          } else if (state is ManageEmployeeSuccessActivateEmployee) {
            showSnackbar(context,
                appText.manage_employee_success_activate_message(state.name));
          } else if (state is ManageEmployeeSuccessDeactivateEmployee) {
            showSnackbar(context,
                appText.manage_employee_success_deactivate_message(state.name));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              appText.manage_employee_screen_title,
              style: AppTextStyle.heading3,
            ),
            centerTitle: true,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: AppTextStyle.body,
                          decoration: InputDecoration(
                            hintText: appText.manage_employee_search_hint,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _employeeBloc.add(
                                        ManageEmployeeEventSearchUser(
                                          query: '',
                                        ),
                                      );
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.size8),
                            ),
                            hintStyle:
                                AppTextStyle.body.copyWith(color: Colors.grey),
                          ),
                          onChanged: (value) {
                            _employeeBloc.add(
                              ManageEmployeeEventSearchUser(
                                query: value,
                              ),
                            );
                          },
                        ),
                      ),
                      AppSizes.spaceWidth8,
                      IconButton(
                        icon: Icon(Icons.sort, size: AppSizes.size24),
                        onPressed: () => _showSortOptions(context),
                      ),
                    ],
                  ),
                  AppSizes.spaceHeight16,
                  Expanded(
                    child: _buildEmployeeList(appText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(AppLocalizations appText) {
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
              emptyMessage: appText.manage_employee_empty_message,
              onRefresh: _getUsers,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _getUsers();
            },
            child: ListView.separated(
              itemCount: filteredUsers.length,
              separatorBuilder: (_, __) => AppSizes.spaceHeight8,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final isAdmin = user.role == 'admin';

                return WidgetListTile(
                  title: user.name,
                  subtitle: user.email,
                  leadingIcon:
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                  tileColor:
                      isAdmin ? AppColors.success.withValues(alpha: 0.2) : null,
                  onLongPress: () {
                    isAdmin
                        ? deactivateEmployee(
                            context: context,
                            user: user,
                          )
                        : activateEmployee(
                            context: context,
                            user: user,
                          );
                  },
                );
              },
            ),
          );
        } else {
          return WidgetError(
            message: appText.manage_employee_empty_message,
          );
        }
      },
    );
  }

  void _showSortOptions(BuildContext context) {
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
                  AppLocalizations.of(context)!.sort_text,
                  style: AppTextStyle.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  isAscending
                      ? AppLocalizations.of(context)!.sort_asc
                      : AppLocalizations.of(context)!.sort_desc,
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
                  _buildSortOption(AppLocalizations.of(context)!.sort_by_name,
                      'name', currentSortField, isAscending),
                  _buildSortOption(AppLocalizations.of(context)!.sort_by_email,
                      'email', currentSortField, isAscending),
                  _buildSortOption(AppLocalizations.of(context)!.sort_by_role,
                      'role', currentSortField, isAscending),
                  _buildSortOption(
                      'Status', 'status', currentSortField, isAscending),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSortOption(
      String title, String field, String currentSortField, bool isAscending) {
    final bool isSelected = currentSortField == field;

    return ListTile(
      leading: Icon(
        isSelected
            ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.sort,
        color: isSelected ? AppColors.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: AppTextStyle.body1.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.onSecondary,
        ),
      ),
      onTap: () {
        // Let the bloc handle the actual sort logic
        final newAscending = currentSortField == field ? !isAscending : true;

        _employeeBloc.add(
          ManageEmployeeEventSortUsers(
            sortBy: field,
            ascending: newAscending,
          ),
        );

        Navigator.pop(context);
      },
    );
  }
}
