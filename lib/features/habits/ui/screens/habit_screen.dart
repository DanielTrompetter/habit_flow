import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/features/auth/state/auth_provider.dart';
import 'package:habit_flow/features/habits/state/habit_provider.dart';
import 'package:habit_flow/features/habits/ui/widgets/empty_habits.dart';
import 'package:habit_flow/features/habits/ui/widgets/habit_list.dart';

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
    _ensureUserExists();
  }

  Future<void> _ensureUserExists() async {
    final user = ref.read(authProvider);
    if (user == null) {
      await ref.read(authProvider.notifier).createGuestUser();
    }
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
      ref
          .read(habitProvider.notifier)
          .addHabit(userId: user.id, name: _controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);
    final habitNotifier = ref.read(habitProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Flow'),
        actions: [
          if (habits.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  habitNotifier.progressText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: habits.isEmpty
                ? const EmptyHabits()
                : HabitList(
                    habits: habits,
                    onToggle: (id) {
                      ref
                          .read(habitProvider.notifier)
                          .toggleHabitCompletion(id);
                    },
                    onEdit: (id, newName) {
                      ref
                          .read(habitProvider.notifier)
                          .updateHabit(id, name: newName);
                    },
                    onDelete: (id) {
                      ref.read(habitProvider.notifier).deleteHabit(id);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Habit hinzufügen',
                    ),
                    onSubmitted: (_) => _addHabit(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addHabit),
              ],
            ),
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
