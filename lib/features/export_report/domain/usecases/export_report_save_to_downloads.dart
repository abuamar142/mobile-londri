import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/export_report_repository.dart';

class ExportReportSaveToDownloads {
  final ExportReportRepository exportReportRepository;

  ExportReportSaveToDownloads({
    required this.exportReportRepository,
  });

  Future<Either<Failure, String>> call(String filePath) async {
    return await exportReportRepository.saveToDownloads(filePath);
  }
}
