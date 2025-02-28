import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/l10n/l10n.dart';
import 'config/routes/app_routes.dart';
import 'config/theme/app_themes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/customer/presentation/bloc/customer_bloc.dart';
import 'features/service/presentation/bloc/service_bloc.dart';
import 'features/transaction/presentation/bloc/transaction_bloc.dart';
import 'features/user_role/presentation/bloc/user_role_bloc.dart';
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
          create: (context) => serviceLocator<UserRoleBloc>(),
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
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Londri',
        routerConfig: AppRoutes.routes,
        themeMode: ThemeMode.system,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        supportedLocales: AppLocales.locales,
        locale: Locale('id'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
