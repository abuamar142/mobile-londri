import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/email_validation.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../bloc/auth_bloc.dart';
import 'register_screen.dart';

void pushReplacementLogin({
  required BuildContext context,
}) {
  context.pushReplacementNamed(RouteNames.login);
}

void pushLogin({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.login);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthBloc _authBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    _authBloc = serviceLocator<AuthBloc>();
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
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthStateFailure) {
          if (state.message == 'invalid_credentials') {
            context.showSnackbar(context.appText.auth_login_error_message);
          } else if (state.message == 'email_not_confirmed') {
            context.showSnackbar(context.appText.auth_login_error_email_not_confirmed);
          } else {
            context.showSnackbar(state.message.toString());
          }
        } else if (state is AuthStateSuccessLogin) {
          context.showSnackbar(context.appText.auth_login_success_message);
          pushReplacementHome(context: context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: WidgetAppBar(label: context.appText.auth_login_screen_title),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.size16),
              child: Column(
                children: [
                  Text(
                    context.appText.auth_login_screen_text_title,
                    style: AppTextStyle.heading1.copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight12,
                  Text(
                    context.appText.auth_login_screen_text_subtitle,
                    style: AppTextStyle.body2,
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight24,
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        WidgetTextFormField(
                          controller: _emailController,
                          label: context.appText.form_email_label,
                          hint: context.appText.form_email_hint,
                          keyboardType: TextInputType.emailAddress,
                          isLoading: state is AuthStateLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.appText.form_email_required_message;
                            } else if (!value.isValidEmail()) {
                              return context.appText.form_email_invalid_message;
                            } else {
                              return null;
                            }
                          },
                        ),
                        AppSizes.spaceHeight12,
                        WidgetTextFormField(
                          controller: _passwordController,
                          label: context.appText.form_password_label,
                          hint: context.appText.form_password_hint,
                          keyboardType: TextInputType.visiblePassword,
                          isLoading: state is AuthStateLoading,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: _togglePasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return context.appText.form_password_required_message;
                            }
                            if (value.length < 8) {
                              return context.appText.form_password_min_length_message;
                            }
                            return null;
                          },
                        ),
                        AppSizes.spaceHeight24,
                        WidgetButton(
                          label: context.appText.button_login,
                          isLoading: state is AuthStateLoading,
                          onPressed: _onLogin,
                        ),
                        AppSizes.spaceHeight12,
                      ],
                    ),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: context.appText.auth_login_screen_rich_text_text,
                      style: AppTextStyle.caption.copyWith(color: AppColors.onSecondary),
                      children: [
                        TextSpan(
                          text: context.appText.auth_login_screen_rich_text_button,
                          style: AppTextStyle.caption.copyWith(color: AppColors.primary),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              pushRegister(context: context);
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      _authBloc.add(AuthEventLogin(
        email: email,
        password: password,
      ));
    }
  }
}
