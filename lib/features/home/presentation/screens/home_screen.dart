import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../setting/presentation/screens/setting_screen.dart';
import 'main_screen.dart';
import 'splash_screen.dart';

void pushReplacementHome(BuildContext context) {
  context.pushReplacementNamed('home');
}

void pushHome(BuildContext context) {
  context.pushNamed('home');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions(BuildContext context) => [
        MainScreen(),
        SettingScreen(),
      ];

  void _logout() {
    context.read<AuthBloc>().add(
          AuthEventLogout(),
        );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthStateFailure) {
              showSnackbar(context, state.message.toString());
            } else if (state is AuthStateSuccessLogout) {
              showSnackbar(context, appText.auth_logout_success_message);
              pushReplacementSplash(context);
            }
          },
          builder: (context, state) {
            if (state is AuthStateLoading) {
              return WidgetLoading(usingPadding: true);
            } else {
              return IconButton(
                tooltip: appText.button_logout,
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _logout();
                },
              );
            }
          },
        ),
        title: Text(
          'Home',
          style: AppTextStyle.title,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _widgetOptions(context).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: 'Setting',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
