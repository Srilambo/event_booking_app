import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();

    final customColors = context.customColors;
    final textPrimary = customColors.textPrimary;
    final textSecondary = customColors.textSecondary;
    final primary = customColors.accentPurple;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() {
          final user = authController.currentUser.value;
          final isCurrentlyDark = themeController.isDarkMode(context);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: primary.withValues(alpha: 0.15),
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : 'U',
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
                color: customColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: customColors.fieldBorder),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text('Edit Account Info', style: TextStyle(color: textPrimary)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        isCurrentlyDark ? Icons.dark_mode : Icons.light_mode,
                        color: isCurrentlyDark ? customColors.accentLime : customColors.accentPurple,
                      ),
                      title: Text('Dark Mode', style: TextStyle(color: textPrimary)),
                      subtitle: Text(
                        isCurrentlyDark ? 'Dark theme active' : 'Light theme active',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                      value: isCurrentlyDark,
                      onChanged: (_) => themeController.toggleTheme(context),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.smart_button_outlined,
                        color: customColors.accentPurple,
                      ),
                      title: Text('Show floating theme button', style: TextStyle(color: textPrimary)),
                      subtitle: Text(
                        'Drag anywhere to move, off-screen to hide',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                      value: !themeController.isFloatingButtonHidden,
                      onChanged: (val) => themeController.setFloatingButtonHidden(!val),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: Text('Security & Privacy', style: TextStyle(color: textPrimary)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: textSecondary),
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
