import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';
import '../widgets/widget_delete_service.dart';

enum ManageServiceMode { add, edit, view }

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = true;
  Service? _currentService;
  late final ServiceBloc _serviceBloc;

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
      _serviceBloc.add(ServiceEventGetServices());
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
    final appText = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _serviceBloc,
      child: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceStateFailure) {
            showSnackbar(context, state.message);
          } else if (state is ServiceStateSuccessCreateService) {
            showSnackbar(context, appText.service_add_success_message);
            context.pop(true);
          } else if (state is ServiceStateSuccessUpdateService) {
            showSnackbar(context, appText.service_update_success_message);
            context.pop(true);
          } else if (state is ServiceStateSuccessDeleteService) {
            showSnackbar(context, appText.service_delete_success_message);
            context.pop(true);
          } else if (state is ServiceStateWithFilteredServices) {
            _handleServiceDataLoaded(state);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: WidgetAppBar(
              label: _getScreenTitle(appText),
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
                            _buildFormFields(state, appText),
                            SizedBox(height: AppSizes.size80),
                          ],
                        ),
                      ),
                    ),
                  ),
            bottomNavigationBar: _buildBottomBar(
              context,
              appText,
              state,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AppLocalizations appText,
    ServiceState state,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size16,
          right: AppSizes.size16,
          bottom: AppSizes.size16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isViewMode)
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label: appText.button_edit,
                      onPressed: () async {
                        if (_currentService != null) {
                          final result = await context.pushNamed(
                            'edit-service',
                            pathParameters: {
                              'id': _currentService!.id!.toString()
                            },
                          );

                          if (result == true && context.mounted) {
                            context.pop(true);
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
                      label:
                          _isAddMode ? appText.button_add : appText.button_save,
                      isLoading: state is ServiceStateLoading,
                      onPressed: _submitForm,
                    ),
                  ),
                ],
              ),
            if ((_isViewMode &&
                RoleManager.hasPermission(Permission.manageServices)))
              AppSizes.spaceHeight12,
            if ((_isViewMode &&
                RoleManager.hasPermission(Permission.manageServices)))
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label: appText.button_delete,
                      backgroundColor: AppColors.error,
                      onPressed: () {
                        deleteService(
                          context: context,
                          service: _currentService!,
                          serviceBloc: _serviceBloc,
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle(AppLocalizations appText) {
    if (_isAddMode) {
      return appText.service_add_screen_title;
    } else if (_isEditMode) {
      return appText.service_edit_screen_title;
    } else {
      return appText.service_view_screen_title;
    }
  }

  Widget _buildFormFields(ServiceState state, AppLocalizations appText) {
    final bool isFormEnabled = !_isViewMode && state is! ServiceStateLoading;

    if (_isViewMode) {
      return _buildServiceDetailView(appText);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetTextFormField(
          label: appText.form_name_label,
          hint: appText.form_name_hint,
          controller: _nameController,
          isEnabled: isFormEnabled,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return appText.form_name_required_message;
            }
            return null;
          },
        ),
        AppSizes.spaceHeight12,
        WidgetTextFormField(
          label: appText.form_description_label,
          hint: appText.form_description_hint,
          controller: _descriptionController,
          maxLines: 3,
          isEnabled: isFormEnabled,
        ),
        AppSizes.spaceHeight12,
        WidgetTextFormField(
          label: appText.form_price_label,
          hint: appText.form_price_hint,
          controller: _priceController,
          isEnabled: isFormEnabled,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return appText.form_price_required_message;
            }
            if (int.tryParse(value) == null) {
              return appText.form_price_digits_only_message;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildServiceDetailView(AppLocalizations appText) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: AppSizes.size80,
                height: AppSizes.size80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
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
                style: AppTextStyle.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.size24),
        _buildDetailCard(
          title: appText.service_information_card_label,
          content: [
            _buildDetailItem(
              icon: Icons.attach_money,
              label: appText.form_price_label,
              value: int.tryParse(_priceController.text)?.formatNumber() ?? '-',
            ),
          ],
        ),
        SizedBox(height: AppSizes.size16),
        _buildDetailCard(
          title: appText.service_description_card_label,
          content: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.size8,
              ),
              child: Text(
                _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : '-',
                style: AppTextStyle.body1.copyWith(
                  color: _descriptionController.text.isNotEmpty
                      ? AppColors.onSecondary
                      : AppColors.gray,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 2,
      surfaceTintColor: AppColors.primary,
      color: AppColors.onPrimary,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size16,
          right: AppSizes.size16,
          top: AppSizes.size16,
          bottom: AppSizes.size8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.size8),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.size20, color: AppColors.primary),
          SizedBox(width: AppSizes.size8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.body2.copyWith(
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: AppSizes.size4),
              Text(
                value,
                style: AppTextStyle.body1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _handleServiceDataLoaded(ServiceStateWithFilteredServices state) {
    if (widget.serviceId != null) {
      final service = state.allServices.firstWhere(
        (service) => service.id.toString() == widget.serviceId,
      );

      if (service.id != null) {
        _currentService = service;
        _nameController.text = service.name ?? '';
        _descriptionController.text = service.description ?? '';
        _priceController.text = service.price?.toString() ?? '';
        setState(() {
          _isLoading = false;
        });
      } else {
        showSnackbar(context, 'Service not found');
        context.pop();
      }
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
        _serviceBloc.add(ServiceEventCreateService(service: service));
      } else if (_isEditMode) {
        _serviceBloc.add(ServiceEventUpdateService(service: service));
      }
    }
  }
}
