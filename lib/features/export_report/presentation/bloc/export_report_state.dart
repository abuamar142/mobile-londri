part of 'export_report_bloc.dart';

sealed class ExportReportState extends Equatable {
  const ExportReportState();

  @override
  List<Object> get props => [];
}

final class ExportReportInitial extends ExportReportState {}

final class ExportReportLoading extends ExportReportState {}

final class ExportReportDataLoaded extends ExportReportState {
  final ExportReportData reportData;

  const ExportReportDataLoaded({required this.reportData});

  @override
  List<Object> get props => [reportData];
}

final class ExportReportExportSuccess extends ExportReportState {
  final String filePath;
  final String format;

  const ExportReportExportSuccess({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object> get props => [filePath, format];
}

final class ExportReportShareSuccess extends ExportReportState {}

final class ExportReportSaveSuccess extends ExportReportState {
  final String savedPath;

  const ExportReportSaveSuccess({required this.savedPath});

  @override
  List<Object> get props => [savedPath];
}

final class ExportReportFailure extends ExportReportState {
  final String message;

  const ExportReportFailure({required this.message});

  @override
  List<Object> get props => [message];
}
