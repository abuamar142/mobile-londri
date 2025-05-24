import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import 'login_screen.dart';

void pushRegister(BuildContext context) {
  context.pushNamed('register');
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordAgainController = TextEditingController();
  bool isPasswordVisible = false;
  bool isPasswordAgainVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void togglePasswordAgainVisibility() {
    setState(() {
      isPasswordAgainVisible = !isPasswordAgainVisible;
    });
  }

  void onRegister() {
    if (formKey.currentState?.validate() ?? false) {
      final name = nameController.text;
      final email = emailController.text;
      final password = passwordController.text;
      final passwordAgain = passwordAgainController.text;

      context.read<AuthBloc>().add(
            AuthEventRegister(
              name: name,
              email: email,
              password: password,
              passwordAgain: passwordAgain,
            ),
          );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordAgainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateFailure) {
          showSnackbar(context, state.message.toString());
        } else if (state is AuthStateSuccessRegister) {
          showSnackbar(context, appText.auth_register_success_message);
          pushReplacementLogin(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: WidgetAppBar(
            label: appText.auth_register_screen_title,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.size16),
              child: Column(
                children: [
                  Text(
                    appText.auth_register_screen_text_title,
                    style: AppTextStyle.heading1.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight12,
                  Text(
                    appText.auth_register_screen_text_subtitle,
                    style: AppTextStyle.body2,
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight24,
                  _buildRegisterForm(appText, state),
                  AppSizes.spaceHeight12,
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: appText.auth_register_screen_rich_text_text,
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.onSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: appText.auth_register_screen_rich_text_button,
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.pop();
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

  Form _buildRegisterForm(AppLocalizations appText, AuthState state) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          WidgetTextFormField(
            controller: nameController,
            label: appText.form_name_label,
            hint: appText.form_name_hint,
            keyboardType: TextInputType.name,
            isLoading: state is AuthStateLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return appText.form_name_required_message;
              }
              return null;
            },
          ),
          AppSizes.spaceHeight12,
          Hero(
            tag: 'form-email',
            child: WidgetTextFormField(
              controller: emailController,
              label: appText.form_email_label,
              hint: appText.form_email_hint,
              keyboardType: TextInputType.emailAddress,
              isLoading: state is AuthStateLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appText.form_email_required_message;
                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return appText.form_email_invalid_message;
                }
                return null;
              },
            ),
          ),
          AppSizes.spaceHeight12,
          Hero(
            tag: 'form-password',
            child: WidgetTextFormField(
              controller: passwordController,
              label: appText.form_password_label,
              hint: appText.form_password_hint,
              keyboardType: TextInputType.visiblePassword,
              isLoading: state is AuthStateLoading,
              obscureText: !isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
          ),
          AppSizes.spaceHeight12,
          WidgetTextFormField(
            controller: passwordAgainController,
            label: appText.form_confirm_password_label,
            hint: appText.form_confirm_password_hint,
            keyboardType: TextInputType.visiblePassword,
            isLoading: state is AuthStateLoading,
            obscureText: !isPasswordAgainVisible,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordAgainVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: togglePasswordAgainVisibility,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return appText.form_confirm_password_required_message;
              }
              if (value != passwordController.text) {
                return appText.form_confirm_password_match_message;
              }
              return null;
            },
          ),
          AppSizes.spaceHeight24,
          WidgetButton(
            label: appText.button_register,
            isLoading: state is AuthStateLoading,
            onPressed: onRegister,
          ),
        ],
      ),
    );
  }
}
