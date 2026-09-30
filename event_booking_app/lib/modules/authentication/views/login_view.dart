import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@eventbook.com');
  final _passwordController = TextEditingController(text: 'Password123!');

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    Widget formCard = Card(
      elevation: Responsive.isDesktop(context) ? 4 : 0,
      color: Responsive.isDesktop(context)
          ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
          : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome back', style: AppTextStyles.displayMedium(textPrimary)),
              const SizedBox(height: 8),
              Text('Sign in to continue exploring events', style: AppTextStyles.body(textSecondary)),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Email Address',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: Validators.email,
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: Validators.password,
              ),
              const SizedBox(height: 24),
              Obx(
                () => AppButton(
                  text: 'Sign In',
                  width: double.infinity,
                  isLoading: authController.isLoading.value,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authController.login(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: AppTextStyles.body(textSecondary)),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: Text('Register', style: AppTextStyles.button(primary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: formCard,
          ),
          desktop: (context) => Row(
            children: [
              // Left branding & illustration
              Expanded(
                child: Container(
                  color: primary.withValues(alpha: 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_seat_rounded, size: 100, color: primary),
                      const SizedBox(height: 24),
                      Text('Eventify Platform', style: AppTextStyles.displayLarge(primary)),
                      const SizedBox(height: 12),
                      Text(
                        'Your Gateway to Premier Conferences, Concerts & Workshops',
                        style: AppTextStyles.subtitle(textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              // Right Form Container (Max 440 wide)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: formCard,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
