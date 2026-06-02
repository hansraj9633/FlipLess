import 'package:isar/isar.dart';

part 'analytics_model.g.dart';

@collection
class AnalyticsModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String subject;

  late String topic;
  late int totalSessionsPracticed;
  late double averageAccuracy;
  late int aggregateTimeSeconds;
  late int totalQuestionsAttempted;
  late int totalCorrect;
  late DateTime lastPracticedAt;
}
