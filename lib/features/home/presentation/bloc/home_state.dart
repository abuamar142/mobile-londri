part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeStateInitial extends HomeState {}

class HomeStateLoading extends HomeState {}

class HomeStateSuccessLoadedData extends HomeState {
  final Statistic statistic;

  const HomeStateSuccessLoadedData({
    required this.statistic,
  });

  @override
  List<Object> get props => [statistic];
}

class HomeStateFailure extends HomeState {
  final String message;

  const HomeStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
