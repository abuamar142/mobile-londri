import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../bloc/auth_bloc.dart';
import 'register_screen.dart';

void pushReplacementLogin(BuildContext context) {
  context.pushReplacementNamed('login');
}

void pushLogin(BuildContext context) {
  context.pushNamed('login');
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void onLogin() {
    if (formKey.currentState?.validate() ?? false) {
      final email = emailController.text;
      final password = passwordController.text;

      context.read<AuthBloc>().add(
            AuthEventLogin(
              email: email,
              password: password,
            ),
          );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateFailure) {
          if (state.message == 'invalid_credentials') {
            showSnackbar(context, appText.auth_login_error_message);
          } else if (state.message == 'email_not_confirmed') {
            showSnackbar(context, appText.auth_login_error_email_not_confirmed);
          } else {
            showSnackbar(context, state.message.toString());
          }
        } else if (state is AuthStateSuccessLogin) {
          showSnackbar(context, appText.auth_login_success_message);
          pushReplacementHome(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              appText.auth_login_screen_title,
              style: AppTextStyle.heading3,
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.size16),
              child: Column(
                children: [
                  Text(
                    appText.auth_login_screen_text_title,
                    style: AppTextStyle.heading1
                        .copyWith(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight12,
                  Text(
                    appText.auth_login_screen_text_subtitle,
                    style: AppTextStyle.body2,
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight24,
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        WidgetTextFormField(
                          controller: emailController,
                          label: appText.form_email_label,
                          hint: appText.form_email_hint,
                          keyboardType: TextInputType.emailAddress,
                          isLoading: state is AuthStateLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appText.form_email_required_message;
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return appText.form_email_invalid_message;
                            } else {
                              return null;
                            }
                          },
                        ),
                        AppSizes.spaceHeight12,
                        WidgetTextFormField(
                          controller: passwordController,
                          label: appText.form_password_label,
                          hint: appText.form_password_hint,
                          keyboardType: TextInputType.visiblePassword,
                          isLoading: state is AuthStateLoading,
                          obscureText: !isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: togglePasswordVisibility,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return appText.form_password_required_message;
                            }
                            if (value.length < 8) {
                              return appText.form_password_min_length_message;
                            }
                            return null;
                          },
                        ),
                        AppSizes.spaceHeight24,
                        WidgetButton(
                          label: appText.button_login,
                          isLoading: state is AuthStateLoading,
                          onPressed: onLogin,
                        ),
                        AppSizes.spaceHeight12,
                      ],
                    ),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: appText.auth_login_screen_rich_text_text,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.onSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: appText.auth_login_screen_rich_text_button,
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              pushRegister(context);
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
}
