import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../../data/services/admin_service.dart';
import '../../../data/repositories/admin_repository_impl.dart';
import '../../../domain/usecases/admin_usecases.dart';
import '../../../core/network/dio_client.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = Get.find<DioClient>();
    final adminService = AdminService(dioClient.dio);
    final adminRepo = AdminRepositoryImpl(adminService);

    Get.lazyPut(() => GetAdminStatsUseCase(adminRepo));
    Get.lazyPut(() => GetAdminUsersUseCase(adminRepo));
    Get.lazyPut(() => UpdateUserRoleUseCase(adminRepo));
    Get.lazyPut(() => UpdateUserStatusUseCase(adminRepo));

    Get.put(AdminController(
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find(),
    ));
  }
}
