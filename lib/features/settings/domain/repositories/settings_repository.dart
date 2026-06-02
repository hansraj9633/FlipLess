import '../../models/settings_model.dart';

abstract class SettingsRepository {
  Future<SettingsModel> getSettings();
  Future<void> updateSettings(SettingsModel settings);
  Future<void> saveStudentName(String name);
  Future<void> saveGeminiApiKey(String apiKey);
  Future<void> saveThemeMode(String mode);
  Future<void> toggleSound(bool enabled);
  Future<void> toggleHaptics(bool enabled);
}
