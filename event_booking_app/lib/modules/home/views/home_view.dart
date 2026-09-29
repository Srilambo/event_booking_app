import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../events/controllers/event_controller.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../common/widgets/category_chip.dart';
import '../../common/widgets/event_card.dart';
import '../../common/widgets/loading_skeleton.dart';
import '../../common/widgets/empty_state.dart';
import '../../common/widgets/error_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => eventController.fetchEvents(refresh: true),
        child: CustomScrollView(
          slivers: [
            // Header & Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        'Hello, ${authController.currentUser.value?.name ?? "Explorer"} 👋',
                        style: AppTextStyles.displayMedium(textPrimary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Find extraordinary events happening near you', style: AppTextStyles.body(textSecondary)),
                    const SizedBox(height: 20),

                    // Search Bar
                    TextField(
                      onChanged: (val) => eventController.setSearchQuery(val),
                      style: AppTextStyles.body(textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search events, cities, or venues...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: () => Get.toNamed(AppRoutes.searchFilter),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Chips
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppStrings.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = AppStrings.categories[index];
                          return Obx(
                            () => CategoryChip(
                              label: cat,
                              isSelected: eventController.selectedCategory.value == cat,
                              onTap: () => eventController.selectCategory(cat),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Upcoming Events', style: AppTextStyles.title(textPrimary)),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.exploreEvents),
                          child: Text('View All', style: AppTextStyles.button(primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Events Grid / States
            Obx(() {
              if (eventController.isLoading.value) {
                return const SliverToBoxAdapter(child: SizedBox(height: 300, child: LoadingSkeleton()));
              }

              if (eventController.errorMessage.value.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: ErrorState(
                    message: eventController.errorMessage.value,
                    onRetry: () => eventController.fetchEvents(refresh: true),
                  ),
                );
              }

              if (eventController.events.isEmpty) {
                return const SliverToBoxAdapter(
                  child: EmptyState(
                    title: 'No Events Found',
                    message: 'Try selecting another category or clearing your search filter.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = eventController.events[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.eventDetails,
                            arguments: event.id,
                          );
                        },
                      );
                    },
                    childCount: eventController.events.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
