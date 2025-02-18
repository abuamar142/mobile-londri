import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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
        bloc: serviceLocator<ServiceBloc>()
          ..add(
            ServiceEventGetServices(),
          ),
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
    );
  }
}
