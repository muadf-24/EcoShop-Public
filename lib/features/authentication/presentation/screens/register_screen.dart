import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/password_strength_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: colorScheme.error),
            );
          } else if (state is AuthAuthenticated) {
            // ✅ FIX AUTH-H01: Let go_router handle navigation via redirect
            // Router will automatically redirect to home based on auth state
            // No manual navigation needed - this prevents navigation stack issues
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Account', style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text('Join the sustainable shopping movement',
                            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 100),
                    child: CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: Validators.name,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 150),
                    child: CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'you@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 220),
                    child: PasswordStrengthIndicator(password: _passwordController.text),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 250),
                    child: CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                      onSubmitted: (_) => _onRegister(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 300),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CustomButton(
                          text: 'Create Account',
                          useGradient: true,
                          isLoading: state is AuthLoading,
                          onPressed: _onRegister,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 350),
                    child: Text.rich(
                      TextSpan(
                        text: 'By creating an account, you agree to our ',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        children: [
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                          const TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
