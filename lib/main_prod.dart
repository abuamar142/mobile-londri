import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../src/generated/i18n/app_localizations.dart';
import 'config/environment/environment_config.dart';
import 'config/environment/environment_loader.dart';
import 'config/i18n/i18n.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_themes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/customer/presentation/bloc/customer_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/manage_staff/presentation/bloc/manage_staff_bloc.dart';
import 'features/printer/presentation/bloc/printer_bloc.dart';
import 'features/service/presentation/bloc/service_bloc.dart';
import 'features/transaction/presentation/bloc/transaction_bloc.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load production environment
  await EnvironmentLoader.loadEnvironment(Environment.production);

  await initializeDependencies();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<AuthBloc>()..add(AuthEventCheckInitialState())),
        BlocProvider(create: (context) => serviceLocator<ManageStaffBloc>()),
        BlocProvider(create: (context) => serviceLocator<ServiceBloc>()),
        BlocProvider(create: (context) => serviceLocator<CustomerBloc>()),
        BlocProvider(create: (context) => serviceLocator<TransactionBloc>()),
        BlocProvider(create: (context) => serviceLocator<PrinterBloc>()),
        BlocProvider(create: (context) => serviceLocator<HomeBloc>()),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLocales.localeNotifier,
        builder: (context, locale, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: EnvironmentConfig.debugMode,
            title: EnvironmentConfig.appDisplayName,
            routerConfig: AppRoutes.routes,
            themeMode: ThemeMode.light,
            theme: AppThemes.lightTheme,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
