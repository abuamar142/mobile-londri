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
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_detail_card.dart';
import '../../../../core/widgets/widget_detail_card_item.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../transaction/presentation/widgets/widget_bottom_bar.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';
import '../widgets/widget_deactivate_service.dart';
import '../widgets/widget_hard_delete_service.dart';

enum ManageServiceMode { add, edit, view }

Future<bool> pushAddService({
  required BuildContext context,
}) async {
  await context.pushNamed(RouteNames.addService);
  return true;
}

Future<bool> pushViewService({
  required BuildContext context,
  required String serviceId,
}) async {
  await context.pushNamed(
    RouteNames.viewService,
    pathParameters: {'id': serviceId},
  );
  return true;
}

Future<bool> pushEditService({
  required BuildContext context,
  required String serviceId,
}) async {
  await context.pushNamed(
    RouteNames.editService,
    pathParameters: {'id': serviceId},
  );
  return true;
}

class ManageServiceScreen extends StatefulWidget {
  final ManageServiceMode mode;
  final String? serviceId;

  const ManageServiceScreen({
    super.key,
    required this.mode,
    this.serviceId,
  });

  @override
  State<ManageServiceScreen> createState() => _ManageServiceScreenState();
}

class _ManageServiceScreenState extends State<ManageServiceScreen> {
  late final ServiceBloc _serviceBloc;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Service? _currentService;
  bool _isLoading = true;

  bool get _isAddMode => widget.mode == ManageServiceMode.add;
  bool get _isEditMode => widget.mode == ManageServiceMode.edit;
  bool get _isViewMode => widget.mode == ManageServiceMode.view;

