import '../../domain/repositories/admin_repository.dart';
import '../services/admin_service.dart';
import '../models/admin_stats_model.dart';
import '../models/user_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminService _adminService;

  AdminRepositoryImpl(this._adminService);

  @override
  Future<AdminStatsModel> getStats() => _adminService.getStats();

  @override
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20}) =>
      _adminService.getUsers(page: page, limit: limit);

  @override
  Future<UserModel> updateUserRole(String userId, String role) =>
      _adminService.updateUserRole(userId, role);

  @override
  Future<UserModel> updateUserStatus(String userId, bool isActive) =>
      _adminService.updateUserStatus(userId, isActive);
}
