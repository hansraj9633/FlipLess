import 'package:isar/isar.dart';

part 'session_model.g.dart';

@collection
class SessionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  late String subject;
  late String topic;
  late int questionCount;
  late List<String> questionTypes;
  late double marksPerCorrect;
  late double negativeMarking;
  late int timer; // Time setting in seconds
  late DateTime createdAt;
  DateTime? completedAt;
  late String status; // 'created', 'practicing', 'completed'
}
