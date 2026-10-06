import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';

/// Redesigned Register View matching the 2-Layer Hero & Floating Surface design language
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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final purpleAccent = isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    final formCardBg = isDark ? const Color(0xFF1B1830) : Colors.white;
    final inputBg = isDark ? const Color(0xFF25213F) : const Color(0xFFF1F5F9);
    final inputBorderColor = isDark ? const Color(0xFF2F2A4D) : const Color(0xFFE2E8F0);

    Widget formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Full Name Field
          Text('Full Name', style: AppTextStyles.caption(textPrimary).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            style: AppTextStyles.body(textPrimary).copyWith(fontSize: 14),
            validator: (v) => Validators.required(v, 'Name is required'),
            decoration: InputDecoration(
              hintText: 'John Doe',
              hintStyle: AppTextStyles.caption(textSecondary),
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: inputBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF8BE232), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
              ),
              errorStyle: AppTextStyles.caption(const Color(0xFFFF6B6B)).copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Email Address Field
          Text('Email Address', style: AppTextStyles.caption(textPrimary).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.body(textPrimary).copyWith(fontSize: 14),
            validator: Validators.email,
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: AppTextStyles.caption(textSecondary),
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: inputBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF8BE232), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
              ),
              errorStyle: AppTextStyles.caption(const Color(0xFFFF6B6B)).copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Password Field Section
          Text('Password', style: AppTextStyles.caption(textPrimary).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTextStyles.body(textPrimary).copyWith(fontSize: 14),
            validator: Validators.password,
            decoration: InputDecoration(
              hintText: 'Minimum 8 characters',
              hintStyle: AppTextStyles.caption(textSecondary),
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: inputBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF8BE232), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
              ),
              errorStyle: AppTextStyles.caption(const Color(0xFFFF6B6B)).copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Lime Accent Full-Width CTA "Register Now" Button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BE232),
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: authController.isLoading.value
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          authController.register(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                        }
                      },
                child: authController.isLoading.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0F172A)),
                      )
                    : Text(
                        'Register Now',
                        style: AppTextStyles.button(const Color(0xFF0F172A)).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Footer Link ("Already have an account? Sign In")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?', style: AppTextStyles.caption(textSecondary)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Get.offNamed(AppRoutes.login),
                child: Text(
                  'Sign In',
                  style: AppTextStyles.button(purpleAccent).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ResponsiveBuilder(
        mobile: (context) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // TOP HERO SECTION (~30% of screen height)
              SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    // Festival/Crowd Photo Background
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=1200&q=80',
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E1B4B)),
                      ),
                    ),
                    // Dark Gradient Overlay
                    Container(
                      height: 240,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0x880F0D1A),
                            Color(0xFF0F0D1A),
                          ],
                          stops: [0.0, 0.45, 0.9],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Top App Header & Welcome Headline
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                                  onPressed: () => Get.back(),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.confirmation_number, color: Color(0xFF8BE232), size: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'EventBook',
                                  style: AppTextStyles.title(Colors.white).copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'Create Account',
                              style: AppTextStyles.displayMedium(Colors.white).copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Join EventBook to discover & book extraordinary events',
                              style: AppTextStyles.body(Colors.white70).copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM FORM CARD (Overlaps Hero by ~24px with slide-up animation)
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: formCardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: formContent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        desktop: (context) => Row(
          children: [
            Expanded(
              child: Container(
                color: const Color(0xFF1B1830),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.confirmation_number, size: 80, color: Color(0xFF8BE232)),
                        const SizedBox(height: 20),
                        Text('EventBook', style: AppTextStyles.displayLarge(Colors.white)),
                        const SizedBox(height: 12),
                        Text(
                          'Join thousands of event lovers exploring live music, tech summits & cultural festivals',
                          style: AppTextStyles.subtitle(Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: formCardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: formContent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
