import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/authentication/controllers/auth_controller.dart';
import 'app_routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (!authController.isAdmin) {
      Get.snackbar('Access Denied', 'Admin privileges required');
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}
