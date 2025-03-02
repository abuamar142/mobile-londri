import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordAgainVisible = false;

  void _register() {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final passwordAgain = _passwordAgainController.text;

    context.read<AuthBloc>().add(
          AuthEventRegister(
            name: name,
            email: email,
            password: password,
            passwordAgain: passwordAgain,
          ),
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateFailure) {
          showSnackbar(context, state.message.toString());
        } else if (state is AuthStateSuccessRegister) {
          showSnackbar(context, 'Registration successful');
          context.pushReplacementNamed('login');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Register',
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
                    controller: _nameController,
                    style: AppTextstyle.textField,
                    enabled: state is! AuthStateLoading,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    style: AppTextstyle.textField,
                    enabled: state is! AuthStateLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    style: AppTextstyle.textField,
                    enabled: state is! AuthStateLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                  TextField(
                    controller: _passwordAgainController,
                    style: AppTextstyle.textField,
                    enabled: state is! AuthStateLoading,
                    decoration: InputDecoration(
                      labelText: 'Password Again',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordAgainVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordAgainVisible = !_isPasswordAgainVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordAgainVisible,
                  ),
                  const SizedBox(height: 24),
                  WidgetButton(
                    label: 'Register',
                    isLoading: state is AuthStateLoading,
                    onPressed: _register,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      WidgetTextButton(
                        label: 'Login',
                        isLoading: state is AuthStateLoading,
                        onPressed: () => context.pop(),
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
