import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';

Future<String?> pushBarcodeScannerScreen(BuildContext context) async {
  return await context.pushNamed(RouteNames.scanTransaction) as String?;
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with TickerProviderStateMixin {
  late MobileScannerController controller;
  late AnimationController animationController;
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();

    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(
        title: context.appText.track_transaction_scan_barcode_title,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onBarcodeDetected,
          ),
          _buildOverlay(context),
          _buildScanningLine(context),
          _buildInstructions(context),
          _buildControls(context),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cutoutSize = screenWidth * 0.8;
    final cutoutLeft = (screenWidth - cutoutSize) / 2;
    final cutoutTop = (screenHeight - cutoutSize) / 2 - screenHeight * 0.2;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: cutoutTop,
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ), // Bottom overlay
          Positioned(
            top: cutoutTop + cutoutSize,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),
          // Left overlay
          Positioned(
            top: cutoutTop,
            left: 0,
            width: cutoutLeft,
            height: cutoutSize,
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),
          // Right overlay
          Positioned(
            top: cutoutTop,
            right: 0,
            width: cutoutLeft,
            height: cutoutSize,
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),
          // Border frame
          Positioned(
            left: cutoutLeft,
            top: cutoutTop,
            child: Container(
              width: cutoutSize,
              height: cutoutSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.transparent,
                  width: 0,
                ),
                borderRadius: BorderRadius.circular(AppSizes.size12),
              ),
              child: Stack(
                children: [
                  // Top left corner
                  Positioned(
                    left: -2,
                    top: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.success, width: 4),
                          top: BorderSide(color: AppColors.success, width: 4),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppSizes.size12),
                        ),
                      ),
                    ),
                  ),
                  // Top right corner
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.success, width: 4),
                          top: BorderSide(color: AppColors.success, width: 4),
                        ),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(AppSizes.size12),
                        ),
                      ),
                    ),
                  ),
                  // Bottom left corner
                  Positioned(
                    left: -2,
                    bottom: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.success, width: 4),
                          bottom: BorderSide(color: AppColors.success, width: 4),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppSizes.size12),
                        ),
                      ),
                    ),
                  ),
                  // Bottom right corner
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.success, width: 4),
                          bottom: BorderSide(color: AppColors.success, width: 4),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(AppSizes.size12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningLine(BuildContext context) {
    final scanAreaSize = MediaQuery.of(context).size.width * 0.8;
    final scanAreaTop =
        (MediaQuery.of(context).size.height - scanAreaSize) / 2 - MediaQuery.of(context).size.height * 0.2;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Positioned(
          left: (MediaQuery.of(context).size.width - scanAreaSize) / 2,
          top: scanAreaTop + (scanAreaSize * animationController.value),
          child: Container(
            width: scanAreaSize,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.success,
                  AppColors.success,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Positioned(
      bottom: 100.0,
      left: AppSizes.size16,
      right: AppSizes.size16,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.size16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppSizes.size8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: AppSizes.size32,
            ),
            AppSizes.spaceHeight8,
            Text(
              context.appText.track_transaction_scan_instructions_title,
              style: AppTextStyle.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            AppSizes.spaceHeight4,
            Text(
              context.appText.track_transaction_scan_instructions_content,
              style: AppTextStyle.body2.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Positioned(
      bottom: AppSizes.size20,
      left: AppSizes.size16,
      right: AppSizes.size16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: "flash",
            onPressed: () => controller.toggleTorch(),
            backgroundColor: Colors.black.withValues(alpha: 0.7),
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                );
              },
            ),
          ),
          FloatingActionButton(
            heroTag: "switch",
            onPressed: () => controller.switchCamera(),
            backgroundColor: Colors.black.withValues(alpha: 0.7),
            child: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        setState(() {
          isScanned = true;
        }); // Haptic feedback
        HapticFeedback.heavyImpact();
        context.showSnackbar(
          context.appText.track_transaction_scan_success(code),
        );

        // Return result using GoRouter
        Navigator.of(context).pop(code);
      }
    }
  }
}
