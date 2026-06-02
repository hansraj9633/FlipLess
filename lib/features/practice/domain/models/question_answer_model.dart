import 'package:isar/isar.dart';

part 'question_answer_model.g.dart';

@collection
class QuestionAnswerModel {
  Id id = Isar.autoIncrement;

  late String sessionId;
  late int questionNumber;
  String? studentAnswer;
  String? correctKey;
  bool? isCorrect;
  String? explanation;
  late bool isMarkedForReview;
  late bool isSkipped;
}
