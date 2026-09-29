import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/admin_controller.dart';
import '../../common/widgets/stat_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          await adminController.fetchStats();
          await adminController.fetchUsers();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            if (adminController.isLoadingStats.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = adminController.stats.value;
            if (stats == null) {
              return const Center(child: Text('Failed to load dashboard statistics'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview', style: AppTextStyles.title(textPrimary)),
                const SizedBox(height: 16),

                // Responsive Stat Cards Grid
                GridView.count(
                  crossAxisCount: isMobile ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isMobile ? 1.3 : 1.6,
                  children: [
                    StatCard(
                      title: 'Total Revenue',
                      value: Formatters.currency(stats.totalRevenue),
                      icon: Icons.attach_money,
                      iconColor: AppColors.success,
                    ),
                    StatCard(
                      title: 'Total Bookings',
                      value: '${stats.totalBookings}',
                      icon: Icons.confirmation_number,
                      iconColor: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Total Events',
                      value: '${stats.totalEvents}',
                      icon: Icons.event,
                      iconColor: AppColors.secondary,
                    ),
                    StatCard(
                      title: 'Total Users',
                      value: '${stats.totalUsers}',
                      icon: Icons.people,
                      iconColor: AppColors.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Management Actions
                Text('Quick Management', style: AppTextStyles.title(textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.event_note),
                        label: const Text('Manage Events'),
                        onPressed: () => Get.toNamed(AppRoutes.manageEvents),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.group_outlined),
                        label: const Text('Manage Users'),
                        onPressed: () => Get.toNamed(AppRoutes.manageUsers),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Revenue Chart
                Text('Monthly Revenue Analytics', style: AppTextStyles.title(textPrimary)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 2000,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                  final idx = value.toInt() - 1;
                                  if (idx >= 0 && idx < months.length) {
                                    return Text(months[idx], style: AppTextStyles.caption(Colors.grey));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: stats.monthlyRevenue.map((m) {
                            return BarChartGroupData(
                              x: m.month,
                              barRods: [
                                BarChartRodData(
                                  toY: m.revenue > 0 ? m.revenue : 300,
                                  color: primary,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
