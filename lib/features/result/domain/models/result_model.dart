import 'package:isar/isar.dart';

part 'result_model.g.dart';

@collection
class ResultModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  late int totalQuestions;
  late int correctAnswersCount;
  late int incorrectAnswersCount;
  late int skippedAnswersCount;
  late double totalMarksScored;
  late double accuracyPercentage;
  late int timeSpentSeconds;
  String? feedbackOverview;
}
