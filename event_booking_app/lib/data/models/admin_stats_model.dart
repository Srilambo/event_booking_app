class MonthlyRevenueModel {
  final int month;
  final double revenue;
  final int bookings;

  MonthlyRevenueModel({
    required this.month,
    required this.revenue,
    required this.bookings,
  });

  factory MonthlyRevenueModel.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueModel(
      month: json['_id'] ?? 1,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      bookings: json['bookings'] ?? 0,
    );
  }
}

class AdminStatsModel {
  final int totalEvents;
  final int totalBookings;
  final double totalRevenue;
  final int totalUsers;
  final List<MonthlyRevenueModel> monthlyRevenue;

  AdminStatsModel({
    required this.totalEvents,
    required this.totalBookings,
    required this.totalRevenue,
    required this.totalUsers,
    required this.monthlyRevenue,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    final monthlyList = (stats['monthlyRevenue'] as List<dynamic>?)
            ?.map((m) => MonthlyRevenueModel.fromJson(m))
            .toList() ??
        [];

    return AdminStatsModel(
      totalEvents: stats['totalEvents'] ?? 0,
      totalBookings: stats['totalBookings'] ?? 0,
      totalRevenue: (stats['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalUsers: stats['totalUsers'] ?? 0,
      monthlyRevenue: monthlyList,
    );
  }
}
