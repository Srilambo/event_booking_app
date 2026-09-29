import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/category_chip.dart';

class SearchFilterView extends StatefulWidget {
  const SearchFilterView({super.key});

  @override
  State<SearchFilterView> createState() => _SearchFilterViewState();
}

class _SearchFilterViewState extends State<SearchFilterView> {
  final EventController _eventController = Get.find<EventController>();
  final _searchController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.text = _eventController.searchQuery.value;
    _cityController.text = _eventController.selectedCity.value;
    _selectedCategory = _eventController.selectedCategory.value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter & Search Events'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _cityController.clear();
                _selectedCategory = 'All';
              });
              _eventController.searchQuery.value = '';
              _eventController.selectedCity.value = '';
              _eventController.selectedCategory.value = 'All';
              _eventController.fetchEvents();
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.secondary)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Keywords', style: AppTextStyles.subtitle(textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                style: AppTextStyles.body(textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search by event title or topic...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24),
              Text('City / Location', style: AppTextStyles.subtitle(textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _cityController,
                style: AppTextStyles.body(textPrimary),
                decoration: const InputDecoration(
                  hintText: 'New York, Los Angeles, Chicago...',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 24),
              Text('Category', style: AppTextStyles.subtitle(textPrimary)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppStrings.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return CategoryChip(
                    label: cat,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              AppButton(
                text: 'Apply Filters',
                width: double.infinity,
                onPressed: () {
                  _eventController.searchQuery.value = _searchController.text.trim();
                  _eventController.selectedCity.value = _cityController.text.trim();
                  _eventController.selectedCategory.value = _selectedCategory;
                  _eventController.fetchEvents();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
