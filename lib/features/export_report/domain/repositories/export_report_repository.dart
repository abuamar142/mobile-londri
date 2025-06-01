import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/export_report_data.dart';

abstract interface class ExportReportRepository {
  Future<Either<Failure, ExportReportData>> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, String>> exportToPdf({
    required ExportReportData reportData,
    required BuildContext context,
  });

  Future<Either<Failure, String>> exportToExcel({
    required ExportReportData reportData,
    required BuildContext context,
  });

  Future<Either<Failure, void>> shareFile({
    required String filePath,
  });

  Future<Either<Failure, String>> saveToDownloads({
    required String filePath,
  });
}
