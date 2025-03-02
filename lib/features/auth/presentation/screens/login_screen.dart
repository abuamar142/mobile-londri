import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _login() {
    final email = _emailController.text;
    final password = _passwordController.text;

    context.read<AuthBloc>().add(
          AuthEventLogin(
            email: email,
            password: password,
          ),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateFailure) {
          showSnackbar(context, state.message.toString());
        } else if (state is AuthStateSuccessLogin) {
          showSnackbar(context, 'Login successful');
          context.pushReplacementNamed('home');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Login',
              style: AppTextstyle.title,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    style: AppTextstyle.textField,
                    enabled: state is! AuthStateLoading,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: AppTextstyle.label,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    style: AppTextstyle.textField,
                    enabled: state is! AuthStateLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: AppTextstyle.label,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                  ),
                  const SizedBox(height: 24),
                  WidgetButton(
                    label: 'Login',
                    isLoading: state is AuthStateLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      WidgetTextButton(
                        label: 'Register',
                        isLoading: state is AuthStateLoading,
                        onPressed: () => context.pushNamed('register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
