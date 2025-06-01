import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report.dart';
import '../repositories/export_report_repository.dart';

class ExportReportGetReportData {
  final ExportReportRepository exportReportRepository;

  ExportReportGetReportData({
    required this.exportReportRepository,
  });

  Future<Either<Failure, ExportReport>> call(DateTime startDate, DateTime endDate) async {
    return await exportReportRepository.getReportData(startDate, endDate);
  }
}
