import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../setting/presentation/screens/setting_screen.dart';
import 'dashboard_screen.dart';
import 'splash_screen.dart';

void pushReplacementHome({
  required BuildContext context,
}) {
  context.pushReplacementNamed(RouteNames.home);
}

void pushHome({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.home);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthBloc _authBloc;

  int _selectedIndex = 0;

  List<Widget> _widgetOptions() => [
        DashboardScreen(),
        SettingScreen(),
      ];

  @override
  void initState() {
    super.initState();

    _authBloc = context.read<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetAppBar(
        leading: BlocConsumer<AuthBloc, AuthState>(
          bloc: _authBloc,
          listener: (context, state) {
            if (state is AuthStateFailure) {
              context.showSnackbar(state.message.toString());
            } else if (state is AuthStateSuccessLogout) {
              context.showSnackbar(context.appText.auth_logout_success_message);
              pushReplacementSplash(context: context);
            }
          },
          builder: (context, state) {
            if (state is AuthStateLoading) {
              return WidgetLoading(usingPadding: true);
            } else {
              return IconButton(
                tooltip: context.appText.button_logout,
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(),
              );
            }
          },
        ),
        title: context.appText.home_screen_title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _widgetOptions().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: context.appText.home_screen_title,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: context.appText.setting_screen_title,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        onTap: _onItemTapped,
      ),
    );
  }

  void _logout() => _authBloc.add(AuthEventLogout());

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
