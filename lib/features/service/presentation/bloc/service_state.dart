part of 'service_bloc.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object> get props => [];
}

class ServiceStateInitial extends ServiceState {}

class ServiceStateLoading extends ServiceState {}

class ServiceStateSuccessGetServices extends ServiceState {
  final List<Service> services;

  const ServiceStateSuccessGetServices({
    required this.services,
  });

  @override
  List<Object> get props => [
        services,
      ];
}

class ServiceStateSuccessGetServiceById extends ServiceState {
  final Service service;

  const ServiceStateSuccessGetServiceById({
    required this.service,
  });

  @override
  List<Object> get props => [
        service,
      ];
}

class ServiceStateSuccessCreateService extends ServiceState {}

class ServiceStateSuccessUpdateService extends ServiceState {}

class ServiceStateSuccessDeleteService extends ServiceState {}

class ServiceStateFailure extends ServiceState {
  final String message;

  const ServiceStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}
