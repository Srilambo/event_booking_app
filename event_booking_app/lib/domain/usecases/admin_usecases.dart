import '../repositories/admin_repository.dart';
import '../../data/models/admin_stats_model.dart';
import '../../data/models/user_model.dart';

class GetAdminStatsUseCase {
  final AdminRepository _repository;
  GetAdminStatsUseCase(this._repository);

  Future<AdminStatsModel> call() => _repository.getStats();
}

class GetAdminUsersUseCase {
  final AdminRepository _repository;
  GetAdminUsersUseCase(this._repository);

  Future<List<UserModel>> call({int page = 1, int limit = 20}) =>
      _repository.getUsers(page: page, limit: limit);
}

class UpdateUserRoleUseCase {
  final AdminRepository _repository;
  UpdateUserRoleUseCase(this._repository);

  Future<UserModel> call(String userId, String role) =>
      _repository.updateUserRole(userId, role);
}

class UpdateUserStatusUseCase {
  final AdminRepository _repository;
  UpdateUserStatusUseCase(this._repository);

  Future<UserModel> call(String userId, bool isActive) =>
      _repository.updateUserStatus(userId, isActive);
}
