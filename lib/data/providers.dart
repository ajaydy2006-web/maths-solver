import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_helper.dart';
import 'models.dart';

final userPreferencesProvider = FutureProvider<UserPreferences>((ref) async {
  return await DatabaseHelper.instance.getUserPreferences();
});

class UserPreferencesNotifier extends StateNotifier<AsyncValue<UserPreferences>> {
  UserPreferencesNotifier() : super(const AsyncValue.loading()) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await DatabaseHelper.instance.getUserPreferences();
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePrefs(UserPreferences newPrefs) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseHelper.instance.updateUserPreferences(newPrefs);
      state = AsyncValue.data(newPrefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reload() async {
    await _loadPrefs();
  }
}

final userPreferencesNotifierProvider =
    StateNotifierProvider<UserPreferencesNotifier, AsyncValue<UserPreferences>>((ref) {
  return UserPreferencesNotifier();
});

class StatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  StatsNotifier() : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await DatabaseHelper.instance.getPerformanceStats();
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearHistory() async {
    try {
      await DatabaseHelper.instance.clearSessionResults();
      await loadStats();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetAll() async {
    try {
      await DatabaseHelper.instance.resetAllData();
      await loadStats();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final statsNotifierProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return StatsNotifier();
});
