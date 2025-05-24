import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/assets/app_assets.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../auth/presentation/screens/login_screen.dart';

void pushReplacementSplash({
  required BuildContext context,
}) {
  context.pushReplacementNamed(RouteNames.splash);
}

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
              pushReplacementLogin(context: context);
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: AppSizes.paddingAll16,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          AppAssets.appImage,
                        ),
                        radius: 120,
                      ),
                      AppSizes.spaceHeight24,
                      Text(
                        context.appText.app_name,
                        style: AppTextStyle.heading1,
                        textAlign: TextAlign.center,
                      ),
                      AppSizes.spaceHeight12,
                      Text(
                        context.appText.splash_screen_text,
                        style: AppTextStyle.body1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
