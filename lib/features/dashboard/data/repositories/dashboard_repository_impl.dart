import 'package:dio/dio.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio dio;

  DashboardRepositoryImpl({required this.dio});

  @override
  Future<DashboardData> getOverviewData() async {
    try {
      final response = await dio.get('/api/admin/dashboard/overview');
      
      // Mapeamento real a partir do JSON da resposta
      final data = response.data;
      
      return DashboardData(
        totalLocations: data['totalLocations'] ?? 0,
        locationsThisMonth: data['locationsThisMonth'] ?? 0,
        activeUsers: data['activeUsers'] ?? 0,
        usersThisMonth: data['usersThisMonth'] ?? 0,
        pendingReviews: data['pendingReviews'] ?? 0,
        approvalsToday: data['approvalsToday'] ?? 0,
        approvalRate: (data['approvalRate'] ?? 0).toDouble(),
        pendingSuggestions: data['pendingSuggestions'] ?? 0,
        weeklyActivity: (data['weeklyActivity'] as List?)
                ?.map((item) => ActivityDay(
                      day: item['day'],
                      approved: item['approved'],
                      rejected: item['rejected'],
                    ))
                .toList() ??
            [],
        recentActivities: (data['recentActivities'] as List?)
                ?.map((item) => RecentActivity(
                      action: item['action'],
                      locationName: item['locationName'],
                      timeAgo: item['timeAgo'],
                      isApproved: item['isApproved'],
                    ))
                .toList() ??
            [],
      );
    } catch (e) {
      throw Exception('Falha ao carregar métricas: $e');
    }
  }
}
