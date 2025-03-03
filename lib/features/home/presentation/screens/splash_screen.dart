import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/assets/app_assets.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../src/generated/i18n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Future.delayed(
          const Duration(seconds: 2),
          () {
            if (mounted) {
              context.pushReplacementNamed('login');
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(AppAssets.appImage),
                  radius: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  'Londri',
                  style: AppTextstyle.title,
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)!.splash_screen_text,
                  textAlign: TextAlign.center,
                  style: AppTextstyle.subtitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
