import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/export_report.dart';
import '../../domain/usecases/export_report_export_to_excel.dart';
import '../../domain/usecases/export_report_export_to_pdf.dart';
import '../../domain/usecases/export_report_get_report_data.dart';
import '../../domain/usecases/export_report_save_to_downloads.dart';
import '../../domain/usecases/export_report_share_file.dart';

part 'export_report_event.dart';
part 'export_report_state.dart';

class ExportReportBloc extends Bloc<ExportReportEvent, ExportReportState> {
  final ExportReportGetReportData exportReportGetReportData;
  final ExportReportExportToPdf exportReportExportToPdf;
  final ExportReportExportToExcel exportReportExportToExcel;
  final ExportReportSaveToDownloads exportReportSaveToDownloads;
  final ExportReportShareFile exportReportShareFile;

  ExportReportBloc({
    required this.exportReportGetReportData,
    required this.exportReportExportToPdf,
    required this.exportReportExportToExcel,
    required this.exportReportSaveToDownloads,
    required this.exportReportShareFile,
  }) : super(ExportReportStateInitial()) {
    on<ExportReportEventGetData>(_onTransactionEventGetData);
    on<ExportReportEventExportToPdf>(_onTransactionEventExportToPdf);
    on<ExportReportEventExportToExcel>(_onTransactionEventExportToExcel);
    on<ExportReportEventShareFile>(_onTransactionEventShareFile);
    on<ExportReportEventSaveToDownloads>(_onTransactionEventSaveToDownloads);
  }

  void _onTransactionEventGetData(
    ExportReportEventGetData event,
    Emitter<ExportReportState> emit,
  ) async {
    emit(ExportReportStateLoading());

    final result = await exportReportGetReportData.call(event.startDate, event.endDate);

    result.fold(
      (left) => emit(ExportReportStateFailure(message: left.message)),
      (right) => emit(ExportReportStateSuccessLoadedData(reportData: right)),
    );
  }

  void _onTransactionEventExportToPdf(
    ExportReportEventExportToPdf event,
    Emitter<ExportReportState> emit,
  ) async {
    emit(ExportReportStateLoading());

    final result = await exportReportExportToPdf.call(event.reportData, event.context);

    result.fold(
      (left) => emit(ExportReportStateFailure(message: left.message)),
      (right) => emit(ExportReportStateSuccessExport(filePath: right, format: 'PDF')),
    );
  }

  void _onTransactionEventExportToExcel(
    ExportReportEventExportToExcel event,
    Emitter<ExportReportState> emit,
  ) async {
    emit(ExportReportStateLoading());

    final result = await exportReportExportToExcel.call(event.reportData, event.context);

    result.fold(
      (left) => emit(ExportReportStateFailure(message: left.message)),
      (right) => emit(ExportReportStateSuccessExport(filePath: right, format: 'Excel')),
    );
  }

  void _onTransactionEventShareFile(
    ExportReportEventShareFile event,
    Emitter<ExportReportState> emit,
  ) async {
    final result = await exportReportShareFile.call(event.filePath);

    result.fold(
      (left) => emit(ExportReportStateFailure(message: left.message)),
      (_) => emit(ExportReportStateSuccessShare()),
    );
  }

  void _onTransactionEventSaveToDownloads(
    ExportReportEventSaveToDownloads event,
    Emitter<ExportReportState> emit,
  ) async {
    final result = await exportReportSaveToDownloads.call(event.filePath);

    result.fold(
      (left) => emit(ExportReportStateFailure(message: left.message)),
      (right) => emit(ExportReportStateSuccessSave(savedPath: right)),
    );
  }
}
