part of 'export_report_bloc.dart';

sealed class ExportReportEvent extends Equatable {
  const ExportReportEvent();

  @override
  List<Object> get props => [];
}

class ExportReportEventGetData extends ExportReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ExportReportEventGetData({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [startDate, endDate];
}

class ExportReportEventExportToPdf extends ExportReportEvent {
  final ExportReport reportData;
  final BuildContext context;

  const ExportReportEventExportToPdf({
    required this.reportData,
    required this.context,
  });

  @override
  List<Object> get props => [reportData, context];
}

class ExportReportEventExportToExcel extends ExportReportEvent {
  final ExportReport reportData;
  final BuildContext context;

  const ExportReportEventExportToExcel({
    required this.reportData,
    required this.context,
  });

  @override
  List<Object> get props => [reportData, context];
}

class ExportReportEventShareFile extends ExportReportEvent {
  final String filePath;

  const ExportReportEventShareFile({
    required this.filePath,
  });

  @override
  List<Object> get props => [filePath];
}

class ExportReportEventSaveToDownloads extends ExportReportEvent {
  final String filePath;

  const ExportReportEventSaveToDownloads({
    required this.filePath,
  });

  @override
  List<Object> get props => [filePath];
}
