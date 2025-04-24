import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'print_event.dart';
part 'print_state.dart';

class PrintBloc extends Bloc<PrintEvent, PrintState> {
  PrintBloc() : super(PrintInitial()) {
    on<PrintEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
