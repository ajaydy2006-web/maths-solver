import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const String _webPrefsKey = 'calcup_user_preferences';
  static const String _webResultsKey = 'calcup_session_results';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not used on Web');
    }
    if (_database != null) return _database!;
    _database = await _initDB('calcup.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        displayName TEXT,
        examGoals TEXT,
        currentLevel TEXT,
        dailyGoalMinutes INTEGER,
        hasCompletedOnboarding INTEGER,
        wrongAnswerThreshold INTEGER,
        threeWrongRestartEnabled INTEGER,
        soundEnabled INTEGER,
        hapticsEnabled INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE session_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        date TEXT,
        score INTEGER,
        correctAnswers INTEGER,
        incorrectAnswers INTEGER,
        totalQuestions INTEGER,
        durationSeconds INTEGER
      )
    ''');
  }

  Future<UserPreferences> getUserPreferences() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      final str = sp.getString(_webPrefsKey);
      if (str != null && str.isNotEmpty) {
        try {
          return UserPreferences.fromMap(jsonDecode(str));
        } catch (_) {}
      }
      return UserPreferences();
    }
    final db = await instance.database;
    final maps = await db.query('user_preferences', limit: 1);
    
    if (maps.isNotEmpty) {
      return UserPreferences.fromMap(maps.first);
    } else {
      final defaultPrefs = UserPreferences();
      await db.insert('user_preferences', defaultPrefs.toMap());
      return defaultPrefs;
    }
  }

  Future<void> updateUserPreferences(UserPreferences prefs) async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_webPrefsKey, jsonEncode(prefs.toMap()));
      return;
    }
    final db = await instance.database;
    final maps = await db.query('user_preferences', limit: 1);
    if (maps.isNotEmpty) {
      final id = maps.first['id'];
      await db.update('user_preferences', prefs.toMap(), where: 'id = ?', whereArgs: [id]);
    } else {
      await db.insert('user_preferences', prefs.toMap());
    }
  }

  Future<void> saveSessionResult(Map<String, dynamic> result) async {
    final data = Map<String, dynamic>.from(result);
    if (!data.containsKey('date') || data['date'] == null || data['date'].toString().isEmpty) {
      data['date'] = DateTime.now().toIso8601String();
    }

    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      final currentList = await getSessionResults();
      data['id'] = currentList.length + 1;
      final updated = [SessionRecord.fromMap(data), ...currentList];
      final encoded = updated.map((e) => e.toMap()).toList();
      await sp.setString(_webResultsKey, jsonEncode(encoded));
      return;
    }

    final db = await instance.database;
    await db.insert('session_results', data);
  }

  Future<List<SessionRecord>> getSessionResults() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      final str = sp.getString(_webResultsKey);
      if (str != null && str.isNotEmpty) {
        try {
          final List decoded = jsonDecode(str);
          return decoded.map((m) => SessionRecord.fromMap(Map<String, dynamic>.from(m))).toList();
        } catch (_) {}
      }
      return [];
    }
    final db = await instance.database;
    final maps = await db.query('session_results', orderBy: 'id DESC');
    return maps.map((m) => SessionRecord.fromMap(m)).toList();
  }

  Future<Map<String, dynamic>> getPerformanceStats() async {
    final sessions = await getSessionResults();

    int totalSessions = sessions.length;
    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalSeconds = 0;
    int todaySeconds = 0;
    final todayString = DateTime.now().toIso8601String().substring(0, 10);

    Map<String, Map<String, int>> categoryBreakdown = {};

    for (final s in sessions) {
      totalQuestions += s.totalQuestions;
      totalCorrect += s.correctAnswers;
      totalSeconds += s.durationSeconds;

      if (s.date.startsWith(todayString)) {
        todaySeconds += s.durationSeconds;
      }

      if (!categoryBreakdown.containsKey(s.category)) {
        categoryBreakdown[s.category] = {'total': 0, 'correct': 0};
      }
      categoryBreakdown[s.category]!['total'] =
          categoryBreakdown[s.category]!['total']! + s.totalQuestions;
      categoryBreakdown[s.category]!['correct'] =
          categoryBreakdown[s.category]!['correct']! + s.correctAnswers;
    }

    double averageAccuracy =
        totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

    return {
      'totalSessions': totalSessions,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'averageAccuracy': averageAccuracy,
      'totalPracticeMinutes': (totalSeconds / 60).round(),
      'todayPracticeMinutes': (todaySeconds / 60).round(),
      'categoryBreakdown': categoryBreakdown,
      'recentSessions': sessions.take(10).toList(),
    };
  }

  Future<void> clearSessionResults() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_webResultsKey);
      return;
    }
    final db = await instance.database;
    await db.delete('session_results');
  }

  Future<void> resetAllData() async {
    if (kIsWeb) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_webResultsKey);
      await sp.remove(_webPrefsKey);
      return;
    }
    final db = await instance.database;
    await db.delete('session_results');
    await db.delete('user_preferences');
    await db.insert('user_preferences', UserPreferences().toMap());
  }
}
