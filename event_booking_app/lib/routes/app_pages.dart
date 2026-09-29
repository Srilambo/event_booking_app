import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import 'route_guards.dart';

import '../modules/authentication/views/splash_view.dart';
import '../modules/authentication/views/login_view.dart';
import '../modules/authentication/views/register_view.dart';
import '../modules/authentication/bindings/auth_binding.dart';

import '../modules/home/views/home_view.dart';
import '../modules/events/views/event_detail_view.dart';
import '../modules/events/views/search_filter_view.dart';
import '../modules/events/bindings/event_binding.dart';

import '../modules/bookings/views/booking_flow_view.dart';
import '../modules/bookings/views/my_bookings_view.dart';
import '../modules/bookings/bindings/booking_binding.dart';

import '../modules/profile/views/profile_view.dart';

import '../modules/admin/views/admin_dashboard_view.dart';
import '../modules/admin/views/manage_events_view.dart';
import '../modules/admin/views/manage_users_view.dart';
import '../modules/admin/bindings/admin_binding.dart';

import '../modules/common/widgets/responsive_scaffold.dart';
import '../modules/authentication/controllers/auth_controller.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    List<NavigationDestinationItem> destinations = [
      const NavigationDestinationItem(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
      const NavigationDestinationItem(label: 'My Bookings', icon: Icons.confirmation_number_outlined, selectedIcon: Icons.confirmation_number),
      const NavigationDestinationItem(label: 'Profile', icon: Icons.person_outline, selectedIcon: Icons.person),
    ];

    List<Widget> pages = [
      const HomeView(),
      const MyBookingsView(),
      const ProfileView(),
    ];

    if (authController.isAdmin) {
      destinations.add(const NavigationDestinationItem(label: 'Admin', icon: Icons.admin_panel_settings_outlined, selectedIcon: Icons.admin_panel_settings));
      pages.add(const AdminDashboardView());
    }

    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: (idx) => setState(() => _currentIndex = idx),
      destinations: destinations,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
    );
  }
}

class AppPages {
  static const initial = AppRoutes.splash;

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShellView(),
      bindings: [
        AuthBinding(),
        EventBinding(),
        BookingBinding(),
        AdminBinding(),
      ],
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.exploreEvents,
      page: () => const MainShellView(),
      bindings: [
        AuthBinding(),
        EventBinding(),
        BookingBinding(),
        AdminBinding(),
      ],
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.searchFilter,
      page: () => const SearchFilterView(),
      binding: EventBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.eventDetails,
      page: () => const EventDetailView(),
      binding: EventBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.bookingFlow,
      page: () => const BookingFlowView(),
      binding: BookingBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.bookingSuccess,
      page: () => const BookingSuccessView(),
      binding: BookingBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.myBookings,
      page: () => const MyBookingsView(),
      binding: BookingBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.manageEvents,
      page: () => const ManageEventsView(),
      bindings: [EventBinding(), AdminBinding()],
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.manageUsers,
      page: () => const ManageUsersView(),
      binding: AdminBinding(),
      middlewares: [AdminGuard()],
    ),
  ];
}
