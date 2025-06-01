part of 'export_report_bloc.dart';

sealed class ExportReportEvent extends Equatable {
  const ExportReportEvent();

  @override
  List<Object> get props => [];
}

class ExportReportGetData extends ExportReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ExportReportGetData({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class ExportReportExportToPdf extends ExportReportEvent {
  final ExportReportData reportData;
  final BuildContext context;

  const ExportReportExportToPdf({
    required this.reportData,
    required this.context,
  });

  @override
  List<Object> get props => [reportData, context];
}

class ExportReportExportToExcel extends ExportReportEvent {
  final ExportReportData reportData;
  final BuildContext context;

  const ExportReportExportToExcel({
    required this.reportData,
    required this.context,
  });

  @override
  List<Object> get props => [reportData, context];
}

class ExportReportShareFile extends ExportReportEvent {
  final String filePath;

  const ExportReportShareFile({
    required this.filePath,
  });

  @override
  List<Object> get props => [filePath];
}

class ExportReportSaveToDownloads extends ExportReportEvent {
  final String filePath;

  const ExportReportSaveToDownloads({
    required this.filePath,
  });

  @override
  List<Object> get props => [filePath];
}
