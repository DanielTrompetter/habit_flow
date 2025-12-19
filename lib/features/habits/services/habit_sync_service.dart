import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/core/services/supabase_service.dart';
import 'package:habit_flow/core/models/sync_status.dart';
import 'package:habit_flow/features/habits/models/habits/habit.dart';
import 'package:habit_flow/features/habits/models/sync_result/sync_result.dart';

class HabitSyncService {
  HabitSyncService(this._supabase);

  final SupabaseService _supabase;

  Future<void> upsertHabit(Habit habit) async {
    final json = habit.toJson();
    await _supabase.habits().upsert(json, onConflict: 'id');
  }

  Future<void> upsertHabits(List<Habit> habits) async {
    if (habits.isEmpty) return;

    final data = habits.map((h) => h.toJson()).toList();
    await _supabase.habits().upsert(data, onConflict: 'id');
  }

  Future<void> deleteHabit(String habitId) async {
    await _supabase.habits().delete().eq('id', habitId);
  }

  Future<List<Habit>> fetchHabitsForUser(String userId) async {
    final response = await _supabase
        .habits()
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      final habit = Habit.fromJson(json as Map<String, dynamic>);
      habit.syncStatus = SyncStatus.synced;
      return habit;
    }).toList();
  }

  Future<List<Habit>> fetchUpdatedHabits(String userId, DateTime since) async {
    final response = await _supabase
        .habits()
        .select()
        .eq('user_id', userId)
        .gt('updated_at', since.toUtc().toIso8601String())
        .order('updated_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      final habit = Habit.fromJson(json as Map<String, dynamic>);
      habit.syncStatus = SyncStatus.synced;
      return habit;
    }).toList();
  }

  Future<void> deleteHabits(List<String> habitIds) async {
    if (habitIds.isEmpty) return;
    await _supabase.habits().delete().inFilter('id', habitIds);
  }

  Future<SyncResult> syncHabits({
    required String userId,
    required List<Habit> localHabits,
    DateTime? lastSyncTime,
  }) async {
    try {
      final pendingHabits = localHabits
          .where((h) => h.syncStatus == SyncStatus.pending && h.isActive)
          .toList();

      final deletedHabits = localHabits
          .where((h) => h.syncStatus == SyncStatus.pending && !h.isActive)
          .toList();

      if (pendingHabits.isNotEmpty) {
        await upsertHabits(pendingHabits);
      }

      if (deletedHabits.isNotEmpty) {
        await deleteHabits(deletedHabits.map((h) => h.id).toList());
      }

      final remoteHabits = lastSyncTime != null
          ? await fetchUpdatedHabits(userId, lastSyncTime)
          : await fetchHabitsForUser(userId);

      return SyncResult(
        success: true,
        syncedCount: pendingHabits.length + deletedHabits.length,
        remoteHabits: remoteHabits,
        deletedIds: deletedHabits.map((h) => h.id).toList(),
      );
    } catch (e) {
      return SyncResult(
        success: false,
        errorMessage: e.toString(),
        syncedCount: 0,
        remoteHabits: [],
      );
    }
  }
}

final habitSyncServiceProvider = Provider<HabitSyncService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return HabitSyncService(supabase);
});
