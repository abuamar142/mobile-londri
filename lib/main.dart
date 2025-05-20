import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../../src/generated/i18n/app_localizations.dart';
import 'config/i18n/i18n.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_themes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/customer/presentation/bloc/customer_bloc.dart';
import 'features/manage_employee/presentation/bloc/manage_employee_bloc.dart';
import 'features/service/presentation/bloc/service_bloc.dart';
import 'features/transaction/presentation/bloc/transaction_bloc.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<ManageEmployeeBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<ServiceBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<CustomerBloc>(),
        ),
        BlocProvider(
          create: (context) => serviceLocator<TransactionBloc>(),
        ),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLocales.localeNotifier,
        builder: (context, locale, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Londri',
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
