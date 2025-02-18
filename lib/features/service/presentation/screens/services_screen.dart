import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';
import '../widgets/custom_text_form_field.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Services',
          style: AppTextstyle.title,
        ),
      ),
      body: BlocConsumer<ServiceBloc, ServiceState>(
        listener: (context, state) {
          if (state is ServiceStateFailure) {
            showSnackbar(context, state.message.toString());
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
                    title: Text(service.name!),
                    subtitle: Text(service.description ?? '-'),
                    trailing: Text(
                      service.price.toString(),
                      style: AppTextstyle.body,
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text('No services found'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool isEnable =
              context.read<ServiceBloc>().state is! ServiceStateLoading;

          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      label: 'Name',
                      enabled: isEnable,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    CustomTextFormField(
                      label: 'Description',
                      enabled: isEnable,
                      controller: _descriptionController,
                    ),
                    CustomTextFormField(
                      label: 'Price',
                      enabled: isEnable,
                      controller: _priceController,
                      textInputType: TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      child: Text(
                        'Submit',
                        style: AppTextstyle.body,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final Service service = Service(
                            name: _nameController.text,
                            description: _descriptionController.text,
                            price: int.parse(_priceController.text),
                          );

                          context.read<ServiceBloc>().add(
                                ServiceEventCreateService(
                                  service: service,
                                ),
                              );

                          context.pushReplacementNamed('services');
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
