import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/services/printer_service.dart';
import '../../../transaction/domain/entities/payment_status.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/domain/entities/transaction_status.dart';

part 'printer_event.dart';
part 'printer_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final PrinterService printerService;
  final PermissionService permissionService;

  PrinterBloc({
    required this.printerService,
    required this.permissionService,
  }) : super(PrinterStateInitial()) {
    on<PrinterEventInitialize>(_onPrinterEventInitialize);
    on<PrinterEventGetPairedDevices>(_onPrinterEventGetPairedDevices);
    on<PrinterEventConnectToDevice>(_onPrinterEventConnectToDevice);
    on<PrinterEventDisconnectDevice>(_onPrinterEventDisconnectDevice);
    on<PrinterEventPrintInvoice>(_onPrinterEventPrintInvoice);
    on<PrinterEventPrintTest>(_onPrinterEventPrintTest);
    on<PrinterEventClearSavedPrinter>(_onPrinterEventClearSavedPrinter);
  }

  Future<void> _onPrinterEventInitialize(
    PrinterEventInitialize event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterStateLoading());

    try {
      // Request permissions
      final permissionStatuses = await permissionService.requestBluetoothPermissions();

      // Check if any permission was denied
      if (permissionStatuses.values.any((status) => !status.isGranted)) {
        emit(const PrinterStateFailure(message: 'Bluetooth permissions are required'));
        return;
      }

      await printerService.init();

      final devices = await printerService.getBondedDevices();
      final selectedDevice = printerService.selectedDevice;
      final isConnected = printerService.isConnected;

      emit(PrinterStatePairedDevicesLoaded(
        devices: devices,
        selectedDevice: selectedDevice,
        isConnected: isConnected,
      ));

      if (isConnected && selectedDevice != null) {
        emit(PrinterStateConnected(device: selectedDevice));
      }
    } catch (e) {
      emit(PrinterStateFailure(message: 'Failed to initialize printer: ${e.toString()}'));
    }
  }

  Future<void> _onPrinterEventGetPairedDevices(
    PrinterEventGetPairedDevices event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterStateLoading());

    try {
      final devices = await printerService.getBondedDevices();
      emit(PrinterStatePairedDevicesLoaded(
        devices: devices,
        selectedDevice: printerService.selectedDevice,
        isConnected: printerService.isConnected,
      ));
    } catch (e) {
      emit(PrinterStateFailure(message: 'Failed to get paired devices: ${e.toString()}'));
    }
  }

  Future<void> _onPrinterEventConnectToDevice(
    PrinterEventConnectToDevice event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterStateLoading());

    try {
      final connected = await printerService.connectToDevice(event.device);

      if (connected) {
        emit(PrinterStateConnected(device: event.device));
        emit(PrinterStateSuccess(message: 'Successfully connected to ${event.device.name}'));
      } else {
        emit(PrinterStateFailure(message: 'Failed to connect to ${event.device.name}'));
      }

      // Update device list after connection attempt
      add(PrinterEventGetPairedDevices());
    } catch (e) {
      emit(PrinterStateFailure(message: 'Error connecting to printer: ${e.toString()}'));
    }
  }

  Future<void> _onPrinterEventDisconnectDevice(
    PrinterEventDisconnectDevice event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterStateLoading());

    try {
      final disconnected = await printerService.disconnect();

      if (disconnected) {
        emit(PrinterStateDisconnected());
        emit(const PrinterStateSuccess(message: 'Successfully disconnected from printer'));
      } else {
        emit(const PrinterStateFailure(message: 'Failed to disconnect from printer'));
      }

      add(PrinterEventGetPairedDevices());
    } catch (e) {
      emit(PrinterStateFailure(message: 'Error disconnecting printer: ${e.toString()}'));
    }
  }

  Future<void> _onPrinterEventPrintInvoice(
    PrinterEventPrintInvoice event,
    Emitter<PrinterState> emit,
  ) async {
    if (!printerService.isConnected) {
      emit(const PrinterStateFailure(message: 'Printer not connected'));
      return;
    }

    emit(PrinterStatePrinting());

    try {
      final success = await printerService.printInvoice(
        context: event.context,
        transaction: event.transaction,
        businessName: event.businessName,
        businessAddress: event.businessAddress,
        businessPhone: event.businessPhone,
      );

      if (success) {
        emit(const PrinterStateSuccess(message: 'Invoice printed successfully'));
      } else {
        emit(const PrinterStateFailure(message: 'Failed to print invoice'));
      }
    } catch (e) {
      emit(PrinterStateFailure(message: 'Error printing invoice: ${e.toString()}'));
    }
  }

  Future<void> _onPrinterEventPrintTest(
    PrinterEventPrintTest event,
    Emitter<PrinterState> emit,
  ) async {
    if (!printerService.isConnected) {
      emit(const PrinterStateFailure(message: 'Printer not connected'));
      return;
    }

    emit(PrinterStatePrinting());

    try {
      // Create a sample transaction for test printing
      final sampleTransaction = Transaction(
        id: "TEST12345",
        customerName: "Test Customer",
        serviceName: "Regular Wash",
        weight: 3.5,
        amount: 70000,
        description: "Test invoice printing",
        transactionStatus: TransactionStatus.onProgress,
        paymentStatus: PaymentStatus.paid,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now(),
      );

      final success = await printerService.printInvoice(
        context: event.context,
        transaction: sampleTransaction,
        businessName: "Laundry Now",
        businessAddress: "Jl. Jalan",
        businessPhone: "0812-xxxx-xxxx",
      );

      if (success) {
        emit(const PrinterStateSuccess(message: 'Test print successful'));
      } else {
        emit(const PrinterStateFailure(message: 'Test print failed'));
      }
    } catch (e) {
      emit(PrinterStateFailure(message: 'Error during test print: ${e.toString()}'));
    }
  }

  Future<void> _onPrinterEventClearSavedPrinter(
    PrinterEventClearSavedPrinter event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterStateLoading());

    try {
      final cleared = await printerService.clearSavedPrinter();

      if (cleared) {
        emit(const PrinterStateSuccess(message: 'Saved printer cleared'));
        emit(PrinterStateDisconnected());
      } else {
        emit(const PrinterStateFailure(message: 'Failed to clear saved printer'));
      }

      add(PrinterEventGetPairedDevices());
    } catch (e) {
      emit(PrinterStateFailure(message: 'Error clearing saved printer: ${e.toString()}'));
    }
  }
}
