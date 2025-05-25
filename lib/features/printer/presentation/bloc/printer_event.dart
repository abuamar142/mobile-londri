part of 'printer_bloc.dart';

abstract class PrinterEvent extends Equatable {
  const PrinterEvent();

  @override
  List<Object?> get props => [];
}

class PrinterEventInitialize extends PrinterEvent {}

class PrinterEventGetPairedDevices extends PrinterEvent {}

class PrinterEventConnectToDevice extends PrinterEvent {
  final BluetoothInfo device;

  const PrinterEventConnectToDevice({required this.device});

  @override
  List<Object?> get props => [device];
}

class PrinterEventDisconnectDevice extends PrinterEvent {}

class PrinterEventPrintInvoice extends PrinterEvent {
  final Transaction transaction;
  final String businessName;
  final String businessAddress;
  final String businessPhone;

  const PrinterEventPrintInvoice({
    required this.transaction,
    required this.businessName,
    required this.businessAddress,
    required this.businessPhone,
  });

  @override
  List<Object?> get props => [transaction, businessName, businessAddress, businessPhone];
}

class PrinterEventPrintTest extends PrinterEvent {}

class PrinterEventClearSavedPrinter extends PrinterEvent {}
