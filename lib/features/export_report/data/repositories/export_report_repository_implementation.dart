import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/export_report_data.dart';
import '../../domain/repositories/export_report_repository.dart';
import '../datasources/export_report_local_datasource.dart';
import '../datasources/export_report_remote_datasource.dart';

class ExportReportRepositoryImplementation implements ExportReportRepository {
  final ExportReportRemoteDatasource _remoteDatasource;
  final ExportReportLocalDatasource _localDatasource;

  const ExportReportRepositoryImplementation(
    this._remoteDatasource,
    this._localDatasource,
  );

  @override
  Future<Either<Failure, ExportReportData>> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final reportData = await _remoteDatasource.getReportData(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(reportData);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportToPdf({
    required ExportReportData reportData,
    required BuildContext context,
  }) async {
    try {
      final filePath = await _localDatasource.exportToPdf(
        reportData: reportData,
        context: context,
      );
      return Right(filePath);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportToExcel({
    required ExportReportData reportData,
    required BuildContext context,
  }) async {
    try {
      final filePath = await _localDatasource.exportToExcel(
        reportData: reportData,
        context: context,
      );
      return Right(filePath);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> shareFile({
    required String filePath,
  }) async {
    try {
      await _localDatasource.shareFile(filePath: filePath);
      return const Right(null);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveToDownloads({
    required String filePath,
  }) async {
    try {
      final savedPath = await _localDatasource.saveToDownloads(filePath: filePath);
      return Right(savedPath);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
