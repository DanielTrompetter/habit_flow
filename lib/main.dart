import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/hive_registrar.g.dart';
import 'package:habit_flow/features/habits/models/habit.dart';
import 'package:habit_flow/features/auth/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<User>('user');

  runApp(const App());
}
