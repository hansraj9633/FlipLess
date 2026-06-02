import 'package:isar/isar.dart';

part 'settings_model.g.dart';

@collection
class SettingsModel {
  Id id = Isar.autoIncrement;

  late String studentName;
  late String geminiApiKey;
  late String themeMode; // 'dark', 'light', 'system'
  late bool soundEnabled;
  late bool hapticEnabled;
  late bool animationsEnabled;
  late int defaultTimer; // in minutes
}
