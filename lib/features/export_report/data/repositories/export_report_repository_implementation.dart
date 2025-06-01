import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/export_report.dart';
import '../../domain/repositories/export_report_repository.dart';
import '../datasources/export_report_local_datasource.dart';
import '../datasources/export_report_remote_datasource.dart';

class ExportReportRepositoryImplementation extends ExportReportRepository {
  final ExportReportRemoteDatasource exportReportRemoteDatasource;
  final ExportReportLocalDatasource exportReportLocalDatasource;

  ExportReportRepositoryImplementation({
    required this.exportReportRemoteDatasource,
    required this.exportReportLocalDatasource,
  });

  @override
  Future<Either<Failure, ExportReport>> getReportData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final reportData = await exportReportRemoteDatasource.getReportData(startDate, endDate);
      return Right(reportData);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportToPdf(ExportReport reportData, BuildContext context) async {
    try {
      final filePath = await exportReportLocalDatasource.exportToPdf(reportData, context);
      return Right(filePath);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportToExcel(ExportReport reportData, BuildContext context) async {
    try {
      final filePath = await exportReportLocalDatasource.exportToExcel(reportData, context);
      return Right(filePath);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> shareFile(String filePath) async {
    try {
      await exportReportLocalDatasource.shareFile(filePath);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveToDownloads(String filePath) async {
    try {
      final savedPath = await exportReportLocalDatasource.saveToDownloads(filePath);
      return Right(savedPath);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
