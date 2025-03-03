import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';

class SelectCustomerScreen extends StatefulWidget {
  const SelectCustomerScreen({super.key});

  @override
  State<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(
          CustomerEventGetCustomers(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText.customer_screen_title,
          style: AppTextstyle.title,
        ),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerStateFailure) {
            showSnackbar(context, state.message.toString());
          }
        },
        builder: (context, state) {
          if (state is CustomerStateLoading) {
            return WidgetLoading(usingPadding: true);
          } else if (state is CustomerStateSuccessGetCustomers) {
            return SafeArea(
              child: ListView.builder(
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final Customer customer = state.customers[index];

                  return ListTile(
                    key: ValueKey(customer.id),
                    title: Text(
                      customer.name!,
                      style: AppTextstyle.tileTitle.copyWith(
                        color: customer.isActive! ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      customer.description ?? '-',
                      style: AppTextstyle.tileSubtitle.copyWith(
                        color: customer.isActive! ? null : Colors.grey,
                      ),
                    ),
                    trailing: Text(
                      customer.phone.toString(),
                      style: AppTextstyle.tileTrailing.copyWith(
                        color: customer.isActive! ? null : Colors.grey,
                      ),
                    ),
                    onTap: () {
                      if (customer.isActive!) {
                        context.pop<Customer>(customer);
                      } else {
                        showSnackbar(
                          context,
                          appText.customer_info_non_active,
                        );
                      }
                    },
                  );
                },
              ),
            );
          } else {
            return Center(
              child: Text(
                appText.customer_empty_message,
                style: AppTextstyle.body,
              ),
            );
          }
        },
      ),
    );
  }
}
