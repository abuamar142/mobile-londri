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
import '../bloc/auth_bloc.dart';
import 'login_screen.dart';

void pushRegister({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.register);
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthBloc _authBloc;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordAgainVisible = false;

  @override
  void initState() {
    super.initState();

    _authBloc = serviceLocator<AuthBloc>();
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
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthStateFailure) {
          context.showSnackbar(state.message.toString());
        } else if (state is AuthStateSuccessRegister) {
          context.showSnackbar(context.appText.auth_register_success_message);
          pushReplacementLogin(context: context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: WidgetAppBar(label: context.appText.auth_register_screen_title),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.size16),
              child: Column(
                children: [
                  Text(
                    context.appText.auth_register_screen_text_title,
                    style: AppTextStyle.heading1.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight12,
                  Text(
                    context.appText.auth_register_screen_text_subtitle,
                    style: AppTextStyle.body2,
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.spaceHeight24,
                  _buildRegisterForm(state: state),
                  AppSizes.spaceHeight12,
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: context.appText.auth_register_screen_rich_text_text,
                      style: AppTextStyle.caption.copyWith(color: AppColors.onSecondary),
                      children: [
                        TextSpan(
                          text: context.appText.auth_register_screen_rich_text_button,
                          style: AppTextStyle.caption.copyWith(color: AppColors.primary),
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

  Form _buildRegisterForm({required AuthState state}) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          WidgetTextFormField(
            controller: _nameController,
            label: context.appText.form_name_label,
            hint: context.appText.form_name_hint,
            keyboardType: TextInputType.name,
            isLoading: state is AuthStateLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.appText.form_name_required_message;
              }
              return null;
            },
          ),
          AppSizes.spaceHeight12,
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
              }
              return null;
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
              onPressed: togglePasswordVisibility,
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
          AppSizes.spaceHeight12,
          WidgetTextFormField(
            controller: _passwordAgainController,
            label: context.appText.form_confirm_password_label,
            hint: context.appText.form_confirm_password_hint,
            keyboardType: TextInputType.visiblePassword,
            isLoading: state is AuthStateLoading,
            obscureText: !_isPasswordAgainVisible,
            suffixIcon: IconButton(
              icon: Icon(_isPasswordAgainVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: togglePasswordAgainVisibility,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.appText.form_confirm_password_required_message;
              }
              if (value != _passwordController.text) {
                return context.appText.form_confirm_password_match_message;
              }
              return null;
            },
          ),
          AppSizes.spaceHeight24,
          WidgetButton(
            label: context.appText.button_register,
            isLoading: state is AuthStateLoading,
            onPressed: onRegister,
          ),
        ],
      ),
    );
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void togglePasswordAgainVisibility() {
    setState(() {
      _isPasswordAgainVisible = !_isPasswordAgainVisible;
    });
  }

  void onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final passwordAgain = _passwordAgainController.text;

      _authBloc.add(AuthEventRegister(
        name: name,
        email: email,
        password: password,
        passwordAgain: passwordAgain,
      ));
    }
  }
}
