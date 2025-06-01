import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report_data.dart';
import '../repositories/export_report_repository.dart';

class ExportToExcel {
  final ExportReportRepository _repository;

  const ExportToExcel(this._repository);

  Future<Either<Failure, String>> call(ExportToExcelParams params) async {
    return await _repository.exportToExcel(
      reportData: params.reportData,
      context: params.context,
    );
  }
}

class ExportToExcelParams {
  final ExportReportData reportData;
  final BuildContext context;

  const ExportToExcelParams({
    required this.reportData,
    required this.context,
  });
}
