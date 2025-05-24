part of 'service_bloc.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object> get props => [];
}

class ServiceStateInitial extends ServiceState {}

class ServiceStateLoading extends ServiceState {}

class ServiceStateWithFilteredServices extends ServiceState {
  final List<Service> allServices;
  final List<Service> filteredServices;

  const ServiceStateWithFilteredServices({
    required this.allServices,
    required this.filteredServices,
  });

  @override
  List<Object> get props => [allServices, filteredServices];
}

class ServiceStateSuccessGetServices extends ServiceState {
  final List<Service> services;

  const ServiceStateSuccessGetServices({
    required this.services,
  });

  @override
  List<Object> get props => [services];
}

class ServiceStateSuccessGetActiveServices extends ServiceState {
  final List<Service> activeServices;

  const ServiceStateSuccessGetActiveServices({
    required this.activeServices,
  });

  @override
  List<Object> get props => [activeServices];
}

class ServiceStateSuccessGetServiceById extends ServiceState {
  final Service service;

  const ServiceStateSuccessGetServiceById({
    required this.service,
  });

  @override
  List<Object> get props => [service];
}

class ServiceStateSuccessCreateService extends ServiceState {}

class ServiceStateSuccessUpdateService extends ServiceState {}

class ServiceStateSuccessDeleteService extends ServiceState {}

class ServiceStateSuccessActivateService extends ServiceState {}

class ServiceStateFailure extends ServiceState {
  final String message;

  const ServiceStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
