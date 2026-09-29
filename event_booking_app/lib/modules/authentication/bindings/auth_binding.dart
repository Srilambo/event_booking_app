import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final dioClient = Get.find<DioClient>();
    final storage = Get.find<SecureStorageService>();

    final authService = AuthService(dioClient.dio);
    final authRepo = AuthRepositoryImpl(authService, storage);

    Get.lazyPut(() => LoginUseCase(authRepo));
    Get.lazyPut(() => RegisterUseCase(authRepo));
    Get.lazyPut(() => LogoutUseCase(authRepo));
    Get.lazyPut(() => GetCurrentUserUseCase(authRepo));

    Get.put(AuthController(
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find(),
    ), permanent: true);
  }
}
