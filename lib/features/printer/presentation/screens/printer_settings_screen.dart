import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../injection_container.dart';
import '../bloc/printer_bloc.dart';

Future<bool> pushPrinterSettings({
  required BuildContext context,
}) async {
  await context.pushNamed(RouteNames.printerSettings);
  return true;
}

class PrinterSettingsScreen extends StatelessWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PrinterBloc>()..add(PrinterEventInitialize()),
      child: const _PrinterSettingsScreenContent(),
    );
  }
}

class _PrinterSettingsScreenContent extends StatelessWidget {
  const _PrinterSettingsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(
        title: context.appText.printer_settings_screen_title,
        action: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => context.read<PrinterBloc>().add(PrinterEventGetPairedDevices()),
          tooltip: context.appText.printer_refresh_devices,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.size16),
          child: BlocConsumer<PrinterBloc, PrinterState>(
            listener: (context, state) {
              if (state is PrinterStateSuccess) {
                context.showSnackbar(state.message);
              } else if (state is PrinterStateFailure) {
                context.showSnackbar(state.message);
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentPrinterStatus(context, state),
                  AppSizes.spaceHeight16,

                  // Available devices
                  Text(
                    context.appText.printer_available_printers,
                    style: AppTextStyle.heading3,
                  ),
                  AppSizes.spaceHeight8,

                  Expanded(
                    child: state is PrinterStateLoading
                        ? const WidgetLoading(usingPadding: true)
                        : _buildDevicesList(
                            context,
                            state,
                          ),
                  ),

                  AppSizes.spaceHeight16,

                  // Test print button
                  SizedBox(
                    width: double.infinity,
                    child: WidgetButton(
                      label: context.appText.printer_test_print,
                      isLoading: state is PrinterStateLoading,
                      onPressed: () {
                        final isConnected = state is PrinterStatePairedDevicesLoaded ? state.isConnected : state is PrinterStateConnected;

                        if (isConnected) {
                          serviceLocator<PrinterBloc>().add(PrinterEventPrintTest());
                        } else {
                          context.showSnackbar(context.appText.printer_please_connect);
                        }
                      },
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

  Widget _buildCurrentPrinterStatus(BuildContext context, PrinterState state) {
    final bool isConnected;
    BluetoothInfo? selectedDevice;

    if (state is PrinterStatePairedDevicesLoaded) {
      isConnected = state.isConnected;
      selectedDevice = state.selectedDevice;
    } else if (state is PrinterStateConnected) {
      isConnected = true;
      selectedDevice = state.device;
    } else {
      isConnected = false;
      selectedDevice = null;
    }

    return Container(
      padding: EdgeInsets.all(AppSizes.size16),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.size12),
        border: Border.all(
          color: isConnected ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.appText.printer_settings_screen_title,
                    style: AppTextStyle.heading3,
                  ),
                  AppSizes.spaceHeight8,
                  Text(
                    isConnected ? context.appText.printer_status_connected(selectedDevice?.name ?? '-') : context.appText.printer_status_not_connected,
                    style: AppTextStyle.body1,
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                    color: isConnected ? AppColors.success : AppColors.warning,
                  ),
                  AppSizes.spaceWidth12,
                ],
              ),
            ],
          ),
          if (isConnected) ...[
            AppSizes.spaceHeight12,
            WidgetButton(
              label: context.appText.printer_disconnect,
              backgroundColor: AppColors.warning,
              onPressed: () => context.read<PrinterBloc>().add(PrinterEventDisconnectDevice()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDevicesList(BuildContext context, PrinterState state) {
    if (state is PrinterStatePairedDevicesLoaded) {
      if (state.devices.isNotEmpty) {
        return ListView.separated(
          itemCount: state.devices.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final device = state.devices[index];
            final bool isSelected = state.selectedDevice?.macAdress == device.macAdress;

            return ListTile(
              leading: Icon(
                Icons.print,
                color: isSelected ? AppColors.primary : AppColors.gray,
              ),
              title: Text(
                device.name,
                style: AppTextStyle.body1.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
              subtitle: Text(device.macAdress),
              trailing: ElevatedButton(
                onPressed: () => context.read<PrinterBloc>().add(
                      PrinterEventConnectToDevice(device: device),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.isConnected && isSelected ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(state.isConnected && isSelected ? context.appText.printer_connected : context.appText.printer_connect),
              ),
              onTap: () => context.read<PrinterBloc>().add(
                    PrinterEventConnectToDevice(device: device),
                  ),
            );
          },
        );
      } else {
        return WidgetEmptyList(
          emptyMessage: context.appText.printer_no_printers_found,
          onRefresh: () => context.read<PrinterBloc>().add(PrinterEventGetPairedDevices()),
        );
      }
    } else {
      return WidgetEmptyList(
        emptyMessage: context.appText.printer_no_printers_found,
        onRefresh: () => context.read<PrinterBloc>().add(PrinterEventGetPairedDevices()),
      );
    }
  }
}
