import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
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

  Widget _buildViewModeBottomBar(
    BuildContext context,
    AppLocalizations appText,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size16,
          right: AppSizes.size16,
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
                        if (_currentCustomer != null) {
                          final result = await context.pushNamed(
                            'edit-customer',
                            pathParameters: {
                              'id': _currentCustomer!.id!.toString()
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
          AppSizes.spaceHeight12,
          WidgetTextFormField(
            label: appText.form_phone_label,
            hint: appText.form_phone_hint,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            isEnabled: isFormEnabled,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              } else if (value.length < 10 || value.length > 13) {
                return appText.form_phone_digit_length_message;
              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return appText.form_phone_digits_only_message;
              }
              return null;
            },
          ),
          AppSizes.spaceHeight12,
          Text(
            appText.gender_label,
            style: AppTextStyle.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSizes.spaceHeight8,
          _buildGenderSelection(isFormEnabled),
          AppSizes.spaceHeight12,
          WidgetTextFormField(
            label: appText.form_description_label,
            hint: appText.form_description_hint,
            controller: _descriptionController,
            maxLines: 3,
            isEnabled: isFormEnabled,
          ),
          AppSizes.spaceHeight16,
          if (!_isViewMode)
            WidgetButton(
              label: _isAddMode ? appText.button_add : appText.button_save,
              isLoading: state is CustomerStateLoading,
              onPressed: _submitForm,
            ),
        ],
      ),
    );
  }

  Widget _buildGenderSelection(bool enabled) {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.size8,
          ),
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
    );
  }

  String _getGenderName(Gender gender) {
    switch (gender) {
      case Gender.male:
        return AppLocalizations.of(context)!.gender_male;
      case Gender.female:
        return AppLocalizations.of(context)!.gender_female;
      default:
        return AppLocalizations.of(context)!.gender_other;
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
