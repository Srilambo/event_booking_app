import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ManageUsersView extends StatelessWidget {
  const ManageUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Obx(() {
        if (adminController.isLoadingUsers.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adminController.users.length,
          itemBuilder: (context, index) {
            final user = adminController.users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: AppTextStyles.button(textPrimary)),
                              Text(user.email, style: AppTextStyles.caption(textSecondary)),
                            ],
                          ),
                        ),
                        Switch(
                          value: user.isActive,
                          activeColor: AppColors.success,
                          onChanged: (val) {
                            adminController.updateUserStatus(user.id, val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Role: ', style: AppTextStyles.caption(textSecondary)),
                        DropdownButton<String>(
                          value: user.role,
                          items: ['user', 'organizer', 'admin']
                              .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                              .toList(),
                          onChanged: (newRole) {
                            if (newRole != null && newRole != user.role) {
                              adminController.updateUserRole(user.id, newRole);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
