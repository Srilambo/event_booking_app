import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/event_controller.dart';
import '../widgets/event_map_pin.dart';
import '../../../data/models/event_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';

/// Helper item for spatial grid clustering
class _MapCluster {
  final LatLng center;
  final List<int> eventIndices;

  _MapCluster({
    required this.center,
    required this.eventIndices,
  });
}

/// Redesigned Smart Search & Map View featuring modern Airbnb/Uber map markers,
/// spatial clustering, user geolocation, and overflow-free event cards.
class SearchFilterView extends StatefulWidget {
  const SearchFilterView({super.key});

  @override
  State<SearchFilterView> createState() => _SearchFilterViewState();
}

class _SearchFilterViewState extends State<SearchFilterView> {
  final EventController _eventController = Get.find<EventController>();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.90);
  final MapController _mapController = MapController();

  int _selectedMarkerIndex = 0;
  bool _isMapViewEnabled = true;
  double _currentZoom = 12.0;
  LatLng? _userLocation;
  bool _isLocating = false;

  static const LatLng _colomboLocation = LatLng(6.9271, 79.8612);

  LatLng _getEventCoordinate(int index) {
    final events = _eventController.events;
    if (index >= 0 && index < events.length) {
      final event = events[index];
      if (event.latitude != 0.0 && event.longitude != 0.0) {
        return LatLng(event.latitude, event.longitude);
      }
    }
    return _colomboLocation;
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = _eventController.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Request live GPS user position and center camera on it
  Future<void> _getUserLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Service Disabled',
          'Please turn on GPS/location services on your device.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required to find your position.',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          );
          setState(() => _isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Location permissions are permanently denied. Please enable in device settings.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      final userCoord = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = userCoord;
      });

      HapticFeedback.lightImpact();
      _mapController.move(userCoord, 14.5);
    } catch (e) {
      debugPrint('Failed to fetch user location: $e');
      Get.snackbar(
        'Location Unavailable',
        'Could not detect current position. Showing Colombo area.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  /// Triggered on marker or card selection: applies haptics, animates camera and scrolls PageView
  void _onMarkerSelected(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedMarkerIndex = index);

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
    final coord = _getEventCoordinate(index);
    _mapController.move(coord, _currentZoom.clamp(13.5, 16.0));
  }

  /// Spatial grid clustering: groups nearby unselected markers when zoomed out (< 13.5)
  List<_MapCluster> _computeClusters(List<EventModel> events) {
    if (_currentZoom >= 13.5 || events.isEmpty) {
      return [];
    }

    final double clusterDistanceThreshold = 0.025 * (14.0 - _currentZoom);
    final List<_MapCluster> clusters = [];
    final Set<int> clusteredIndices = {};

    for (int i = 0; i < events.length; i++) {
      // Keep selected event isolated so it's always visible as top-most selected pin
      if (i == _selectedMarkerIndex || clusteredIndices.contains(i)) continue;

      final coordI = _getEventCoordinate(i);
      final List<int> currentGroup = [i];

      for (int j = i + 1; j < events.length; j++) {
        if (j == _selectedMarkerIndex || clusteredIndices.contains(j)) continue;

        final coordJ = _getEventCoordinate(j);
        final double dist = (coordI.latitude - coordJ.latitude).abs() +
            (coordI.longitude - coordJ.longitude).abs();

        if (dist < clusterDistanceThreshold) {
          currentGroup.add(j);
        }
      }

      if (currentGroup.length > 1) {
        clusteredIndices.addAll(currentGroup);
        double sumLat = 0;
        double sumLng = 0;
        for (final idx in currentGroup) {
          final c = _getEventCoordinate(idx);
          sumLat += c.latitude;
          sumLng += c.longitude;
        }
        clusters.add(
          _MapCluster(
            center: LatLng(sumLat / currentGroup.length, sumLng / currentGroup.length),
            eventIndices: currentGroup,
          ),
        );
      }
    }

    return clusters;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;
    final textPrimary = customColors.textPrimary;
    final textSecondary = customColors.textSecondary;
    final surfaceColor = customColors.surface;
    final borderColor = customColors.fieldBorder;

    return Scaffold(
      backgroundColor: customColors.background,
      body: Obx(() {
        final events = _eventController.events;
        final hasActiveFilters = _eventController.searchQuery.value.isNotEmpty ||
            _eventController.selectedCity.value.isNotEmpty ||
            _eventController.selectedCategory.value != 'All';

        // Compute clusters and unclustered pin indices
        final clusters = _computeClusters(events);
        final Set<int> clusteredIndexSet = {};
        for (final c in clusters) {
          clusteredIndexSet.addAll(c.eventIndices);
        }

        final List<int> unclusteredIndices = [];
        for (int i = 0; i < events.length; i++) {
          if (i != _selectedMarkerIndex && !clusteredIndexSet.contains(i)) {
            unclusteredIndices.add(i);
          }
        }

        final bool hasValidSelected =
            events.isNotEmpty && _selectedMarkerIndex >= 0 && _selectedMarkerIndex < events.length;

        return Stack(
          children: [
            // 1. MAP LAYER
            Positioned.fill(
              child: _isMapViewEnabled
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _colomboLocation,
                        initialZoom: _currentZoom,
                        onPositionChanged: (camera, hasGesture) {
                          if ((camera.zoom - _currentZoom).abs() > 0.05) {
                            setState(() {
                              _currentZoom = camera.zoom;
                            });
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.eventbook.app',
                          retinaMode: RetinaMode.isHighDensity(context),
                          tileBuilder: isDark
                              ? (context, tileWidget, tile) {
                                  return ColorFiltered(
                                    colorFilter: const ColorFilter.matrix(<double>[
                                      -1, 0, 0, 0, 255,
                                      0, -1, 0, 0, 255,
                                      0, 0, -1, 0, 255,
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: tileWidget,
                                  );
                                }
                              : null,
                        ),

                        // USER GPS LOCATION LAYER (Blue pulsing dot)
                        if (_userLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _userLocation!,
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                child: const UserLocationDotMarker(),
                              ),
                            ],
                          ),

                        // UNSELECTED MARKERS & CLUSTERS LAYER
                        MarkerLayer(
                          markers: [
                            // Clusters (Gradient circle with bold count)
                            ...clusters.map((cluster) {
                              return Marker(
                                point: cluster.center,
                                width: 62.0,
                                height: 62.0,
                                alignment: Alignment.center,
                                child: EventMapCluster(
                                  count: cluster.eventIndices.length,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    _mapController.move(
                                      cluster.center,
                                      (_currentZoom + 2.0).clamp(1.0, 18.0),
                                    );
                                  },
                                ),
                              );
                            }),

                            // Unselected Pins
                            ...unclusteredIndices.map((index) {
                              final event = events[index];
                              final coord = _getEventCoordinate(index);
                              final showPrice = _currentZoom >= 14.0;

                              return Marker(
                                point: coord,
                                width: 50.0,
                                height: showPrice ? 68.0 : 50.0,
                                alignment: showPrice
                                    ? const Alignment(0.0, 0.42)
                                    : Alignment.bottomCenter,
                                child: EventMapPin(
                                  category: event.category,
                                  isSelected: false,
                                  price: event.price,
                                  showPriceLabel: showPrice,
                                  onTap: () => _onMarkerSelected(index),
                                ),
                              );
                            }),
                          ],
                        ),

                        // TOP-MOST SELECTED PIN LAYER (Always draws above all markers)
                        if (hasValidSelected)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _getEventCoordinate(_selectedMarkerIndex),
                                width: 92.0,
                                height: 104.0,
                                alignment: Alignment.bottomCenter,
                                child: EventMapPin(
                                  category: events[_selectedMarkerIndex].category,
                                  isSelected: true,
                                  price: events[_selectedMarkerIndex].price,
                                  showPriceLabel: false,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),

                        // Attribution Label
                        Positioned(
                          left: 12,
                          bottom: mediaQuery.padding.bottom + 210,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '© OpenStreetMap',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: customColors.background),
            ),

            // 2. TOP FLOATING HEADER (Search & Category Chips)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.arrow_back, color: textPrimary, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => _eventController.setSearchQuery(val),
                                style: AppTextStyles.body(textPrimary).copyWith(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search events, venues...',
                                  hintStyle: AppTextStyles.caption(textSecondary),
                                  prefixIcon: Icon(Icons.search, size: 20, color: textSecondary),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, size: 18, color: textSecondary),
                                          onPressed: () {
                                            _searchController.clear();
                                            _eventController.setSearchQuery('');
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => setState(() => _isMapViewEnabled = !_isMapViewEnabled),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isMapViewEnabled ? Icons.format_list_bulleted : Icons.map_outlined,
                                color: textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filter Chips Row
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [Colors.black, Colors.black, Colors.transparent],
                            stops: [0.0, 0.90, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.dstIn,
                        child: SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(right: 24, left: 4),
                            children: [
                              ...AppStrings.categories.map((cat) {
                                final isSelected = _eventController.selectedCategory.value == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChipPill(
                                    label: cat,
                                    isSelected: isSelected,
                                    onTap: () => _eventController.selectCategory(cat),
                                  ),
                                );
                              }),
                              if (hasActiveFilters)
                                FilterChipPill(
                                  label: 'Reset',
                                  icon: Icons.refresh_outlined,
                                  isSelected: false,
                                  isReset: true,
                                  onTap: () {
                                    _searchController.clear();
                                    _eventController.searchQuery.value = '';
                                    _eventController.selectedCity.value = '';
                                    _eventController.selectedCategory.value = 'All';
                                    _eventController.fetchEvents();
                                  },
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

            // 3. FLOATING "MY LOCATION" CIRCULAR BUTTON (48px)
            if (_isMapViewEnabled)
              Positioned(
                right: 16,
                bottom: mediaQuery.padding.bottom + 12 + 124 + 12 + 40 + 12,
                child: GestureDetector(
                  onTap: _getUserLocation,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLocating
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: isDark ? customColors.accentLime : customColors.accentPurple,
                            ),
                          )
                        : Icon(
                            Icons.my_location_rounded,
                            color: _userLocation != null ? const Color(0xFF3B82F6) : textPrimary,
                            size: 22,
                          ),
                  ),
                ),
              ),

            // 4. BOTTOM FLOATING CONTROLS (Pagination & Fixed Height 124 Card)
            Positioned(
              left: 0,
              right: 0,
              bottom: mediaQuery.padding.bottom + 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pagination Stepper Pill
                  if (events.isNotEmpty) ...[
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              size: 12,
                              color: _selectedMarkerIndex > 0 ? textPrimary : Colors.grey,
                            ),
                            onPressed: _selectedMarkerIndex > 0
                                ? () => _onMarkerSelected(_selectedMarkerIndex - 1)
                                : null,
                          ),
                          const SizedBox(width: 4),
                          ...List.generate(events.length.clamp(0, 6), (index) {
                            final isSelected = index == _selectedMarkerIndex;
                            return GestureDetector(
                              onTap: () => _onMarkerSelected(index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isSelected ? 22 : 18,
                                height: isSelected ? 22 : 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? customColors.accentLime : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: AppTextStyles.caption(
                                    isSelected ? const Color(0xFF0F0D1A) : textSecondary,
                                  ).copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 4),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: _selectedMarkerIndex < events.length - 1
                                  ? textPrimary
                                  : Colors.grey,
                            ),
                            onPressed: _selectedMarkerIndex < events.length - 1
                                ? () => _onMarkerSelected(_selectedMarkerIndex + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Swipeable Event Cards (Fixed height 124, zero overflow)
                  if (_eventController.isLoading.value)
                    Container(
                      height: 124,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (events.isEmpty)
                    Container(
                      height: 124,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No events found', style: AppTextStyles.body(textPrimary)),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              _eventController.searchQuery.value = '';
                              _eventController.selectCategory('All');
                            },
                            child: Text(
                              'Reset',
                              style: TextStyle(color: customColors.accentLime),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 124,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: events.length,
                        onPageChanged: (index) {
                          _onMarkerSelected(index);
                        },
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: EventMiniCard(
                              event: event,
                              onTap: () =>
                                  Get.toNamed(AppRoutes.eventDetails, arguments: event.id),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Filter Chip Pill Widget with ThemeExtension color lookups
class FilterChipPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final bool isReset;
  final VoidCallback onTap;

  const FilterChipPill({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    this.isReset = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    Color bg;
    Color fg;

    if (isReset) {
      bg = AppColors.error.withValues(alpha: 0.2);
      fg = AppColors.error;
    } else if (isSelected) {
      bg = customColors.accentLime;
      fg = const Color(0xFF0F0D1A);
    } else {
      bg = customColors.surface;
      fg = customColors.textSecondary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: isSelected || isReset
              ? null
              : Border.all(color: customColors.fieldBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.caption(fg).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Event Mini Card Widget with 88x88 Shimmer / Category fallback image,
/// Expanded text column, title maxLines 2, venue maxLines 1, and spaceBetween price/book row.
class EventMiniCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventMiniCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;
    final textPrimary = customColors.textPrimary;
    final textSecondary = customColors.textSecondary;
    final cardBg = customColors.surface;

    final validImageUrl = (event.imageUrl.isNotEmpty && event.imageUrl.startsWith('http'))
        ? event.imageUrl
        : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80';

    final categoryColor = getCategoryColor(event.category);
    final categoryIcon = getCategoryIcon(event.category);

    return Container(
      height: 124,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: customColors.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                // 1. Image 88x88, radius 14 with Shimmer placeholder & Category icon fallback
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: CachedNetworkImage(
                      imageUrl: validImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: isDark ? const Color(0xFF232035) : const Color(0xFFE5E7EB),
                        highlightColor: isDark ? const Color(0xFF322E48) : const Color(0xFFF3F4F6),
                        child: Container(
                          width: 88,
                          height: 88,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 88,
                        height: 88,
                        color: categoryColor.withValues(alpha: 0.18),
                        child: Center(
                          child: Icon(
                            categoryIcon,
                            color: categoryColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Text Content (Expanded, spaceBetween, no overflow)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title maxLines 2 with ellipsis
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle(textPrimary).copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),

                      // Venue & City maxLines 1 with ellipsis
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.tertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${event.venue}, ${event.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(textSecondary).copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),

                      // Price badge & Book button with spaceBetween
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: customColors.accentLime,
                              borderRadius: AppRadius.borderChip,
                            ),
                            child: Text(
                              event.price > 0 ? Formatters.currency(event.price) : 'FREE',
                              style: AppTextStyles.caption(const Color(0xFF0F0D1A)).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: customColors.accentLime,
                              borderRadius: AppRadius.borderChip,
                            ),
                            child: Text(
                              'Book',
                              style: AppTextStyles.caption(const Color(0xFF0F0D1A)).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
