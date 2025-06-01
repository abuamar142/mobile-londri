import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report.dart';
import '../repositories/export_report_repository.dart';

class ExportReportExportToExcel {
  final ExportReportRepository exportReportRepository;

  ExportReportExportToExcel({
    required this.exportReportRepository,
  });

  Future<Either<Failure, String>> call(ExportReport reportData, BuildContext context) async {
    return await exportReportRepository.exportToExcel(reportData, context);
  }
}
