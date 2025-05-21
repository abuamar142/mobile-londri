import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/launch_whatsapp.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../widgets/widget_delete_customer.dart';

enum ManageCustomerMode { add, edit, view }

class ManageCustomerScreen extends StatefulWidget {
  final ManageCustomerMode mode;
  final String? customerId;

  const ManageCustomerScreen({
    super.key,
    required this.mode,
    this.customerId,
  });

  @override
  State<ManageCustomerScreen> createState() => _ManageCustomerScreenState();
}

class _ManageCustomerScreenState extends State<ManageCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late final CustomerBloc _customerBloc;
  Gender _selectedGender = Gender.other;
  Customer? _currentCustomer;
  bool _isLoading = true;

  bool get _isViewMode => widget.mode == ManageCustomerMode.view;
  bool get _isEditMode => widget.mode == ManageCustomerMode.edit;
  bool get _isAddMode => widget.mode == ManageCustomerMode.add;

  @override
  void initState() {
    super.initState();
    _customerBloc = serviceLocator<CustomerBloc>();

    if (_isAddMode) {
      _isLoading = false;
    } else if (widget.customerId != null) {
      _loadCustomerData();
    }
  }

  void _loadCustomerData() {
    _customerBloc.add(CustomerEventGetCustomers());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _customerBloc,
      child: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerStateFailure) {
            showSnackbar(context, state.message);
          } else if (state is CustomerStateSuccessCreateCustomer) {
            showSnackbar(context, appText.customer_add_success_message);
            context.pop(true);
          } else if (state is CustomerStateSuccessUpdateCustomer) {
            showSnackbar(context, appText.customer_update_success_message);
            context.pop(true);
          } else if (state is CustomerStateSuccessDeleteCustomer) {
            showSnackbar(context, appText.customer_delete_success_message);
            context.pop(true);
          } else if (state is CustomerStateWithFilteredCustomers &&
              _currentCustomer == null) {
            _handleCustomerDataLoaded(state);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _getScreenTitle(appText),
                style: AppTextStyle.heading3,
              ),
              centerTitle: true,
              actions: _buildAppBarActions(appText),
            ),
            body: _isLoading && !_isAddMode
                ? const WidgetLoading(usingPadding: true)
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.size16),
                      child: _buildCustomerForm(state, appText),
                    ),
                  ),
            bottomNavigationBar:
                _isViewMode ? _buildViewModeBottomBar(context, appText) : null,
          );
        },
      ),
    );
  }

  String _getScreenTitle(AppLocalizations appText) {
    switch (widget.mode) {
      case ManageCustomerMode.add:
        return appText.customer_add_dialog_title;
      case ManageCustomerMode.edit:
        return appText.customer_edit_dialog_title;
      case ManageCustomerMode.view:
        return appText.customer_view_dialog_title;
    }
  }

  List<Widget> _buildAppBarActions(AppLocalizations appText) {
    if (_isEditMode &&
        _currentCustomer?.phone != null &&
        _currentCustomer!.phone!.isNotEmpty) {
      return [
        IconButton(
          icon: const Icon(Icons.message),
          onPressed: () {
            launchWhatsapp(phone: _currentCustomer!.phone!, message: '');
          },
        ),
      ];
    }
    return [];
  }

  Widget _buildViewModeBottomBar(
    BuildContext context,
    AppLocalizations appText,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.size16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isViewMode)
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label: appText.button_edit,
                      onPressed: () {
                        if (_currentCustomer != null) {
                          context.pushReplacementNamed(
                            'edit-customer',
                            pathParameters: {
                              'id': _currentCustomer!.id!.toString()
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            AppSizes.spaceHeight12,
            if (RoleManager.hasPermission(Permission.deleteCustomer))
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label: appText.button_delete,
                      backgroundColor: AppColors.error,
                      onPressed: () {
                        deleteCustomer(
                          context: context,
                          customer: _currentCustomer!,
                          customerBloc: _customerBloc,
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

  Widget _buildCustomerForm(CustomerState state, AppLocalizations appText) {
    final bool isFormEnabled = !_isViewMode && state is! CustomerStateLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetTextFormField(
            label: appText.form_name_label,
            hint: appText.form_name_hint,
            controller: _nameController,
            isEnabled: isFormEnabled,
            validator: (value) =>
                value?.isEmpty ?? true ? appText.form_name_hint : null,
          ),
          const SizedBox(height: AppSizes.size16),
          WidgetTextFormField(
            label: appText.form_phone_label,
            hint: appText.form_phone_hint,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            isEnabled: isFormEnabled,
          ),
          const SizedBox(height: AppSizes.size16),
          Text(
            'Gender',
            style: AppTextStyle.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.size8),
          _buildGenderSelection(isFormEnabled),
          const SizedBox(height: AppSizes.size16),
          WidgetTextFormField(
            label: appText.form_description_label,
            hint: 'Enter additional notes about the customer',
            controller: _descriptionController,
            maxLines: 3,
            isEnabled: isFormEnabled,
          ),
          const SizedBox(height: AppSizes.size24),
          if (!_isViewMode)
            WidgetButton(
              label: _isAddMode ? 'Add' : 'Update',
              isLoading: state is CustomerStateLoading,
              onPressed: _submitForm,
            ),
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.size16),
              child: WidgetTextButton(
                label: appText.button_delete,
                isLoading: state is CustomerStateLoading,
                onPressed: () => deleteCustomer(
                  context: context,
                  customer: _currentCustomer!,
                  customerBloc: _customerBloc,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection(bool enabled) {
    return Column(
      children: [
        DropdownButtonFormField<Gender>(
          value: _selectedGender,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.size8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.size16,
              vertical: AppSizes.size12,
            ),
            filled: !enabled,
            fillColor: enabled
                ? null
                : Colors.grey.withValues(
                    alpha: 0.1,
                  ),
          ),
          items: Gender.values.map((gender) {
            return DropdownMenuItem(
              value: gender,
              child: Text(_getGenderName(gender)),
            );
          }).toList(),
          onChanged: enabled
              ? (Gender? value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                }
              : null,
        ),
      ],
    );
  }

  String _getGenderName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      default:
        return 'Other';
    }
  }

  void _handleCustomerDataLoaded(CustomerStateWithFilteredCustomers state) {
    if (widget.customerId != null) {
      final customer = state.allCustomers.firstWhere(
        (customer) => customer.id.toString() == widget.customerId,
      );

      if (customer.id != null) {
        _currentCustomer = customer;
        _nameController.text = customer.name ?? '';
        _phoneController.text = customer.phone ?? '';
        _descriptionController.text = customer.description ?? '';
        _selectedGender = customer.gender ?? Gender.other;
        setState(() {
          _isLoading = false;
        });
      } else {
        showSnackbar(context, 'Customer not found');
        context.pop();
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final customer = Customer(
        id: _isAddMode ? null : _currentCustomer!.id,
        name: _isAddMode && _nameController.text.isEmpty
            ? null
            : _nameController.text,
        phone: _isAddMode && _phoneController.text.isEmpty
            ? null
            : _phoneController.text,
        description: _descriptionController.text,
        isActive: _currentCustomer?.isActive ?? true,
        gender: _selectedGender,
      );

      if (_isAddMode) {
        _customerBloc.add(CustomerEventCreateCustomer(customer: customer));
      } else {
        _customerBloc.add(CustomerEventUpdateCustomer(customer: customer));
      }
    }
  }
}
