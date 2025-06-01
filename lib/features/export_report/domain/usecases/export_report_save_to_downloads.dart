import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/export_report_repository.dart';

class ExportReportSaveToDownloads {
  final ExportReportRepository _repository;

  ExportReportSaveToDownloads(this._repository);

  Future<Either<Failure, String>> call({
    required String filePath,
  }) async {
    return await _repository.saveToDownloads(filePath: filePath);
  }
}
