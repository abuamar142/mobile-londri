part of 'service_bloc.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object> get props => [];
}

class ServiceEventGetServices extends ServiceEvent {}

class ServiceEventGetServiceById extends ServiceEvent {
  final String id;

  const ServiceEventGetServiceById({
    required this.id,
  });

  @override
  List<Object> get props => [
        id,
      ];
}

class ServiceEventCreateService extends ServiceEvent {
  final Service service;

  const ServiceEventCreateService({
    required this.service,
  });

  @override
  List<Object> get props => [
        service,
      ];
}

class ServiceEventUpdateService extends ServiceEvent {
  final Service service;

  const ServiceEventUpdateService({
    required this.service,
  });

  @override
  List<Object> get props => [
        service,
      ];
}

class ServiceEventDeleteService extends ServiceEvent {
  final String id;

  const ServiceEventDeleteService({
    required this.id,
  });

  @override
  List<Object> get props => [
        id,
      ];
}
