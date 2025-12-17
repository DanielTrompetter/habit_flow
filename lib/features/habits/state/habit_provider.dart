import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/core/models/sync_status.dart';
import 'package:habit_flow/features/habits/models/habit.dart';
import 'package:habit_flow/features/settings/state/settings_provider.dart';
import 'package:habit_flow/features/settings/models/settings.dart';

class HabitNotifier extends Notifier<List<Habit>> {
  late Box<Habit> _box;

  @override
  List<Habit> build() {
    _box = Hive.box<Habit>('habits');
    return _box.values.where((h) => h.isActive).toList();
  }

  Future<void> addHabit({
    required String userId,
    required String name,
    String? description,
  }) async {
    final habit = Habit(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      description: description,
      syncStatus: SyncStatus.pending,
    );
    await _box.put(habit.id, habit);
    state = _box.values.where((h) => h.isActive).toList();
    await _syncIfAuto();
  }

  Future<void> updateHabit(
    String id, {
    String? name,
    String? description,
  }) async {
    final habit = _box.get(id);
    if (habit != null) {
      if (name != null) habit.name = name;
      if (description != null) habit.description = description;
      habit.syncStatus = SyncStatus.pending;
      habit.updatedAt = DateTime.now();
      await habit.save();
      state = _box.values.where((h) => h.isActive).toList();
      await _syncIfAuto();
    }
  }

  Future<void> deleteHabit(String id) async {
    final habit = _box.get(id);
    if (habit != null) {
      habit.isActive = false;
      habit.syncStatus = SyncStatus.pending;
      habit.updatedAt = DateTime.now();
      await habit.save();
      state = _box.values.where((h) => h.isActive).toList();
      await _syncIfAuto();
    }
  }

  Future<void> toggleHabitCompletion(String id) async {
    final habit = _box.get(id);
    if (habit != null) {
      if (habit.isCompletedToday) {
        habit.unmarkCompleted();
      } else {
        habit.markCompleted();
      }
      await habit.save();
      state = _box.values.where((h) => h.isActive).toList();
      await _syncIfAuto();
    }
  }

  Future<void> _syncIfAuto() async {
    final settings = await ref.read(settingsProvider.future);
    if (settings.syncType == SyncType.auto) {
      await syncToCloud();
    }
  }

  Future<void> syncToCloud() async {
    final pendingHabits = _box.values
        .where((h) => h.syncStatus == SyncStatus.pending)
        .toList();

    for (final habit in pendingHabits) {
      try {
        habit.syncStatus = SyncStatus.synced;
        await habit.save();
      } catch (e) {
        habit.syncStatus = SyncStatus.error;
        await habit.save();
      }
    }

    state = _box.values.where((h) => h.isActive).toList();
  }

  int get completedTodayCount => state.where((h) => h.isCompletedToday).length;

  int get totalCount => state.length;

  String get progressText => '$completedTodayCount von $totalCount erledigt';
}

final habitProvider = NotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);
