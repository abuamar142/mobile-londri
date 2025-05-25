part of 'printer_bloc.dart';

abstract class PrinterState extends Equatable {
  const PrinterState();

  @override
  List<Object?> get props => [];
}

class PrinterStateInitial extends PrinterState {}

class PrinterStateLoading extends PrinterState {}

class PrinterStatePairedDevicesLoaded extends PrinterState {
  final List<BluetoothInfo> devices;
  final BluetoothInfo? selectedDevice;
  final bool isConnected;

  const PrinterStatePairedDevicesLoaded({
    required this.devices,
    this.selectedDevice,
    required this.isConnected,
  });

  @override
  List<Object?> get props => [devices, selectedDevice, isConnected];
}

class PrinterStateConnected extends PrinterState {
  final BluetoothInfo device;

  const PrinterStateConnected({required this.device});

  @override
  List<Object?> get props => [device];
}

class PrinterStateDisconnected extends PrinterState {}

class PrinterStatePrinting extends PrinterState {}

class PrinterStateSuccess extends PrinterState {
  final String message;

  const PrinterStateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class PrinterStateFailure extends PrinterState {
  final String message;

  const PrinterStateFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
