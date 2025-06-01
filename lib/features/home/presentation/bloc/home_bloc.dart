import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/statistic.dart';
import '../../domain/usecases/home_get_today_statistics.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeGetTodayStatistics homeGetTodayStatistics;

  HomeBloc({
    required this.homeGetTodayStatistics,
  }) : super(HomeStateInitial()) {
    on<HomeEventGetTodayStatistics>(_onHomeEventGetTodayStatistics);
  }

  Future<void> _onHomeEventGetTodayStatistics(
    HomeEventGetTodayStatistics event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeStateLoading());

    Either<Failure, Statistic> result = await homeGetTodayStatistics();

    result.fold(
      (left) => emit(HomeStateFailure(message: left.message)),
      (right) => emit(HomeStateSuccessLoadedData(statistic: right)),
    );
  }
}
