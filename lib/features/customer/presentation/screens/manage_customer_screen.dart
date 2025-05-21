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
            ),
            body: _isLoading && !_isAddMode
                ? const WidgetLoading(usingPadding: true)
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.size16),
                      child: _buildCustomerForm(state, appText),
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

  Widget _buildBottomBar(
    BuildContext context,
    AppLocalizations appText,
    CustomerState state,
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
            if (_isAddMode || _isEditMode)
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label:
                          _isAddMode ? appText.button_add : appText.button_save,
                      isLoading: state is CustomerStateLoading,
                      onPressed: _submitForm,
                    ),
                  ),
                ],
              ),
            if ((_isViewMode &&
                RoleManager.hasPermission(Permission.deleteCustomer)))
              AppSizes.spaceHeight12,
            if ((_isViewMode &&
                RoleManager.hasPermission(Permission.deleteCustomer)))
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

    if (_isViewMode) {
      return _buildCustomerDetailView(appText);
    }

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
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.size4,
              bottom: AppSizes.size8,
            ),
            child: Text(
              appText.gender_label,
              style: AppTextStyle.body1.copyWith(
                color: isFormEnabled ? AppColors.onSecondary : AppColors.gray,
              ),
            ),
          ),
          _buildGenderSelection(isFormEnabled),
          AppSizes.spaceHeight12,
          WidgetTextFormField(
            label: appText.form_description_label,
            hint: appText.form_description_hint,
            controller: _descriptionController,
            maxLines: 3,
            isEnabled: isFormEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailView(AppLocalizations appText) {
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
                  _getGenderIcon(_selectedGender),
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
          title: appText.customer_information_card_label,
          content: [
            _buildDetailItem(
              icon: Icons.phone,
              label: appText.form_phone_label,
              value: _phoneController.text.isNotEmpty
                  ? _phoneController.text
                  : '-',
              trailing: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.send,
                        color: AppColors.primary,
                        size: AppSizes.size24,
                      ),
                      tooltip: appText.customer_send_whatsapp_message,
                      onPressed: () => _phoneController.text.isNotEmpty
                          ? () => launchWhatsapp(
                              phone: _phoneController.text, message: '')
                          : null,
                    )
                  : null,
            ),
            _buildDetailItem(
              icon: _getGenderIcon(_selectedGender),
              label: appText.gender_label,
              value: _getGenderName(_selectedGender),
            ),
          ],
        ),
        SizedBox(height: AppSizes.size16),
        _buildDetailCard(
          title: appText.customer_note_card_label,
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
        SizedBox(height: AppSizes.size16),
        _buildDetailCard(
          title: appText.customer_transaction_card_label,
          content: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSizes.size12),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: AppSizes.size40,
                      color: AppColors.gray,
                    ),
                    SizedBox(height: AppSizes.size8),
                    WidgetTextButton(
                      label: appText.customer_redirect_to_transaction_screen,
                      color: AppColors.primary,
                      onPressed: () {
                        // TODO: Implement navigation to transaction screen based on customer ID
                      },
                    )
                  ],
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
              style: AppTextStyle.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.size8),
            Divider(),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: AppSizes.size16,
      leading: Container(
        padding: EdgeInsets.all(AppSizes.size8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(
            alpha: 0.1,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppSizes.size20,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.caption.copyWith(
              color: AppColors.gray,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.body1.copyWith(
              color: AppColors.onSecondary,
            ),
          ),
        ],
      ),
      trailing: trailing,
    );
  }

  Widget _buildGenderSelection(bool enabled) {
    return GestureDetector(
      onTap: enabled ? () => _showGenderBottomSheet(context) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.size12,
          horizontal: AppSizes.size16,
        ),
        child: Row(
          children: [
            Icon(
              _getGenderIcon(_selectedGender),
              size: AppSizes.size24,
              color: enabled ? AppColors.onSecondary : AppColors.gray,
            ),
            SizedBox(width: AppSizes.size12),
            Expanded(
              child: Text(
                _getGenderName(_selectedGender),
                style: AppTextStyle.textField.copyWith(
                  color: enabled ? AppColors.onSecondary : AppColors.gray,
                ),
              ),
            ),
            if (enabled)
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.onSecondary,
              ),
          ],
        ),
      ),
    );
  }

  void _showGenderBottomSheet(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

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
                  appText.gender_label,
                  style: AppTextStyle.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          _buildGenderOption(Gender.male),
          _buildGenderOption(Gender.female),
          _buildGenderOption(Gender.other),
          SizedBox(height: AppSizes.size16),
        ],
      ),
    );
  }

  Widget _buildGenderOption(Gender gender) {
    final bool isSelected = _selectedGender == gender;

    return ListTile(
      leading: Icon(
        _getGenderIcon(gender),
        color: isSelected ? AppColors.primary : AppColors.gray,
      ),
      title: Text(
        _getGenderName(gender),
        style: AppTextStyle.body1.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.onSecondary,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
        Navigator.pop(context);
      },
    );
  }

  IconData _getGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.male:
        return Icons.man;
      case Gender.female:
        return Icons.woman;
      default:
        return Icons.person;
    }
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
      } else if (_isEditMode) {
        _customerBloc.add(CustomerEventUpdateCustomer(customer: customer));
      }
    }
  }
}
