part of 'service_bloc.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object> get props => [];
}

class ServiceEventGetServices extends ServiceEvent {}

class ServiceEventGetActiveServices extends ServiceEvent {}

class ServiceEventGetServiceById extends ServiceEvent {
  final String id;

  const ServiceEventGetServiceById({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class ServiceEventCreateService extends ServiceEvent {
  final Service service;

  const ServiceEventCreateService({
    required this.service,
  });

  @override
  List<Object> get props => [service];
}

class ServiceEventUpdateService extends ServiceEvent {
  final Service service;

  const ServiceEventUpdateService({
    required this.service,
  });

  @override
  List<Object> get props => [service];
}

class ServiceEventActivateService extends ServiceEvent {
  final String id;

  const ServiceEventActivateService({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class ServiceEventDeactivateService extends ServiceEvent {
  final String id;

  const ServiceEventDeactivateService({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class ServiceEventHardDeleteService extends ServiceEvent {
  final String id;

  const ServiceEventHardDeleteService({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class ServiceEventSearchService extends ServiceEvent {
  final String query;

  const ServiceEventSearchService({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}

class ServiceEventSortServices extends ServiceEvent {
  final String sortBy;
  final bool ascending;

  const ServiceEventSortServices({
    required this.sortBy,
    required this.ascending,
  });

  @override
  List<Object> get props => [sortBy, ascending];
}

class ServiceEventCreateDefaultService extends ServiceEvent {
  final Service service;

  const ServiceEventCreateDefaultService({
    required this.service,
  });

  @override
  List<Object> get props => [service];
}

class ServiceEventGetDefaultService extends ServiceEvent {}
