import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report.dart';

abstract class ExportReportRepository {
  Future<Either<Failure, ExportReport>> getReportData(DateTime startDate, DateTime endDate);
  Future<Either<Failure, String>> exportToPdf(ExportReport reportData, BuildContext context);
  Future<Either<Failure, String>> exportToExcel(ExportReport reportData, BuildContext context);
  Future<Either<Failure, void>> shareFile(String filePath);
  Future<Either<Failure, String>> saveToDownloads(String filePath);
}
