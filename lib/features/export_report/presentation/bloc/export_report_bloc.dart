import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/export_report_data.dart';
import '../../domain/usecases/export_report_save_to_downloads.dart' as save_use_case;
import '../../domain/usecases/export_to_excel.dart';
import '../../domain/usecases/export_to_pdf.dart';
import '../../domain/usecases/get_report_data.dart';
import '../../domain/usecases/share_file.dart';

part 'export_report_event.dart';
part 'export_report_state.dart';

class ExportReportBloc extends Bloc<ExportReportEvent, ExportReportState> {
  final GetReportData _getReportData;
  final ExportToPdf _exportToPdf;
  final ExportToExcel _exportToExcel;
  final ShareFile _shareFile;
  final save_use_case.ExportReportSaveToDownloads _saveToDownloads;

  ExportReportBloc({
    required GetReportData getReportData,
    required ExportToPdf exportToPdf,
    required ExportToExcel exportToExcel,
    required ShareFile shareFile,
    required save_use_case.ExportReportSaveToDownloads saveToDownloads,
  })  : _getReportData = getReportData,
        _exportToPdf = exportToPdf,
        _exportToExcel = exportToExcel,
        _shareFile = shareFile,
        _saveToDownloads = saveToDownloads,
        super(ExportReportInitial()) {
    on<ExportReportGetData>(_onGetData);
    on<ExportReportExportToPdf>(_onExportToPdf);
    on<ExportReportExportToExcel>(_onExportToExcel);
    on<ExportReportShareFile>(_onShareFile);
    on<ExportReportSaveToDownloads>(_onSaveToDownloads);
  }

  void _onGetData(
    ExportReportGetData event,
    Emitter<ExportReportState> emit,
  ) async {
    emit(ExportReportLoading());

    final result = await _getReportData.call(
      GetReportDataParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(ExportReportFailure(message: failure.message)),
      (reportData) => emit(ExportReportDataLoaded(reportData: reportData)),
    );
  }

  void _onExportToPdf(
    ExportReportExportToPdf event,
    Emitter<ExportReportState> emit,
  ) async {
    emit(ExportReportLoading());

    final result = await _exportToPdf.call(
      ExportToPdfParams(
        reportData: event.reportData,
        context: event.context,
      ),
    );

    result.fold(
      (failure) => emit(ExportReportFailure(message: failure.message)),
      (filePath) => emit(ExportReportExportSuccess(
        filePath: filePath,
        format: 'PDF',
      )),
    );
  }

  void _onExportToExcel(
    ExportReportExportToExcel event,
    Emitter<ExportReportState> emit,
  ) async {
    emit(ExportReportLoading());

    final result = await _exportToExcel.call(
      ExportToExcelParams(
        reportData: event.reportData,
        context: event.context,
      ),
    );

    result.fold(
      (failure) => emit(ExportReportFailure(message: failure.message)),
      (filePath) => emit(ExportReportExportSuccess(
        filePath: filePath,
        format: 'Excel',
      )),
    );
  }

  void _onShareFile(
    ExportReportShareFile event,
    Emitter<ExportReportState> emit,
  ) async {
    final result = await _shareFile.call(
      ShareFileParams(filePath: event.filePath),
    );

    result.fold(
      (failure) => emit(ExportReportFailure(message: failure.message)),
      (_) => emit(ExportReportShareSuccess()),
    );
  }

  void _onSaveToDownloads(
    ExportReportSaveToDownloads event,
    Emitter<ExportReportState> emit,
  ) async {
    final result = await _saveToDownloads.call(
      filePath: event.filePath,
    );

    result.fold(
      (failure) => emit(ExportReportFailure(message: failure.message)),
      (savedPath) => emit(ExportReportSaveSuccess(savedPath: savedPath)),
    );
  }
}
