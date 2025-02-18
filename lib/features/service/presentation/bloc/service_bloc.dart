import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/service.dart';
import '../../domain/usecases/service_create_service.dart';
import '../../domain/usecases/service_delete_service.dart';
import '../../domain/usecases/service_get_service_by_id.dart';
import '../../domain/usecases/service_get_services.dart';
import '../../domain/usecases/service_update_service.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final ServiceGetServices serviceGetServices;
  final ServiceGetServiceById serviceGetServiceById;
  final ServiceCreateService serviceCreateService;
  final ServiceUpdateService serviceUpdateService;
  final ServiceDeleteService serviceDeleteService;

  ServiceBloc({
    required this.serviceGetServices,
    required this.serviceGetServiceById,
    required this.serviceCreateService,
    required this.serviceUpdateService,
    required this.serviceDeleteService,
  }) : super(ServiceStateInitial()) {
    on<ServiceEventGetServices>(
      (event, emit) => onServiceEventGetServices(event, emit),
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
  }

  void onServiceEventGetServices(
      ServiceEventGetServices event, Emitter<ServiceState> emit) async {
    emit(ServiceStateLoading());

    Either<Failure, List<Service>> result = await serviceGetServices();

    result.fold((left) {
      emit(ServiceStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ServiceStateSuccessGetServices(
        services: right,
      ));
    });
  }

  void onServiceEventGetServiceById(
      ServiceEventGetServiceById event, Emitter<ServiceState> emit) async {
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
      ServiceEventCreateService event, Emitter<ServiceState> emit) async {
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
      ServiceEventUpdateService event, Emitter<ServiceState> emit) async {
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
      ServiceEventDeleteService event, Emitter<ServiceState> emit) async {
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
}
