import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_list_tile.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_scaffold_list.dart';
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

  void _getServices() => _serviceBloc.add(ServiceEventGetServices());

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
          } else if (state is ServiceStateSuccessDeactivateService) {
            context.showSnackbar(context.appText.service_deactivate_success_message);
          }
        },
        child: WidgetScaffoldList(
          title: context.appText.service_screen_title,
          searchController: _searchController,
          searchHint: context.appText.service_search_hint,
          onChanged: (value) {
            setState(() {
              _serviceBloc.add(
                ServiceEventSearchService(query: value),
              );
            });
          },
          onClear: () {
            setState(() {
              _serviceBloc.add(
                ServiceEventSearchService(query: ''),
              );
            });
          },
          onSortTap: () => _showSortOptions(),
          buildListItems: _buildServiceList(),
          onFloatingActionButtonPressed: () async {
            final result = await context.pushNamed(
              RouteNames.addService,
            );

            if (result == true) {
              _getServices();
            }
          },
        ),
      ),
    );
  }

  void _showSortOptions() {
    return showDropdownBottomSheet(
      context: context,
      title: context.appText.sort_text,
      isAscending: _serviceBloc.isAscending,
      items: [
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_name,
          isSelected: _serviceBloc.currentSortField == 'name',
          leadingIcon: Icons.person,
          onTap: () {
            _serviceBloc.add(ServiceEventSortServices(
              sortBy: 'name',
              ascending: !_serviceBloc.isAscending,
            ));
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_price,
          isSelected: _serviceBloc.currentSortField == 'price',
          leadingIcon: Icons.attach_money,
          onTap: () {
            _serviceBloc.add(ServiceEventSortServices(
              sortBy: 'price',
              ascending: !_serviceBloc.isAscending,
            ));
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_created_at,
          isSelected: _serviceBloc.currentSortField == 'createdAt',
          leadingIcon: Icons.date_range,
          onTap: () {
            _serviceBloc.add(ServiceEventSortServices(
              sortBy: 'createdAt',
              ascending: !_serviceBloc.isAscending,
            ));
          },
        ),
      ],
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

          if (filteredServices.isEmpty) {
            return WidgetEmptyList(
              emptyMessage: context.appText.service_empty_message,
              onRefresh: _getServices,
            );
          }

          return RefreshIndicator(
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
          );
        } else {
          return WidgetError(
            message: context.appText.service_empty_message,
          );
        }
      },
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
