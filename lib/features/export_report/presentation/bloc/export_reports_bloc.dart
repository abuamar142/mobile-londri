import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'export_reports_event.dart';
part 'export_reports_state.dart';

class ExportReportsBloc extends Bloc<ExportReportsEvent, ExportReportsState> {
  ExportReportsBloc() : super(ExportReportsInitial()) {
    on<ExportReportsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
