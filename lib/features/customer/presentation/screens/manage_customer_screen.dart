import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/launch_whatsapp.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_detail_card.dart';
import '../../../../core/widgets/widget_detail_card_item.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../../transaction/presentation/screens/transactions_screen.dart';
import '../../../transaction/presentation/widgets/widget_bottom_bar.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/gender.dart';
import '../bloc/customer_bloc.dart';
import '../widgets/widget_deactivate_customer.dart';
import '../widgets/widget_dropdown.dart';
import '../widgets/widget_hard_delete_customer.dart';

enum ManageCustomerMode { add, edit, view }

Future<bool> pushAddCustomer({
  required BuildContext context,
}) async {
  await context.pushNamed(RouteNames.addCustomer);
  return true;
}

Future<bool> pushViewCustomer({
  required BuildContext context,
  required String customerId,
}) async {
  await context.pushNamed(
    RouteNames.viewCustomer,
    pathParameters: {'id': customerId},
  );
  return true;
}

Future<bool> pushEditCustomer({
  required BuildContext context,
  required String customerId,
}) async {
  await context.pushNamed(
    RouteNames.editCustomer,
    pathParameters: {'id': customerId},
  );
  return true;
}

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
  late final CustomerBloc _customerBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;
  Gender _selectedGender = Gender.other;
  Customer? _currentCustomer;

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _customerBloc,
      child: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is CustomerStateSuccessCreateCustomer) {
            context.showSnackbar(context.appText.customer_add_success_message);
            context.pop(true);
          } else if (state is CustomerStateSuccessUpdateCustomer) {
            context.showSnackbar(context.appText.customer_update_success_message);
            context.pop();
          } else if (state is CustomerStateSuccessActivateCustomer) {
            context.showSnackbar(context.appText.customer_activate_success_message);
          } else if (state is CustomerStateSuccessDeactivateCustomer) {
            context.showSnackbar(context.appText.customer_deactivate_success_message);
            context.pop();
          } else if (state is CustomerStateSuccessHardDeleteCustomer) {
            context.showSnackbar(context.appText.customer_hard_delete_success_message);
            context.pop();
          } else if (state is CustomerStateSuccessGetCustomerById) {
            _handleCustomerDataLoaded(state);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: WidgetAppBar(
              title: _getScreenTitle(),
            ),
            body: _isLoading && !_isAddMode
                ? const WidgetLoading(usingPadding: true)
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.size16),
                      child: _buildCustomerForm(),
                    ),
                  ),
            bottomNavigationBar: WidgetBottomBar(
              content: [
                if (_isViewMode)
                  Row(
                    children: [
                      Expanded(
                        child: WidgetButton(
                          label: context.appText.button_edit,
                          onPressed: () async {
                            if (_currentCustomer != null) {
                              final result = await pushEditCustomer(
                                context: context,
                                customerId: _currentCustomer!.id!.toString(),
                              );

                              if (result && context.mounted) {
                                _customerBloc.add(
                                  CustomerEventGetCustomerById(
                                    customerId: _currentCustomer!.id!.toString(),
                                  ),
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
                          isLoading: _customerBloc.state is CustomerStateLoading,
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
                              onPressed: () => deactivateCustomer(
                                context: context,
                                customer: _currentCustomer!,
                                customerBloc: _customerBloc,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_isViewMode && RoleManager.hasPermission(Permission.hardDeleteCustomer))
                        Column(
                          children: [
                            AppSizes.spaceHeight12,
                            Row(
                              children: [
                                Expanded(
                                  child: WidgetButton(
                                    label: context.appText.button_hard_delete,
                                    backgroundColor: AppColors.error,
                                    onPressed: () => hardDeleteCustomer(
                                      context: context,
                                      customer: _currentCustomer!,
                                      customerBloc: _customerBloc,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getScreenTitle() {
    switch (widget.mode) {
      case ManageCustomerMode.add:
        return context.appText.customer_add_dialog_title;
      case ManageCustomerMode.edit:
        return context.appText.customer_edit_dialog_title;
      case ManageCustomerMode.view:
        return context.appText.customer_view_dialog_title;
    }
  }

  Widget _buildCustomerForm() {
    final bool isFormEnabled = !_isViewMode && _customerBloc.state is! CustomerStateLoading;

    if (_isViewMode) {
      return _buildCustomerDetailView();
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetTextFormField(
            label: context.appText.form_name_label,
            hint: context.appText.form_name_hint,
            controller: _nameController,
            isEnabled: isFormEnabled,
            validator: (value) => value?.isEmpty ?? true ? context.appText.form_name_hint : null,
          ),
          AppSizes.spaceHeight12,
          WidgetTextFormField(
            label: context.appText.form_phone_label,
            hint: context.appText.form_phone_hint,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            isEnabled: isFormEnabled,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null;
              } else if (value.length < 10 || value.length > 13) {
                return context.appText.form_phone_digit_length_message;
              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return context.appText.form_phone_digits_only_message;
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
              context.appText.gender_label,
              style: AppTextStyle.body1.copyWith(
                color: isFormEnabled ? AppColors.onSecondary : AppColors.gray,
              ),
            ),
          ),
          _buildGenderSelection(isFormEnabled),
          AppSizes.spaceHeight12,
          WidgetTextFormField(
            label: context.appText.form_description_label,
            hint: context.appText.form_description_hint,
            controller: _descriptionController,
            maxLines: 3,
            isEnabled: isFormEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailView() {
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
                  _selectedGender.icon,
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
        WidgetDetailCard(
          title: context.appText.customer_information_card_label,
          content: [
            WidgetDetailCardItem(
              icon: Icons.phone,
              label: context.appText.form_phone_label,
              value: _phoneController.text.isNotEmpty ? _phoneController.text : '-',
              trailing: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.message,
                        color: AppColors.primary,
                        size: AppSizes.size24,
                      ),
                      tooltip: context.appText.customer_send_whatsapp_message,
                      onPressed: () => contactCustomer(_phoneController.text),
                    )
                  : null,
            ),
            WidgetDetailCardItem(
              icon: _selectedGender.icon,
              label: context.appText.gender_label,
              value: getGenderValue(context, _selectedGender),
            ),
          ],
        ),
        SizedBox(height: AppSizes.size16),
        WidgetDetailCard(
          title: context.appText.customer_invoice_card_label,
          content: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.size8,
              ),
              child: Text(
                _descriptionController.text.isNotEmpty ? _descriptionController.text : '-',
                style: AppTextStyle.body1.copyWith(
                  color: _descriptionController.text.isNotEmpty ? AppColors.onSecondary : AppColors.gray,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.size16),
        WidgetDetailCard(
          title: context.appText.customer_transaction_card_label,
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
                      label: context.appText.customer_redirect_to_transaction_screen,
                      color: AppColors.primary,
                      onPressed: () async {
                        pushTransactions(
                          context: context,
                          searchQuery: _currentCustomer?.name,
                        );
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

  Widget _buildGenderSelection(bool enabled) {
    return GestureDetector(
      onTap: enabled
          ? () => showDropdownBottomSheet(
                context: context,
                title: context.appText.gender_label,
                items: [
                  WidgetDropdownBottomSheetItem(
                    isSelected: _selectedGender == Gender.male,
                    leadingIcon: Gender.male.icon,
                    title: getGenderValue(context, Gender.male),
                    onTap: () {
                      setState(() {
                        _selectedGender = Gender.male;
                      });
                    },
                  ),
                  WidgetDropdownBottomSheetItem(
                    isSelected: _selectedGender == Gender.female,
                    leadingIcon: Gender.female.icon,
                    title: getGenderValue(context, Gender.female),
                    onTap: () {
                      setState(() {
                        _selectedGender = Gender.female;
                      });
                    },
                  ),
                  WidgetDropdownBottomSheetItem(
                    isSelected: _selectedGender == Gender.other,
                    leadingIcon: Gender.other.icon,
                    title: getGenderValue(context, Gender.other),
                    onTap: () {
                      setState(() {
                        _selectedGender = Gender.other;
                      });
                    },
                  ),
                ],
              )
          : null,
      child: WidgetDropdown(
        icon: _selectedGender.icon,
        label: getGenderValue(context, _selectedGender),
        isEnable: enabled,
      ),
    );
  }

  void _loadCustomerData() => _customerBloc.add(
        CustomerEventGetCustomerById(customerId: widget.customerId!),
      );

  void _handleCustomerDataLoaded(CustomerStateSuccessGetCustomerById state) {
    if (widget.customerId != null) {
      final customer = state.customer;

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
        context.showSnackbar(context.appText.customer_empty_message);
        context.pop();
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final customer = Customer(
        id: _isAddMode ? null : _currentCustomer!.id,
        name: _isAddMode && _nameController.text.isEmpty ? null : _nameController.text,
        phone: _isAddMode && _phoneController.text.isEmpty ? null : _phoneController.text,
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

void contactCustomer(String phone) {
  if (phone.isNotEmpty) {
    launchWhatsapp(phone: phone, message: '');
  }
}
