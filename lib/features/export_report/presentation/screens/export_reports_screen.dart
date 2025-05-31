import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../customer/presentation/widgets/widget_dropdown.dart';

void pushExportReports({required BuildContext context}) {
  context.pushNamed(RouteNames.exportReports);
}

enum ExportPeriod { daily, weekly, monthly }

enum ExportFormat { pdf, excel }

extension ExportPeriodExtension on ExportPeriod {
  String getName(BuildContext context) {
    switch (this) {
      case ExportPeriod.daily:
        return 'Harian';
      case ExportPeriod.weekly:
        return 'Mingguan';
      case ExportPeriod.monthly:
        return 'Bulanan';
    }
  }

  IconData get icon {
    switch (this) {
      case ExportPeriod.daily:
        return Icons.today;
      case ExportPeriod.weekly:
        return Icons.date_range;
      case ExportPeriod.monthly:
        return Icons.calendar_month;
    }
  }
}

extension ExportFormatExtension on ExportFormat {
  String getName(BuildContext context) {
    switch (this) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.excel:
        return 'Excel (XLSX)';
    }
  }

  IconData get icon {
    switch (this) {
      case ExportFormat.pdf:
        return Icons.picture_as_pdf;
      case ExportFormat.excel:
        return Icons.table_chart;
    }
  }

  Color get color {
    switch (this) {
      case ExportFormat.pdf:
        return Colors.red;
      case ExportFormat.excel:
        return Colors.green;
    }
  }
}

class ExportReportsScreen extends StatefulWidget {
  const ExportReportsScreen({super.key});

  @override
  State<ExportReportsScreen> createState() => _ExportReportsScreenState();
}

class _ExportReportsScreenState extends State<ExportReportsScreen> {
  ExportPeriod _selectedPeriod = ExportPeriod.daily;
  ExportFormat _selectedFormat = ExportFormat.pdf;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(
        title: 'Ekspor Laporan',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.size16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              AppSizes.spaceHeight24,
              _buildPeriodSelection(),
              AppSizes.spaceHeight24,
              _buildDateRangeSection(),
              AppSizes.spaceHeight24,
              _buildFormatSelection(),
              AppSizes.spaceHeight24,
              _buildReportPreview(),
              AppSizes.spaceHeight32,
              _buildExportButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ekspor Laporan Transaksi',
          style: AppTextStyle.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        AppSizes.spaceHeight8,
        Text(
          'Pilih periode dan format untuk mengekspor laporan transaksi laundry',
          style: AppTextStyle.body1.copyWith(
            color: AppColors.gray,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Periode Laporan',
          style: AppTextStyle.heading3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSizes.spaceHeight12,
        WidgetDropdown(
          icon: _selectedPeriod.icon,
          label: _selectedPeriod.getName(context),
          isEnable: !_isLoading,
          showModalBottomSheet: () => _showPeriodOptions(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rentang Tanggal',
          style: AppTextStyle.heading3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSizes.spaceHeight12,
        Row(
          children: [
            Expanded(
              child: WidgetTextFormField(
                label: 'Tanggal Mulai',
                hint: 'Pilih tanggal mulai',
                controller: _startDateController,
                isEnabled: !_isLoading,
                readOnly: true,
                suffixIcon: !_isLoading
                    ? IconButton(
                        onPressed: () => _selectStartDate(context),
                        icon: Icon(Icons.calendar_today),
                      )
                    : null,
              ),
            ),
            AppSizes.spaceWidth12,
            Expanded(
              child: WidgetTextFormField(
                label: 'Tanggal Akhir',
                hint: 'Pilih tanggal akhir',
                controller: _endDateController,
                isEnabled: !_isLoading,
                readOnly: true,
                suffixIcon: !_isLoading
                    ? IconButton(
                        onPressed: () => _selectEndDate(context),
                        icon: Icon(Icons.calendar_today),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Format File',
          style: AppTextStyle.heading3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSizes.spaceHeight12,
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(ExportFormat.pdf),
            ),
            AppSizes.spaceWidth12,
            Expanded(
              child: _buildFormatCard(ExportFormat.excel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatCard(ExportFormat format) {
    final isSelected = _selectedFormat == format;

    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _selectedFormat = format;
              });
            },
      child: Container(
        padding: EdgeInsets.all(AppSizes.size16),
        decoration: BoxDecoration(
          color: isSelected ? format.color.withValues(alpha: 0.1) : AppColors.onPrimary,
          borderRadius: BorderRadius.circular(AppSizes.size12),
          border: Border.all(
            color: isSelected ? format.color : AppColors.gray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              format.icon,
              size: AppSizes.size32,
              color: isSelected ? format.color : AppColors.gray,
            ),
            AppSizes.spaceHeight8,
            Text(
              format.getName(context),
              style: AppTextStyle.body1.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? format.color : AppColors.onSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    return Container(
      padding: EdgeInsets.all(AppSizes.size16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.size12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: AppColors.primary,
                size: AppSizes.size20,
              ),
              AppSizes.spaceWidth8,
              Text(
                'Preview Laporan',
                style: AppTextStyle.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          AppSizes.spaceHeight12,
          _buildPreviewItem('Periode', _selectedPeriod.getName(context)),
          _buildPreviewItem('Tanggal', '${_startDateController.text} - ${_endDateController.text}'),
          _buildPreviewItem('Format', _selectedFormat.getName(context)),
          _buildPreviewItem('Estimasi Data', 'akan dihitung saat export'), // TODO: Replace with actual data count
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.size8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyle.body2.copyWith(
                color: AppColors.gray,
              ),
            ),
          ),
          Text(
            ': ',
            style: AppTextStyle.body2.copyWith(
              color: AppColors.gray,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return WidgetButton(
      label: 'Ekspor Laporan',
      isLoading: _isLoading,
      onPressed: _exportReport,
    );
  }

  void _showPeriodOptions() {
    showDropdownBottomSheet(
      context: context,
      title: 'Pilih Periode',
      items: ExportPeriod.values
          .map(
            (period) => WidgetDropdownBottomSheetItem(
              isSelected: _selectedPeriod == period,
              leadingIcon: period.icon,
              title: period.getName(context),
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                  _updateDateRangeBasedOnPeriod();
                });
              },
            ),
          )
          .toList(),
    );
  }

  void _updateDateRangeBasedOnPeriod() {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case ExportPeriod.daily:
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = _startDate;
        break;
      case ExportPeriod.weekly:
        final weekday = now.weekday;
        _startDate = now.subtract(Duration(days: weekday - 1));
        _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
        _endDate = _startDate.add(Duration(days: 6));
        break;
      case ExportPeriod.monthly:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
    }

    _updateDateControllers();
  }

  void _updateDateControllers() {
    _startDateController.text = _formatDate(_startDate);
    _endDateController.text = _formatDate(_endDate);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
        _updateDateControllers();
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _updateDateControllers();
      });
    }
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate;
    _updateDateControllers();
  }

  void _exportReport() {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement export logic here
    // This will be connected to Supabase later

    // Simulate loading
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        context.showSnackbar('Laporan ${_selectedFormat.getName(context)} berhasil diekspor!');
      }
    });
  }
}
