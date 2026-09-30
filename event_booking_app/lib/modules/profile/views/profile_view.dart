import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileController extends GetxController {
  final RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.put(ProfileController());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() {
          final user = authController.currentUser.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: primary.withValues(alpha: 0.15),
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTextStyles.displayLarge(primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(user?.name ?? 'Guest User', style: AppTextStyles.title(textPrimary)),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: AppTextStyles.body(textSecondary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppColors.radiusChip),
                ),
                child: Text(
                  'ROLE: ${(user?.role ?? "user").toUpperCase()}',
                  style: AppTextStyles.caption(primary).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 36),

              // Settings List
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Edit Account Info'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    Obx(
                      () => SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Dark Mode'),
                        value: profileController.isDarkMode.value,
                        onChanged: (_) => profileController.toggleTheme(),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: const Text('Security & Privacy'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () => authController.logout(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
