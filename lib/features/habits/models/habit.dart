import 'package:hive_ce/hive.dart';
import 'package:habit_flow/core/models/sync_status.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.isActive = true,
    this.completedDates = const [],
    this.currentStreak = 0,
    this.syncStatus = SyncStatus.synced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String? description;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  List<DateTime> completedDates;

  @HiveField(6)
  int currentStreak;

  @HiveField(7)
  SyncStatus syncStatus;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any(
      (d) =>
          d.year == today.year && d.month == today.month && d.day == today.day,
    );
  }

  void markCompleted() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (!isCompletedToday) {
      completedDates = [...completedDates, todayOnly];
      syncStatus = SyncStatus.pending;
      updatedAt = DateTime.now();
    }
  }

  void unmarkCompleted() {
    final today = DateTime.now();
    completedDates = completedDates
        .where(
          (d) =>
              !(d.year == today.year &&
                  d.month == today.month &&
                  d.day == today.day),
        )
        .toList();
    syncStatus = SyncStatus.pending;
    updatedAt = DateTime.now();
  }
}
