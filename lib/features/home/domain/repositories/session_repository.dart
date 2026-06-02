import '../../models/session_model.dart';

abstract class SessionRepository {
  Future<SessionModel?> getSessionById(String sessionId);
  Future<List<SessionModel>> getAllSessions();
  Future<void> saveSession(SessionModel session);
  Future<void> updateSessionStatus(String sessionId, String status);
  Future<void> deleteSession(String sessionId);
}
