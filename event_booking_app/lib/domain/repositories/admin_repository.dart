import '../../data/models/admin_stats_model.dart';
import '../../data/models/user_model.dart';

abstract class AdminRepository {
  Future<AdminStatsModel> getStats();
  Future<List<UserModel>> getUsers({int page = 1, int limit = 20});
  Future<UserModel> updateUserRole(String userId, String role);
  Future<UserModel> updateUserStatus(String userId, bool isActive);
}
