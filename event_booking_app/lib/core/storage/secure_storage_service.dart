import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Token Helpers
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await write(AppConstants.keyAccessToken, accessToken);
    await write(AppConstants.keyRefreshToken, refreshToken);
  }

  Future<String?> getAccessToken() => read(AppConstants.keyAccessToken);
  Future<String?> getRefreshToken() => read(AppConstants.keyRefreshToken);

  Future<void> saveUserRole(String role) => write(AppConstants.keyUserRole, role);
  Future<String?> getUserRole() => read(AppConstants.keyUserRole);
}
