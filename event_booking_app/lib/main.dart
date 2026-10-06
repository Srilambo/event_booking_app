import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/theme_toggle_button.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/network/dio_client.dart';
import 'routes/app_pages.dart';
import 'modules/authentication/bindings/auth_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeController for Theme & Floating Button Persistence
  Get.put(ThemeController(), permanent: true);

  // Initialize Global Core Services
  final storage = SecureStorageService();
  Get.put(storage, permanent: true);

  final dioClient = DioClient(storage);
  Get.put(dioClient, permanent: true);

  // Initialize Initial Auth Binding
  AuthBinding().dependencies();

  runApp(const EventifyApp());
}

class EventifyApp extends StatelessWidget {
  const EventifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Eventify - Event Booking',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialRoute: AppPages.initial,
        getPages: AppPages.pages,
        navigatorObservers: [
          GetObserver((routing) {
            if (routing?.current != null && routing!.current.isNotEmpty) {
              themeController.updateCurrentRoute(routing.current);
            }
          }),
        ],
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              const ThemeToggleButton(),
            ],
          );
        },
      ),
    );
  }
}
