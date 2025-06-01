import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/export_report_repository.dart';

class ShareFile {
  final ExportReportRepository _repository;

  const ShareFile(this._repository);

  Future<Either<Failure, void>> call(ShareFileParams params) async {
    return await _repository.shareFile(
      filePath: params.filePath,
    );
  }
}

class ShareFileParams {
  final String filePath;

  const ShareFileParams({
    required this.filePath,
  });
}
