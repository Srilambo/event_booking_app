import 'package:get/get.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthController(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
  );

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (_) {}
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final user = await _loginUseCase(email, password);
      currentUser.value = user;
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Login Failed', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final user = await _registerUseCase(name, email, password);
      currentUser.value = user;
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Registration Failed', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase();
    } catch (_) {}
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;
  bool get isOrganizer => currentUser.value?.isOrganizer ?? false;
}
