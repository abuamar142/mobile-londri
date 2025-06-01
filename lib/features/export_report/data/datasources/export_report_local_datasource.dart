import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transaction/domain/entities/payment_status.dart';
import '../../../transaction/domain/entities/transaction_status.dart';
import '../../domain/entities/export_report.dart';

abstract interface class ExportReportLocalDatasource {
  Future<String> exportToPdf(ExportReport reportData, BuildContext context);
  Future<String> exportToExcel(ExportReport reportData, BuildContext context);
  Future<void> shareFile(String filePath);
  Future<String> saveToDownloads(String filePath);
}

class ExportReportLocalDatasourceImplementation implements ExportReportLocalDatasource {
  @override
  Future<String> exportToPdf(ExportReport reportData, BuildContext context) async {
    final appText = context.appText;

    try {
      final pdf = pw.Document();

      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  appText.export_report_document_title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Report Info
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      appText.export_report_info_section_title,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('${appText.export_report_info_period_label}: ${reportData.period.toUpperCase()}'),
                    pw.Text('${appText.export_report_info_date_label}: ${reportData.startDate.formatDateOnly()} - ${reportData.endDate.formatDateOnly()}'),
                    pw.Text('${appText.export_report_info_total_transactions_label}: ${reportData.totalTransactions}'),
                    pw.Text('${appText.export_report_info_total_revenue_label}: Rp ${_formatCurrency(reportData.totalRevenue)}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Statistics
              pw.Text(
                appText.export_report_statistics_section_title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(appText.export_report_table_header_status, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(appText.export_report_table_header_count, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(getTransactionStatusValue(context, TransactionStatus.onProgress)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${reportData.onProgressCount}'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(getTransactionStatusValue(context, TransactionStatus.readyForPickup)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${reportData.readyForPickupCount}'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(getTransactionStatusValue(context, TransactionStatus.pickedUp)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${reportData.pickedUpCount}'),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Transactions Table
              pw.Text(
                appText.export_report_details_section_title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(appText.export_report_table_header_id, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(appText.export_report_table_header_customer, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(appText.export_report_table_header_service, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(appText.export_report_table_header_weight, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(appText.export_report_table_header_total, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...reportData.transactions.map((transaction) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(transaction.id ?? 'N/A'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(transaction.customerName ?? 'N/A'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(transaction.serviceName ?? 'N/A'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${transaction.weight ?? 0.0}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Rp ${_formatCurrency((transaction.amount ?? 0).toDouble())}'),
                          ),
                        ],
                      )),
                ],
              ),
            ];
          },
        ),
      );

      // Save PDF to file
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/Londri_${DateTime.now().formatddMMyyyy()}.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> exportToExcel(ExportReport reportData, BuildContext context) async {
    final appText = context.appText;

    try {
      final excel = Excel.createExcel();
      final sheet = excel[appText.export_report_excel_sheet_name];

      // Header
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(appText.export_report_document_title);
      sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));

      // Report Info
      sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(appText.export_report_info_section_title);
      sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('${appText.export_report_info_period_label}: ${reportData.period.toUpperCase()}');
      sheet.cell(CellIndex.indexByString('A5')).value =
          TextCellValue('${appText.export_report_info_date_label}: ${reportData.startDate.formatDateOnly()} - ${reportData.endDate.formatDateOnly()}');
      sheet.cell(CellIndex.indexByString('A6')).value =
          TextCellValue('${appText.export_report_info_total_transactions_label}: ${reportData.totalTransactions}');
      sheet.cell(CellIndex.indexByString('A7')).value =
          TextCellValue('${appText.export_report_info_total_revenue_label}: Rp ${_formatCurrency(reportData.totalRevenue)}');

      // Statistics Header
      sheet.cell(CellIndex.indexByString('A9')).value = TextCellValue(appText.export_report_statistics_section_title);
      sheet.cell(CellIndex.indexByString('A10')).value = TextCellValue(appText.export_report_table_header_status);
      sheet.cell(CellIndex.indexByString('B10')).value = TextCellValue(appText.export_report_table_header_count);

      // Statistics Data
      sheet.cell(CellIndex.indexByString('A11')).value = TextCellValue(getTransactionStatusValue(context, TransactionStatus.onProgress));
      sheet.cell(CellIndex.indexByString('B11')).value = IntCellValue(reportData.onProgressCount);
      sheet.cell(CellIndex.indexByString('A12')).value = TextCellValue(getTransactionStatusValue(context, TransactionStatus.readyForPickup));
      sheet.cell(CellIndex.indexByString('B12')).value = IntCellValue(reportData.readyForPickupCount);
      sheet.cell(CellIndex.indexByString('A13')).value = TextCellValue(getTransactionStatusValue(context, TransactionStatus.pickedUp));
      sheet.cell(CellIndex.indexByString('B13')).value = IntCellValue(reportData.pickedUpCount);

      // Transaction Table Header
      int startRow = 15;
      sheet.cell(CellIndex.indexByString('A${startRow - 1}')).value = TextCellValue(appText.export_report_details_section_title);
      sheet.cell(CellIndex.indexByString('A$startRow')).value = TextCellValue(appText.export_report_table_header_id);
      sheet.cell(CellIndex.indexByString('B$startRow')).value = TextCellValue(appText.export_report_table_header_customer);
      sheet.cell(CellIndex.indexByString('C$startRow')).value = TextCellValue(appText.export_report_table_header_service);
      sheet.cell(CellIndex.indexByString('D$startRow')).value = TextCellValue(appText.export_report_table_header_weight);
      sheet.cell(CellIndex.indexByString('E$startRow')).value = TextCellValue(appText.export_report_table_header_total);
      sheet.cell(CellIndex.indexByString('F$startRow')).value = TextCellValue(appText.export_report_table_header_transaction_status);
      sheet.cell(CellIndex.indexByString('G$startRow')).value = TextCellValue(appText.export_report_table_header_payment_status);
      sheet.cell(CellIndex.indexByString('H$startRow')).value = TextCellValue(appText.export_report_table_header_created_date);

      // Transaction Data
      for (int i = 0; i < reportData.transactions.length; i++) {
        final transaction = reportData.transactions[i];
        final row = startRow + 1 + i;

        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(transaction.id ?? 'N/A');
        sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(transaction.customerName ?? 'N/A');
        sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(transaction.serviceName ?? 'N/A');
        sheet.cell(CellIndex.indexByString('D$row')).value = DoubleCellValue(transaction.weight ?? 0);
        sheet.cell(CellIndex.indexByString('E$row')).value = IntCellValue(transaction.amount ?? 0);
        sheet.cell(CellIndex.indexByString('F$row')).value =
            TextCellValue(getTransactionStatusValue(context, transaction.transactionStatus ?? TransactionStatus.other));
        sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(getPaymentStatusValue(context, transaction.paymentStatus ?? PaymentStatus.other));
        sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue((transaction.createdAt ?? DateTime.now()).formatDateOnly());
      }

      // Save Excel to file
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/Londri_${DateTime.now().formatddMMyyyy()}.xlsx');

      final List<int>? bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
      }

      return file.path;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        );
  }

  @override
  Future<String> saveToDownloads(String filePath) async {
    try {
      Directory? downloadsDirectory;

      if (Platform.isAndroid) {
        // For Android, try to get the Downloads directory
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          // Fallback to external storage
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else {
        // For iOS and other platforms, use documents directory
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory == null) {
        throw Exception('Could not access Downloads directory');
      }

      final file = File(filePath);
      final fileName = file.path.split('/').last;
      final newPath = '${downloadsDirectory.path}/$fileName';

      // Copy file to Downloads directory
      await file.copy(newPath);

      return newPath;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
