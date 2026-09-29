import '../../domain/repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._authService, this._storage);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await _authService.login(email, password);
    final user = UserModel.fromJson(response['data']['user']);
    final tokens = response['data']['tokens'];

    await _storage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
    );
    await _storage.saveUserRole(user.role);

    return user;
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final response = await _authService.register(name, email, password);
    final user = UserModel.fromJson(response['data']['user']);
    final tokens = response['data']['tokens'];

    await _storage.saveTokens(
      accessToken: tokens['accessToken'],
      refreshToken: tokens['refreshToken'],
    );
    await _storage.saveUserRole(user.role);

    return user;
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      await _authService.logout(refreshToken);
    }
    await _storage.clearAll();
  }

  @override
  Future<UserModel?> getMe() async {
    try {
      return await _authService.getMe();
    } catch (_) {
      return null;
    }
  }
}
