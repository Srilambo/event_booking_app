import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../models/admin_stats_model.dart';
import '../models/user_model.dart';

class AdminService {
  final Dio _dio;

  AdminService(this._dio);

  Future<AdminStatsModel> getStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.adminStats);
      return AdminStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<UserModel>> getUsers({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.adminUsers,
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = (response.data['data']['users'] as List<dynamic>?)
              ?.map((u) => UserModel.fromJson(u))
              .toList() ??
          [];
      return list;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> updateUserRole(String userId, String role) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.adminUsers}/$userId/role',
        data: {'role': role},
      );
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> updateUserStatus(String userId, bool isActive) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.adminUsers}/$userId/status',
        data: {'isActive': isActive},
      );
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
