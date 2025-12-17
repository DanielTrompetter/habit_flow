import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/core/models/sync_status.dart';
import 'package:habit_flow/features/auth/models/user.dart';

class AuthNotifier extends Notifier<User?> {
  late Box<User> _box;

  @override
  User? build() {
    _box = Hive.box<User>('user');
    return _box.get('current_user');
  }

  Future<void> createGuestUser() async {
    final user = User(
      id: const Uuid().v4(),
      email: 'guest@habitflow.local',
      name: 'Gast',
      guestMode: true,
      syncStatus: SyncStatus.synced,
    );
    await _box.put('current_user', user);
    state = user;
  }

  Future<void> login({
    required String email,
    String? name,
    String? userId,
  }) async {
    final user = User(
      id: userId ?? const Uuid().v4(),
      email: email,
      name: name,
      guestMode: false,
      syncStatus: SyncStatus.synced,
    );
    await _box.put('current_user', user);
    state = user;
  }

  Future<void> logout() async {
    await _box.delete('current_user');
    state = null;
  }

  Future<void> updateProfile({String? name, String? email}) async {
    final user = state;
    if (user != null) {
      if (name != null) user.name = name;
      if (email != null) user.email = email;
      user.syncStatus = SyncStatus.pending;
      user.updatedAt = DateTime.now();
      await user.save();
      state = user;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
