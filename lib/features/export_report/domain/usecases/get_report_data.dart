import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report_data.dart';
import '../repositories/export_report_repository.dart';

class GetReportData {
  final ExportReportRepository _repository;

  const GetReportData(this._repository);

  Future<Either<Failure, ExportReportData>> call(GetReportDataParams params) async {
    return await _repository.getReportData(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetReportDataParams {
  final DateTime startDate;
  final DateTime endDate;

  const GetReportDataParams({
    required this.startDate,
    required this.endDate,
  });
}
