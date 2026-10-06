import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../events/controllers/event_controller.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../common/widgets/event_card.dart';
import '../../common/widgets/loading_skeleton.dart';
import '../../common/widgets/empty_state.dart';
import '../../common/widgets/error_state.dart';

/// Refined Home View using ThemeExtension context color lookups
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _locationController = TextEditingController(text: 'Colombo, LK');
  final TextEditingController _priceController = TextEditingController(text: 'Min LKR 1,000');

  @override
  void dispose() {
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;
    final textPrimary = customColors.textPrimary;
    final textSecondary = customColors.textSecondary;
    final surface = customColors.surface;
    final searchCardBg = customColors.surface;
    final cardInputBg = customColors.fieldFill;
    final inputBorderColor = customColors.fieldBorder;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final carouselCardWidth = (screenWidth * 0.78).clamp(280.0, 360.0);

    return Scaffold(
      backgroundColor: customColors.background,
      body: RefreshIndicator(
        onRefresh: () => eventController.fetchEvents(refresh: true),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar / User Greeting
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              'Hello, ${authController.currentUser.value?.name ?? "Explorer"} 👋',
                              style: AppTextStyles.title(textPrimary),
                            ),
                          ),
                          Text('Discover extraordinary events near you', style: AppTextStyles.caption(textSecondary)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: inputBorderColor),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.notifications_none, color: textPrimary),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // TWO-LAYER HERO + FLOATING SEARCH CARD SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  height: 425,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // LAYER 1: HERO (Height ~220px, rounded 24px, photo + gradient overlay to #0F0D1A)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 220,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                Image.network(
                                  'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80',
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E1B4B)),
                                ),
                                Container(
                                  height: 220,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0x990F0D1A),
                                        Color(0xFF0F0D1A),
                                      ],
                                      stops: [0.0, 0.45, 0.85],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          borderRadius: AppRadius.borderChip,
                                        ),
                                        child: Text(
                                          '🔥 AI Event Engine',
                                          style: AppTextStyles.caption(Colors.white).copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Effortless Event Discovery',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.displayLarge(Colors.white).copyWith(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          height: 1.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // LAYER 2: FLOATING SEARCH CARD
                      Positioned(
                        top: 170,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: searchCardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: inputBorderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Category Pills Row
                              SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(right: 16),
                                  itemCount: AppStrings.categories.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final cat = AppStrings.categories[index];
                                    return Obx(() {
                                      final isSelected = eventController.selectedCategory.value == cat;
                                      return GestureDetector(
                                        onTap: () => eventController.selectCategory(cat),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? customColors.accentLime
                                                : customColors.fieldFill,
                                            borderRadius: AppRadius.borderChip,
                                          ),
                                          child: Text(
                                            cat,
                                            style: AppTextStyles.button(
                                              isSelected
                                                  ? const Color(0xFF0F0D1A)
                                                  : textSecondary,
                                            ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Location Input
                              SizedBox(
                                height: 48,
                                child: TextField(
                                  controller: _locationController,
                                  style: AppTextStyles.body(textPrimary).copyWith(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Location',
                                    hintStyle: AppTextStyles.caption(textSecondary),
                                    prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: textSecondary),
                                    fillColor: cardInputBg,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: inputBorderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: customColors.accentLime, width: 1.5),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Price Input + Filter Button
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: TextField(
                                        controller: _priceController,
                                        style: AppTextStyles.body(textPrimary).copyWith(fontSize: 13),
                                        decoration: InputDecoration(
                                          hintText: 'Min Price',
                                          hintStyle: AppTextStyles.caption(textSecondary),
                                          prefixIcon: Icon(Icons.attach_money, size: 18, color: textSecondary),
                                          fillColor: cardInputBg,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: inputBorderColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            borderSide: BorderSide(color: customColors.accentLime, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: cardInputBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: inputBorderColor),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.tune, size: 20, color: textPrimary),
                                      onPressed: () => Get.toNamed(AppRoutes.searchFilter),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Lime Action Button ("Discover Events")
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: customColors.accentLime,
                                    foregroundColor: const Color(0xFF0F0D1A),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.borderChip,
                                    ),
                                  ),
                                  onPressed: () => eventController.fetchEvents(refresh: true),
                                  child: Text(
                                    'Discover Events',
                                    style: AppTextStyles.button(const Color(0xFF0F0D1A)).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section Header: Upcoming Events
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Events', style: AppTextStyles.title(textPrimary)),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.exploreEvents),
                      child: Text('View All', style: AppTextStyles.button(customColors.accentPurple)),
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming Events Carousel
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

              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 360,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: eventController.events.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final event = eventController.events[index];
                      return EventCard(
                        width: carouselCardWidth,
                        event: event,
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.eventDetails,
                            arguments: event.id,
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            }),

            const SliverPadding(
              padding: EdgeInsets.only(bottom: 120),
            ),
          ],
        ),
      ),
    );
  }
}
