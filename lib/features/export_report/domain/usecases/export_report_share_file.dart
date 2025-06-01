import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/export_report_repository.dart';

class ExportReportShareFile {
  final ExportReportRepository exportReportRepository;

  ExportReportShareFile({
    required this.exportReportRepository,
  });

  Future<Either<Failure, void>> call(String filePath) async {
    return await exportReportRepository.shareFile(filePath);
  }
}
