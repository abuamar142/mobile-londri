import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report.dart';
import '../repositories/export_report_repository.dart';

class ExportReportExportToPdf {
  final ExportReportRepository exportReportRepository;

  ExportReportExportToPdf({
    required this.exportReportRepository,
  });

  Future<Either<Failure, String>> call(ExportReport reportData, BuildContext context) async {
    return await exportReportRepository.exportToPdf(reportData, context);
  }
}