  @override
  void initState() {
    super.initState();

    _serviceBloc = serviceLocator<ServiceBloc>();

    if (_isAddMode) {
      setState(() {
        _isLoading = false;
      });
    } else {
      _serviceBloc.add(ServiceEventGetServiceById(id: widget.serviceId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _serviceBloc,
      child: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is ServiceStateSuccessCreateService) {
            context.showSnackbar(context.appText.service_add_success_message);
            context.pop(true);
          } else if (state is ServiceStateSuccessUpdateService) {
            context.showSnackbar(context.appText.service_update_success_message);
            context.pop();
          } else if (state is ServiceStateSuccessDeactivateService) {
            context.showSnackbar(context.appText.service_deactivate_success_message);
            context.pop(true);
          } else if (state is ServiceStateSuccessHardDeleteService) {
            context.showSnackbar(context.appText.service_hard_delete_success_message);
            context.pop(true);
          } else if (state is ServiceStateSuccessGetServiceById) {
            _handleServiceDataLoaded();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: WidgetAppBar(
              title: _getScreenTitle(),
            ),
            body: _isLoading
                ? WidgetLoading(usingPadding: true)
                : SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSizes.size16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormFields(state),
                            SizedBox(height: AppSizes.size80),
                          ],
                        ),
                      ),
                    ),
                  ),
            bottomNavigationBar: WidgetBottomBar(content: [
              if (_isViewMode)
                Row(
                  children: [
                    Expanded(
                      child: WidgetButton(
                        label: context.appText.button_edit,
                        onPressed: () async {
                          if (_currentService != null) {
                            final result = await pushEditService(
                              context: context,
                              serviceId: _currentService!.id!.toString(),
                            );

                            if (result && mounted) {
                              _serviceBloc.add(
                                ServiceEventGetServiceById(id: _currentService!.id!.toString()),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              if (_isAddMode || _isEditMode)
                Row(
                  children: [
                    Expanded(
                      child: WidgetButton(
                        label: _isAddMode ? context.appText.button_add : context.appText.button_save,
                        isLoading: _serviceBloc.state is ServiceStateLoading,
                        onPressed: _submitForm,
                      ),
                    ),
                  ],
                ),
              if (_isViewMode)
                Column(
                  children: [
                    AppSizes.spaceHeight12,
                    Row(
                      children: [
                        Expanded(
                          child: WidgetButton(
                            label: context.appText.button_deactivate,
                            backgroundColor: AppColors.warning,
                            onPressed: () => deactivateService(
                              context: context,
                              service: _currentService!,
                              serviceBloc: _serviceBloc,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSizes.spaceHeight12,
                    Row(
                      children: [
                        Expanded(
                          child: WidgetButton(
                            label: context.appText.button_hard_delete,
                            backgroundColor: AppColors.error,
                            onPressed: () => hardDeleteService(
                              context: context,
                              service: _currentService!,
                              serviceBloc: _serviceBloc,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ]),
          );
        },
      ),
    );
  }

  String _getScreenTitle() {
    if (_isAddMode) {
      return context.appText.service_add_screen_title;
    } else if (_isEditMode) {
      return context.appText.service_edit_screen_title;
    } else {
      return context.appText.service_view_screen_title;
    }
  }

  Widget _buildFormFields(ServiceState state) {
    final bool isFormEnabled = !_isViewMode && state is! ServiceStateLoading;

    if (_isViewMode) {
      return _buildServiceDetailView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetTextFormField(
          label: context.appText.form_name_label,
          hint: context.appText.form_name_hint,
          controller: _nameController,
          isEnabled: isFormEnabled,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.appText.form_name_required_message;
            }
            return null;
          },
        ),
        AppSizes.spaceHeight12,
        WidgetTextFormField(
          label: context.appText.form_description_label,
          hint: context.appText.form_description_hint,
          controller: _descriptionController,
          maxLines: 3,
          isEnabled: isFormEnabled,
        ),
        AppSizes.spaceHeight12,
        WidgetTextFormField(
          label: context.appText.form_price_label,
          hint: context.appText.form_price_hint,
          controller: _priceController,
          isEnabled: isFormEnabled,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.appText.form_price_required_message;
            }
            if (int.tryParse(value) == null) {
              return context.appText.form_price_digits_only_message;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildServiceDetailView() {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: AppSizes.size80,
                height: AppSizes.size80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Icon(
                  Icons.assignment,
                  size: AppSizes.size40,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSizes.size16),
              Text(
                _nameController.text,
                style: AppTextStyle.heading2.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.size24),
        WidgetDetailCard(
          title: context.appText.service_information_card_label,
          content: [
            WidgetDetailCardItem(
              icon: Icons.attach_money,
              label: context.appText.form_price_label,
              value: int.tryParse(_priceController.text)?.formatNumber() ?? '-',
            ),
          ],
        ),
        SizedBox(height: AppSizes.size16),
        WidgetDetailCard(
          title: context.appText.service_description_card_label,
          content: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.size8),
              child: Text(
                _descriptionController.text.isNotEmpty ? _descriptionController.text : '-',
                style: AppTextStyle.body1.copyWith(
                  color: _descriptionController.text.isNotEmpty ? AppColors.onSecondary : AppColors.gray,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleServiceDataLoaded() {
    final service = (_serviceBloc.state as ServiceStateSuccessGetServiceById).service;

    if (service.id != null) {
      _currentService = service;
      _nameController.text = service.name ?? '';
      _descriptionController.text = service.description ?? '';
      _priceController.text = service.price?.toString() ?? '';
      setState(() {
        _isLoading = false;
      });
    } else {
      context.showSnackbar(context.appText.service_empty_message);
      context.pop();
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final service = Service(
        id: _isAddMode ? null : _currentService!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: int.tryParse(_priceController.text),
        isActive: _currentService?.isActive ?? true,
      );

      if (_isAddMode) {
        _serviceBloc.add(ServiceEventCreateService(
          service: service,
        ));
      } else if (_isEditMode) {
        _serviceBloc.add(ServiceEventUpdateService(
          service: service,
        ));
      }
    }
  }
}
