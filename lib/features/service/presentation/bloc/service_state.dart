part of 'service_bloc.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();  

  @override
  List<Object> get props => [];
}
class ServiceInitial extends ServiceState {}
