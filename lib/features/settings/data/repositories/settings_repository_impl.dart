import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/settings_model.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyName = 'studentName';
  static const String _keyApiKey = 'geminiApiKey';
  static const String _keyTheme = 'themeMode';
  static const String _keySound = 'soundEnabled';
  static const String _keyHaptic = 'hapticEnabled';
  static const String _keyAnimations = 'animationsEnabled';
  static const String _keyTimer = 'defaultTimer';

  @override
  Future<SettingsModel> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsModel()
      ..studentName = prefs.getString(_keyName) ?? 'Hans'
      ..geminiApiKey = prefs.getString(_keyApiKey) ?? ''
      ..themeMode = prefs.getString(_keyTheme) ?? 'dark'
      ..soundEnabled = prefs.getBool(_keySound) ?? true
      ..hapticEnabled = prefs.getBool(_keyHaptic) ?? true
      ..animationsEnabled = prefs.getBool(_keyAnimations) ?? true
      ..defaultTimer = prefs.getInt(_keyTimer) ?? 15;
  }

  @override
  Future<void> updateSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, settings.studentName);
    await prefs.setString(_keyApiKey, settings.geminiApiKey);
    await prefs.setString(_keyTheme, settings.themeMode);
    await prefs.setBool(_keySound, settings.soundEnabled);
    await prefs.setBool(_keyHaptic, settings.hapticEnabled);
    await prefs.setBool(_keyAnimations, settings.animationsEnabled);
    await prefs.setInt(_keyTimer, settings.defaultTimer);
  }

  @override
  Future<void> saveStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  @override
  Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, apiKey);
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode);
  }

  @override
  Future<void> toggleSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, enabled);
  }

  @override
  Future<void> toggleHaptics(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptic, enabled);
  }
}
