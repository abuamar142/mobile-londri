part of 'export_report_bloc.dart';

sealed class ExportReportState extends Equatable {
  const ExportReportState();

  @override
  List<Object> get props => [];
}

final class ExportReportStateInitial extends ExportReportState {}

final class ExportReportStateLoading extends ExportReportState {}

final class ExportReportStateSuccessLoadedData extends ExportReportState {
  final ExportReport reportData;

  const ExportReportStateSuccessLoadedData({
    required this.reportData,
  });

  @override
  List<Object> get props => [reportData];
}

final class ExportReportStateSuccessExport extends ExportReportState {
  final String filePath;
  final String format;

  const ExportReportStateSuccessExport({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object> get props => [filePath, format];
}

final class ExportReportStateSuccessShare extends ExportReportState {}

final class ExportReportStateSuccessSave extends ExportReportState {
  final String savedPath;

  const ExportReportStateSuccessSave({
    required this.savedPath,
  });

  @override
  List<Object> get props => [savedPath];
}

final class ExportReportStateFailure extends ExportReportState {
  final String message;

  const ExportReportStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
