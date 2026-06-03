import 'package:equatable/equatable.dart';

class ActivityDay extends Equatable {
  final String day;
  final int approved;
  final int rejected;

  const ActivityDay({
    required this.day,
    required this.approved,
    required this.rejected,
  });

  int get total => approved + rejected;
  double get approvedPercent => total == 0 ? 0 : (approved / total) * 100;
  double get rejectedPercent => total == 0 ? 0 : (rejected / total) * 100;

  @override
  List<Object?> get props => [day, approved, rejected];
}

class RecentActivity extends Equatable {
  final String action;
  final String locationName;
  final String timeAgo;
  final bool isApproved;

  const RecentActivity({
    required this.action,
    required this.locationName,
    required this.timeAgo,
    required this.isApproved,
  });

  @override
  List<Object?> get props => [action, locationName, timeAgo, isApproved];
}

class DashboardData extends Equatable {
  final int totalLocations;
  final int locationsThisMonth;
  final int activeUsers;
  final int usersThisMonth;
  final int pendingReviews;
  final int approvalsToday;
  final double approvalRate;
  final List<ActivityDay> weeklyActivity;
  final List<RecentActivity> recentActivities;
  final int pendingSuggestions;

  const DashboardData({
    required this.totalLocations,
    required this.locationsThisMonth,
    required this.activeUsers,
    required this.usersThisMonth,
    required this.pendingReviews,
    required this.approvalsToday,
    required this.approvalRate,
    required this.weeklyActivity,
    required this.recentActivities,
    required this.pendingSuggestions,
  });

  @override
  List<Object?> get props => [
        totalLocations,
        locationsThisMonth,
        activeUsers,
        usersThisMonth,
        pendingReviews,
        approvalsToday,
        approvalRate,
        weeklyActivity,
        recentActivities,
        pendingSuggestions,
      ];
}
