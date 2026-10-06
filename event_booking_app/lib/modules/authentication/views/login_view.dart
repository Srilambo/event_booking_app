import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';

/// Redesigned Modern Login View matching the 2-Layer Hero & Floating Surface card style
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@eventbook.com');
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _obscurePassword = true;
  final bool _isGooglePressed = false;
  final bool _isApplePressed = false;

  @override
  void dispose() {
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
          // 1. Email Field Section
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

          // 2. Password Field Section
          Text('Password', style: AppTextStyles.caption(textPrimary).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTextStyles.body(textPrimary).copyWith(fontSize: 14),
            validator: Validators.password,
            decoration: InputDecoration(
              hintText: '••••••••',
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
          const SizedBox(height: 6),

          // Forgot Password Link (Right Aligned)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Get.snackbar(
                  'Password Reset',
                  'A password reset link has been sent to your email.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: formCardBg,
                  colorText: textPrimary,
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: AppTextStyles.caption(purpleAccent).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Full-Width Lime CTA "Sign In" Button with Loading Spinner State
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
                          authController.login(
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
                        'Sign In',
                        style: AppTextStyles.button(const Color(0xFF0F172A)).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Divider Row ("or continue with")
          Row(
            children: [
              Expanded(child: Divider(color: inputBorderColor, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or continue with', style: AppTextStyles.caption(textSecondary)),
              ),
              Expanded(child: Divider(color: inputBorderColor, thickness: 1)),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Social Login Buttons Side by Side (Google & Apple)
          Row(
            children: [
              Expanded(
                child: AnimatedScale(
                  scale: _isGooglePressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: inputBorderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {},
                    onLongPress: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.redAccent),
                    label: Text('Google', style: AppTextStyles.button(textPrimary).copyWith(fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedScale(
                  scale: _isApplePressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: inputBorderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {},
                    onLongPress: () {},
                    icon: Icon(Icons.apple, size: 22, color: textPrimary),
                    label: Text('Apple', style: AppTextStyles.button(textPrimary).copyWith(fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 6. Footer ("Don't have an account? Register")
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: AppTextStyles.caption(textSecondary)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.register),
                child: Text(
                  'Register',
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
              // TOP HERO SECTION (~35% of screen height)
              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    // Concert Background Photo with rounded bottom 32
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80',
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E1B4B)),
                      ),
                    ),
                    // Dark Gradient Overlay (Transparent to #0F0D1A)
                    Container(
                      height: 260,
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
                    // App Branding & Welcome Text
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App Logo Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.confirmation_number, color: Color(0xFF8BE232), size: 20),
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
                              'Welcome back',
                              style: AppTextStyles.displayMedium(Colors.white).copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to continue exploring events',
                              style: AppTextStyles.body(Colors.white70).copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM FORM CARD (Overlaps Hero by ~24px with smooth slide-up animation)
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
            // Left branding illustration container
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
                          'Your Gateway to Premier Conferences, Concerts & Workshops',
                          style: AppTextStyles.subtitle(Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Right Form Container (Max 460 wide)
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
