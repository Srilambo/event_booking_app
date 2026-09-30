import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NavigationDestinationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationDestinationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class ResponsiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<NavigationDestinationItem> destinations;
  final Widget body;
  final String? title;
  final List<Widget>? actions;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.destinations,
    required this.body,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return ResponsiveBuilder(
      mobile: (context) => Scaffold(
        appBar: title != null
            ? AppBar(
                title: Text(title!),
                actions: actions,
              )
            : null,
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onIndexChanged,
          destinations: destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon, color: primary),
                    label: d.label,
                  ))
              .toList(),
        ),
      ),
      tablet: (context) => Scaffold(
        appBar: title != null ? AppBar(title: Text(title!), actions: actions) : null,
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: onIndexChanged,
                labelType: NavigationRailLabelType.all,
                destinations: destinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon, color: primary),
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: body),
            ],
          ),
        ),
      ),
      desktop: (context) => Scaffold(
        body: Row(
          children: [
            // Permanent Left Sidebar for Desktop
            Container(
              width: 250,
              color: surface,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, color: primary, size: 32),
                      const SizedBox(width: 8),
                      Text('Eventify', style: AppTextStyles.displayMedium(primary).copyWith(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.builder(
                      itemCount: destinations.length,
                      itemBuilder: (context, index) {
                        final item = destinations[index];
                        final isSelected = index == currentIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? primary.withValues(alpha: 0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? primary : Colors.grey,
                            ),
                            title: Text(
                              item.label,
                              style: AppTextStyles.button(
                                isSelected ? primary : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            onTap: () => onIndexChanged(index),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Desktop Content Area (Max width 1200 constrained with bounded height)
            Expanded(
              child: Column(
                children: [
                  if (title != null)
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      color: surface,
                      child: Row(
                        children: [
                          Text(title!, style: AppTextStyles.title(isDark ? Colors.white : Colors.black)),
                          const Spacer(),
                          if (actions != null) ...actions!,
                        ],
                      ),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: SizedBox.expand(
                          child: body,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
