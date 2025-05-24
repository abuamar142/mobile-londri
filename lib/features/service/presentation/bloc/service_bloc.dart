import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/service_activate_service.dart';
import '../../domain/usecases/service_create_service.dart';
import '../../domain/usecases/service_delete_service.dart';
import '../../domain/usecases/service_get_active_services.dart';
import '../../domain/usecases/service_get_service_by_id.dart';
import '../../domain/usecases/service_get_services.dart';
import '../../domain/usecases/service_update_service.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceGetServices serviceGetServices;
  final ServiceGetActiveServices serviceGetActiveServices;
  final ServiceGetServiceById serviceGetServiceById;
  final ServiceCreateService serviceCreateService;
  final ServiceUpdateService serviceUpdateService;
  final ServiceDeleteService serviceDeleteService;
  final ServiceActivateService serviceActivateService;

  late List<Service> _allServices;
  String _currentQuery = '';
  String _currentSortField = 'name';
  bool _isAscending = true;

  String get currentSortField => _currentSortField;
  bool get isAscending => _isAscending;

  ServiceBloc({
    required this.serviceGetServices,
    required this.serviceGetActiveServices,
    required this.serviceGetServiceById,
    required this.serviceCreateService,
    required this.serviceUpdateService,
    required this.serviceDeleteService,
    required this.serviceActivateService,
  }) : super(ServiceStateInitial()) {
    on<ServiceEventGetServices>(
      (event, emit) => onServiceEventGetServices(event, emit),
    );
    on<ServiceEventGetActiveServices>(
      (event, emit) => onServiceEventGetActiveServices(event, emit),
    );
    on<ServiceEventGetServiceById>(
      (event, emit) => onServiceEventGetServiceById(event, emit),
    );
    on<ServiceEventCreateService>(
      (event, emit) => onServiceEventCreateService(event, emit),
    );
    on<ServiceEventUpdateService>(
      (event, emit) => onServiceEventUpdateService(event, emit),
    );
    on<ServiceEventDeleteService>(
      (event, emit) => onServiceEventDeleteService(event, emit),
    );
    on<ServiceEventActivateService>(
      (event, emit) => onServiceEventActivateService(event, emit),
    );
    on<ServiceEventSearchService>(
      (event, emit) => onServiceEventSearchService(event, emit),
    );
    on<ServiceEventSortServices>(
      (event, emit) => onServiceEventSortServices(event, emit),
    );
  }

  void onServiceEventGetServices(
    ServiceEventGetServices event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceStateLoading());

    Either<Failure, List<Service>> result = await serviceGetServices();

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      _allServices = right;
      emit(ServiceStateWithFilteredServices(
        allServices: _allServices,
        filteredServices: _sortAndFilter(
          _allServices,
          _currentQuery,
          _currentSortField,
          _isAscending,
        ),
      ));
    });
  }

  void onServiceEventGetActiveServices(
    ServiceEventGetActiveServices event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceStateLoading());

    Either<Failure, List<Service>> result = await serviceGetActiveServices();

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ServiceStateSuccessGetActiveServices(
        activeServices: right,
      ));
    });
  }

  void onServiceEventGetServiceById(
    ServiceEventGetServiceById event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceStateLoading());

    Either<Failure, Service> result = await serviceGetServiceById(event.id);

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ServiceStateSuccessGetServiceById(
        service: right,
      ));
    });
  }

  void onServiceEventCreateService(
    ServiceEventCreateService event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceStateLoading());

    Either<Failure, void> result = await serviceCreateService(event.service);

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ServiceStateSuccessCreateService());
    });
  }

  void onServiceEventUpdateService(
    ServiceEventUpdateService event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceStateLoading());

    Either<Failure, void> result = await serviceUpdateService(event.service);

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ServiceStateSuccessUpdateService());
    });
  }

  void onServiceEventDeleteService(
    ServiceEventDeleteService event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceStateLoading());

    Either<Failure, void> result = await serviceDeleteService(event.id);

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ServiceStateSuccessDeleteService());
    });
  }

  void onServiceEventActivateService(
    ServiceEventActivateService event,
    Emitter<ServiceState> emit,
  ) async {
    emit(ServiceStateLoading());

    Either<Failure, void> result = await serviceActivateService(event.id);

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ServiceStateSuccessActivateService());
      add(ServiceEventGetServices());
    });
  }

  void onServiceEventSearchService(
    ServiceEventSearchService event,
    Emitter<ServiceState> emit,
  ) {
    _currentQuery = event.query;
    final filtered = _sortAndFilter(
      _allServices,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );

    emit(ServiceStateWithFilteredServices(
      allServices: _allServices,
      filteredServices: filtered,
    ));
  }

  void onServiceEventSortServices(
    ServiceEventSortServices event,
    Emitter<ServiceState> emit,
  ) {
    _currentSortField = event.sortBy;
    _isAscending = event.ascending;

    final filtered = _sortAndFilter(
      _allServices,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );

    emit(ServiceStateWithFilteredServices(
      allServices: _allServices,
      filteredServices: filtered,
    ));
  }

  List<Service> _sortAndFilter(
    List<Service> services,
    String query,
    String sortField,
    bool ascending,
  ) {
    final lowerQuery = query.toLowerCase();
    List<Service> filtered = services
        .where((service) => (service.name?.toLowerCase().contains(lowerQuery) ?? false) || (service.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();

    filtered.sort((a, b) {
      int result;

      switch (sortField) {
        case 'name':
          result = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'price':
          result = (a.price ?? 0).compareTo(b.price ?? 0);
          break;
        case 'createdAt':
          result = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
          break;
        default:
          result = (a.name ?? '').compareTo(b.name ?? '');
      }

      return ascending ? result : -result;
    });

    return filtered;
  }
}
