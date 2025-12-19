import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/auth/state/auth/auth_provider.dart';
import 'package:habit_flow/features/habits/state/habit_provider.dart';
import 'package:habit_flow/features/habits/state/habit_ui_provider.dart';
import 'package:habit_flow/features/habits/ui/widgets/add_habit_row.dart';
import 'package:habit_flow/features/habits/ui/widgets/habit_app_bar_actions.dart';
import 'package:habit_flow/features/habits/ui/widgets/habit_body.dart';

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndSync();
  }

  Future<void> _initializeAndSync() async {
    final user = ref.read(authProvider);
    if (user == null) {
      await ref.read(authProvider.notifier).createGuestUser();
    } else if (!user.guestMode) {
      await ref.read(habitProvider.notifier).syncToCloud();
    }
  }

  Future<void> _syncHabits() async {
    final ui = ref.read(habitUiProvider.notifier);
    final user = ref.read(authProvider);
    if (user == null || user.guestMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Melde dich an, um zu synchronisieren')),
      );
      return;
    }

    ui.setSyncing(true);
    final success = await ref.read(habitProvider.notifier).syncToCloud();

    if (!mounted) return;
    ui.setSyncing(false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Synchronisierung erfolgreich' : 'Synchronisierung fehlgeschlagen',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addHabit() {
    if (_controller.text.trim().isEmpty) return;
    final user = ref.read(authProvider);
    if (user != null) {
      ref.read(habitProvider.notifier).addHabit(
            userId: user.id,
            name: _controller.text.trim(),
          );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);
    final habitNotifier = ref.read(habitProvider.notifier);
    final uiState = ref.watch(habitUiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Flow'),
        actions: [
          HabitAppBarActions(
            showProgress: habits.isNotEmpty,
            progressText: habitNotifier.progressText,
            isSyncing: uiState.isSyncing,
            onSync: _syncHabits,
          ),
        ],
      ),
      body: Column(
        children: [
          HabitBody(
            habits: habits,
            onToggle: (id) {
              ref.read(habitProvider.notifier).toggleHabitCompletion(id);
            },
            onEdit: (id, newName) {
              ref.read(habitProvider.notifier).updateHabit(id, name: newName);
            },
            onDelete: (id) {
              ref.read(habitProvider.notifier).deleteHabit(id);
            },
          ),
          AddHabitRow(
            controller: _controller,
            onAdd: _addHabit,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Habits'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Streaks',
          ),
        ],
      ),
    );
  }
}
