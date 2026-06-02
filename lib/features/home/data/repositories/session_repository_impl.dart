import '../../domain/models/session_model.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final List<SessionModel> _sessions = [];

  SessionRepositoryImpl() {
    _seedInitialData();
  }

  void _seedInitialData() {
    // Session 1: Fluid Mechanics (Draft 45% completed)
    _sessions.add(
      SessionModel()
        ..id = 1
        ..sessionId = 'draft_fluid_mechanics'
        ..subject = 'Fluid Mechanics'
        ..topic = 'Navier-Stokes & Viscosity'
        ..questionCount = 20
        ..questionTypes = ['MCQ', 'True/False']
        ..marksPerCorrect = 4.0
        ..negativeMarking = 1.0
        ..timer = 1200
        ..createdAt = DateTime.now().subtract(const Duration(hours: 3))
        ..status = 'practicing',
    );

    // Session 2: Modern History (Draft 12% completed)
    _sessions.add(
      SessionModel()
        ..id = 2
        ..sessionId = 'draft_modern_history'
        ..subject = 'Modern History'
        ..topic = 'The World Wars'
        ..questionCount = 50
        ..questionTypes = ['MCQ', 'Short Answers']
        ..marksPerCorrect = 2.0
        ..negativeMarking = 0.5
        ..timer = 2400
        ..createdAt = DateTime.now().subtract(const Duration(days: 1))
        ..status = 'practicing',
    );

    // Seeding some historically completed sessions as well
    _sessions.add(
      SessionModel()
        ..id = 3
        ..sessionId = 'completed_calc'
        ..subject = 'Calculus III'
        ..topic = 'Vector Fields'
        ..questionCount = 10
        ..questionTypes = ['Numerical']
        ..marksPerCorrect = 4.0
        ..negativeMarking = 1.0
        ..timer = 900
        ..createdAt = DateTime.now().subtract(const Duration(days: 2))
        ..completedAt = DateTime.now().subtract(const Duration(days: 2, hours: 2))
        ..status = 'completed',
    );

    _sessions.add(
      SessionModel()
        ..id = 4
        ..sessionId = 'completed_chem'
        ..subject = 'Organic Chem'
        ..topic = 'Alkanes'
        ..questionCount = 15
        ..questionTypes = ['MCQ']
        ..marksPerCorrect = 3.0
        ..negativeMarking = 1.0
        ..timer = 1200
        ..createdAt = DateTime.now().subtract(const Duration(days: 3))
        ..completedAt = DateTime.now().subtract(const Duration(days: 3, hours: 1))
        ..status = 'completed',
    );

    _sessions.add(
      SessionModel()
        ..id = 5
        ..sessionId = 'completed_algo'
        ..subject = 'Algorithms'
        ..topic = 'Graph Theory'
        ..questionCount = 25
        ..questionTypes = ['MCQ']
        ..marksPerCorrect = 4.0
        ..negativeMarking = 1.0
        ..timer = 1800
        ..createdAt = DateTime.now().subtract(const Duration(days: 4))
        ..completedAt = DateTime.now().subtract(const Duration(days: 4, hours: 1))
        ..status = 'completed',
    );

    _sessions.add(
      SessionModel()
        ..id = 6
        ..sessionId = 'completed_ethics'
        ..subject = 'Ethics'
        ..topic = 'Utilitarianism'
        ..questionCount = 10
        ..questionTypes = ['MCQ']
        ..marksPerCorrect = 4.0
        ..negativeMarking = 0.0
        ..timer = 600
        ..createdAt = DateTime.now().subtract(const Duration(days: 5))
        ..completedAt = DateTime.now().subtract(const Duration(days: 5, hours: 1))
        ..status = 'completed',
    );

    _sessions.add(
      SessionModel()
        ..id = 7
        ..sessionId = 'completed_micro'
        ..subject = 'Microbiology'
        ..topic = 'Cell Wall'
        ..questionCount = 13
        ..questionTypes = ['MCQ']
        ..marksPerCorrect = 4.0
        ..negativeMarking = 1.0
        ..timer = 1200
        ..createdAt = DateTime.now().subtract(const Duration(days: 6))
        ..completedAt = DateTime.now().subtract(const Duration(days: 6, hours: 1))
        ..status = 'completed',
    );
  }

  @override
  Future<SessionModel?> getSessionById(String sessionId) async {
    try {
      return _sessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SessionModel>> getAllSessions() async {
    return List<SessionModel>.from(_sessions);
  }

  @override
  Future<void> saveSession(SessionModel session) async {
    final index = _sessions.indexWhere((s) => s.sessionId == session.sessionId);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
  }

  @override
  Future<void> updateSessionStatus(String sessionId, String status) async {
    final index = _sessions.indexWhere((s) => s.sessionId == sessionId);
    if (index >= 0) {
      _sessions[index].status = status;
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.sessionId == sessionId);
  }
}
