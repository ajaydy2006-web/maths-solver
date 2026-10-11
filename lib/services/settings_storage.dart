import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const String _keyPrefix = 'calcup_settings_';
  static const String _presetsKey = 'calcup_custom_presets';

  /// Save last used configuration for a specific category or operation
  static Future<void> saveSettings(String categoryOrKey, Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$categoryOrKey', jsonEncode(settings));
    } catch (_) {}
  }

  /// Load last used configuration for a specific category or operation
  static Future<Map<String, dynamic>?> loadSettings(String categoryOrKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('$_keyPrefix$categoryOrKey');
      if (data != null && data.isNotEmpty) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Save a named custom preset
  static Future<void> saveCustomPreset(String name, Map<String, dynamic> config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentList = await loadCustomPresets();
      currentList[name] = config;
      await prefs.setString(_presetsKey, jsonEncode(currentList));
    } catch (_) {}
  }

  /// Load all saved custom presets
  static Future<Map<String, dynamic>> loadCustomPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_presetsKey);
      if (data != null && data.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(data));
      }
    } catch (_) {}
    return {};
  }
}
