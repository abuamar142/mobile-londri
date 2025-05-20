import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';
import '../widgets/widget_text_form_field.dart';

void pushServices(BuildContext context) {
  context.pushNamed('services');
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(
          ServiceEventGetServices(),
        );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText.service_screen_title,
          style: AppTextStyle.title,
        ),
      ),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceStateFailure) {
            showSnackbar(context, state.message.toString());
          } else if (state is ServiceStateSuccessCreateService) {
            showSnackbar(context, appText.service_add_success_message);
          } else if (state is ServiceStateSuccessUpdateService) {
            showSnackbar(context, appText.service_update_success_message);
          } else if (state is ServiceStateSuccessDeleteService) {
            showSnackbar(context, appText.service_delete_success_message);
          }
        },
        builder: (context, state) {
          if (state is ServiceStateLoading) {
            return WidgetLoading(usingPadding: true);
          } else if (state is ServiceStateSuccessGetServices) {
            return SafeArea(
              child: ListView.builder(
                itemCount: state.services.length,
                itemBuilder: (context, index) {
                  final Service service = state.services[index];

                  return ListTile(
                    key: ValueKey(service.id),
                    title: Text(service.name!, style: AppTextStyle.tileTitle),
                    subtitle: Text(
                      service.description ?? '-',
                      style: AppTextStyle.tileSubtitle,
                    ),
                    trailing: Text(
                      service.price!.formatNumber(),
                      style: AppTextStyle.tileTrailing,
                    ),
                    onTap: () => editService(
                      service: service,
                      appText: appText,
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text(
                appText.service_empty_message,
                style: AppTextStyle.body,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addService(
          appText: appText,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void addService({
    required AppLocalizations appText,
  }) {
    _showServiceDialog(
      context: context,
      appText: appText,
      title: appText.service_add_dialog_title,
      onSubmit: (Service service) {
        context
            .read<ServiceBloc>()
            .add(ServiceEventCreateService(service: service));
        context.pop();
      },
    );
  }

  void editService({
    required Service service,
    required AppLocalizations appText,
  }) {
    _showServiceDialog(
      context: context,
      appText: appText,
      title: appText.service_edit_dialog_title,
      service: service,
      showDeleteButton: true,
      onSubmit: (Service newService) {
        context
            .read<ServiceBloc>()
            .add(ServiceEventUpdateService(service: newService));
        context.pop();
      },
    );
  }

  void _showServiceDialog({
    required BuildContext context,
    required AppLocalizations appText,
    required String title,
    Service? service,
    required Function(Service) onSubmit,
    showDeleteButton = false,
  }) {
    if (service != null) {
      _nameController.text = service.name!;
      _descriptionController.text = service.description ?? '';
      _priceController.text = service.price.toString();
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Form(
          key: _formKey,
          child: BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyle.title),
                  SizedBox(height: 8),
                  WidgetTextFormField(
                    label: appText.form_name_label,
                    enabled: state is! ServiceStateLoading,
                    controller: _nameController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? appText.form_name_hint : null,
                  ),
                  WidgetTextFormField(
                    label: appText.form_description_label,
                    enabled: state is! ServiceStateLoading,
                    maxLines: 3,
                    controller: _descriptionController,
                  ),
                  WidgetTextFormField(
                    label: appText.form_price_label,
                    enabled: state is! ServiceStateLoading,
                    controller: _priceController,
                    textInputType:
                        TextInputType.numberWithOptions(decimal: false),
                    validator: (value) =>
                        value?.isEmpty ?? true ? appText.form_price_hint : null,
                  ),
                  const SizedBox(height: 4),
                  WidgetButton(
                    label: appText.button_submit,
                    isLoading: state is ServiceStateLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newService = Service(
                          id: service?.id,
                          name: _nameController.text,
                          description: _descriptionController.text,
                          price: int.parse(_priceController.text),
                        );

                        onSubmit(newService);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (showDeleteButton)
                    WidgetTextButton(
                      label: appText.button_delete,
                      isLoading: state is ServiceStateLoading,
                      onPressed: () => deleteService(
                        service: service!,
                        appText: appText,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void deleteService({
    required Service service,
    required AppLocalizations appText,
  }) {
    context.pop();

    showConfirmationDialog(
      context: context,
      title: appText.service_delete_dialog_title,
      content: appText.service_delete_confirm_message,
      onConfirm: () {
        context.read<ServiceBloc>().add(
              ServiceEventDeleteService(id: service.id!),
            );
        context.pop();
      },
    );
  }
}
