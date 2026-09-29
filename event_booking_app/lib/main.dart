import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/network/dio_client.dart';
import 'routes/app_pages.dart';
import 'modules/authentication/bindings/auth_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return GetMaterialApp(
      title: 'Eventify - Event Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      builder: (context, child) {
        // Enforce anti-overflow text scaling clamp as specified in Prompt 2
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
