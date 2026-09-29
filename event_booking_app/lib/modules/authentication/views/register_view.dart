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

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
              Text('Create Account', style: AppTextStyles.displayMedium(textPrimary)),
              const SizedBox(height: 8),
              Text('Join Eventify to book your favorite events', style: AppTextStyles.body(textSecondary)),
              const SizedBox(height: 28),
              AppTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline),
                validator: (v) => Validators.required(v, 'Name is required'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email Address',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hint: 'Minimum 8 chars (letters + numbers)',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: Validators.password,
              ),
              const SizedBox(height: 24),
              Obx(
                () => AppButton(
                  text: 'Register Now',
                  width: double.infinity,
                  isLoading: authController.isLoading.value,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authController.register(
                        _nameController.text.trim(),
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
                  Text('Already have an account?', style: AppTextStyles.body(textSecondary)),
                  TextButton(
                    onPressed: () => Get.offNamed(AppRoutes.login),
                    child: Text('Sign In', style: AppTextStyles.button(primary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: ResponsiveBuilder(
          mobile: (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: formCard,
          ),
          desktop: (context) => Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: formCard,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
