part of 'print_bloc.dart';

abstract class PrintState extends Equatable {
  const PrintState();  

  @override
  List<Object> get props => [];
}
class PrintInitial extends PrintState {}
