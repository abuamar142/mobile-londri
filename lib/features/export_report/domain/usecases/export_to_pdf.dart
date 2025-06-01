import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report_data.dart';
import '../repositories/export_report_repository.dart';

class ExportToPdf {
  final ExportReportRepository _repository;

  const ExportToPdf(this._repository);

  Future<Either<Failure, String>> call(ExportToPdfParams params) async {
    return await _repository.exportToPdf(
      reportData: params.reportData,
      context: params.context,
    );
  }
}

class ExportToPdfParams {
  final ExportReportData reportData;
  final BuildContext context;

  const ExportToPdfParams({
    required this.reportData,
    required this.context,
  });
}
