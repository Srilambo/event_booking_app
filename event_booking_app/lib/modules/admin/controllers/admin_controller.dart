import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../domain/usecases/admin_usecases.dart';
import '../../../data/models/admin_stats_model.dart';
import '../../../data/models/user_model.dart';

class AdminController extends GetxController {
  final GetAdminStatsUseCase _getAdminStatsUseCase;
  final GetAdminUsersUseCase _getAdminUsersUseCase;
  final UpdateUserRoleUseCase _updateUserRoleUseCase;
  final UpdateUserStatusUseCase _updateUserStatusUseCase;

  AdminController(
    this._getAdminStatsUseCase,
    this._getAdminUsersUseCase,
    this._updateUserRoleUseCase,
    this._updateUserStatusUseCase,
  );

  final Rx<AdminStatsModel?> stats = Rx<AdminStatsModel?>(null);
  final RxList<UserModel> users = <UserModel>[].obs;

  final RxBool isLoadingStats = false.obs;
  final RxBool isLoadingUsers = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
    fetchUsers();
  }

  Future<void> fetchStats() async {
    try {
      isLoadingStats.value = true;
      final result = await _getAdminStatsUseCase();
      stats.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoadingUsers.value = true;
      final result = await _getAdminUsersUseCase();
      users.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final updatedUser = await _updateUserRoleUseCase(userId, newRole);
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = updatedUser;
      }
      Get.snackbar('Success', 'User role updated to $newRole');
    } catch (e) {
      Get.snackbar('Update Failed', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      final updatedUser = await _updateUserStatusUseCase(userId, isActive);
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = updatedUser;
      }
      Get.snackbar('Success', 'User status updated');
    } catch (e) {
      Get.snackbar('Update Failed', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
