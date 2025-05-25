import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_list_tile.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_search_bar.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';
import '../widgets/widget_activate_service.dart';
import 'manage_service_screen.dart';

void pushServices({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.services);
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late final ServiceBloc _serviceBloc;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _serviceBloc = serviceLocator<ServiceBloc>();
    _getServices();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _serviceBloc,
      child: BlocListener<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is ServiceStateSuccessActivateService) {
            context.showSnackbar(context.appText.service_activate_success_message);
          }
        },
        child: Scaffold(
          appBar: WidgetAppBar(
            title: context.appText.service_screen_title,
          ),
          body: SafeArea(
            child: Padding(
              padding: AppSizes.paddingAll16,
              child: _buildServiceList(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await pushAddService(context: context);

              if (result == true) {
                _getServices();
              }
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceStateLoading) {
          return WidgetLoading(usingPadding: true);
        } else if (state is ServiceStateFailure) {
          return WidgetError(message: state.message);
        } else if (state is ServiceStateWithFilteredServices) {
          List<Service> filteredServices = state.filteredServices;

          if (filteredServices.isNotEmpty) {
            return Column(
              children: [
                Row(
                  children: [
                    WidgetSearchBar(
                      controller: _searchController,
                      hintText: context.appText.service_search_hint,
                      onChanged: (value) {
                        _serviceBloc.add(
                          ServiceEventSearchService(query: value),
                        );
                      },
                      onClear: () {
                        _serviceBloc.add(
                          ServiceEventSearchService(query: ''),
                        );
                      },
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
                  child: RefreshIndicator(
                    onRefresh: () async => _getServices(),
                    child: ListView.separated(
                      itemCount: filteredServices.length,
                      separatorBuilder: (_, __) => AppSizes.spaceHeight8,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        final isActive = service.isActive ?? false;

                        return WidgetListTile(
                          title: service.name ?? '',
                          subtitle: _getServiceSubtitle(service),
                          leadingIcon: isActive ? Icons.assignment : Icons.assignment_late,
                          tileColor: isActive ? null : AppColors.gray.withValues(alpha: 0.1),
                          onTap: () async {
                            if (isActive) {
                              final result = await pushViewService(
                                context: context,
                                serviceId: service.id!.toString(),
                              );

                              if (result == true) {
                                _getServices();
                              }
                            } else {
                              context.showSnackbar(context.appText.service_info_activate);
                            }
                          },
                          onLongPress: () => isActive
                              ? context.showSnackbar(context.appText.service_info_active)
                              : activateService(
                                  context: context,
                                  service: service,
                                  serviceBloc: _serviceBloc,
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        }

        return WidgetEmptyList(
          emptyMessage: context.appText.service_empty_message,
          onRefresh: _getServices,
        );
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

        _serviceBloc.add(
          ServiceEventSortServices(
            sortBy: field,
            ascending: newAscending,
          ),
        );

        context.pop();
      },
    );
  }

  void _getServices() => _serviceBloc.add(ServiceEventGetServices());

  void _showSortOptions(BuildContext context) {
    final blocState = _serviceBloc.state;
    String currentSortField = 'name';
    bool isAscending = true;

    if (blocState is ServiceStateWithFilteredServices) {
      currentSortField = _serviceBloc.currentSortField;
      isAscending = _serviceBloc.isAscending;
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
                  style: AppTextStyle.heading3.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  isAscending ? context.appText.sort_asc : context.appText.sort_desc,
                  style: AppTextStyle.body1.copyWith(color: AppColors.primary),
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
                    title: context.appText.sort_by_price,
                    isSelected: currentSortField == 'price',
                    field: 'price',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: context.appText.sort_by_created_at,
                    isSelected: currentSortField == 'createdAt',
                    field: 'createdAt',
                    isAscending: isAscending,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getServiceSubtitle(Service service) {
    final List<String> parts = [];

    if (service.price != null && service.price! > 0) {
      parts.add('${service.price!.formatNumber()}/kg');
    }

    if (service.description != null && service.description!.isNotEmpty) {
      parts.add(service.description!);
    }

    return parts.isEmpty ? '-' : parts.join(' • ');
  }
}
