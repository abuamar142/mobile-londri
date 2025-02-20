import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';
import '../widgets/widget_text_form_field.dart';

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
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText.serviceTitle,
          style: AppTextstyle.title,
        ),
      ),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceStateFailure) {
            showSnackbar(context, state.message.toString());
          } else if (state is ServiceStateSuccessCreateService) {
            showSnackbar(context, appText.serviceAddSuccess);
          } else if (state is ServiceStateSuccessUpdateService) {
            showSnackbar(context, appText.serviceUpdateSuccess);
          } else if (state is ServiceStateSuccessDeleteService) {
            showSnackbar(context, appText.serviceDeleteSuccess);
          }
        },
        builder: (context, state) {
          if (state is ServiceStateLoading) {
            return LoadingWidget(usingPadding: true);
          } else if (state is ServiceStateSuccessGetServices) {
            return SafeArea(
              child: ListView.builder(
                itemCount: state.services.length,
                itemBuilder: (context, index) {
                  final Service service = state.services[index];

                  return ListTile(
                    key: ValueKey(service.id),
                    title: Text(service.name!, style: AppTextstyle.tileTitle),
                    subtitle: Text(
                      service.description ?? '-',
                      style: AppTextstyle.tileSubtitle,
                    ),
                    trailing: Text(
                      service.price!.formatNumber(),
                      style: AppTextstyle.tileTrailing,
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
                appText.serviceEmpty,
                style: AppTextstyle.body,
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
      title: appText.serviceAdd,
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
      title: appText.serviceEdit,
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
                  Text(title, style: AppTextstyle.title),
                  SizedBox(height: 8),
                  WidgetTextFormField(
                    label: appText.formNameLabel,
                    enabled: state is ServiceStateLoading ? false : true,
                    controller: _nameController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? appText.formNameHint : null,
                  ),
                  WidgetTextFormField(
                    label: appText.formDescriptionLabel,
                    enabled: state is ServiceStateLoading ? false : true,
                    maxLines: 3,
                    controller: _descriptionController,
                  ),
                  WidgetTextFormField(
                    label: appText.formPriceLabel,
                    enabled: state is ServiceStateLoading ? false : true,
                    controller: _priceController,
                    textInputType:
                        TextInputType.numberWithOptions(decimal: false),
                    validator: (value) =>
                        value?.isEmpty ?? true ? appText.formPriceHint : null,
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(
                        const Size(
                          double.infinity,
                          54,
                        ),
                      ),
                    ),
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
                    child: state is ServiceStateLoading
                        ? LoadingWidget()
                        : Text(
                            appText.buttonSubmit,
                            style: AppTextstyle.body,
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (showDeleteButton)
                    TextButton(
                      onPressed: () => deleteService(
                        service: service!,
                        appText: appText,
                      ),
                      child: state is ServiceStateLoading
                          ? LoadingWidget()
                          : Text(
                              appText.buttonDelete,
                              style: AppTextstyle.body,
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
      title: appText.serviceDelete,
      appText: appText,
      content: appText.serviceDeleteConfirm,
      onConfirm: () {
        context.read<ServiceBloc>().add(
              ServiceEventDeleteService(id: service.id!),
            );
        context.pop();
      },
    );
  }
}
