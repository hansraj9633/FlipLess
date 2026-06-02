import '../../domain/models/analytics_model.dart';
import '../../domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final List<AnalyticsModel> _analytics = [];

  AnalyticsRepositoryImpl() {
    _seedInitialData();
  }

  void _seedInitialData() {
    _analytics.add(
      AnalyticsModel()
        ..id = 1
        ..subject = 'Fluid Mechanics'
        ..topic = 'Navier-Stokes'
        ..totalSessionsPracticed = 40
        ..averageAccuracy = 75.0
        ..aggregateTimeSeconds = 90000 // 25 hours
        ..totalQuestionsAttempted = 1000
        ..totalCorrect = 750
        ..lastPracticedAt = DateTime.now().subtract(const Duration(days: 1)),
    );

    _analytics.add(
      AnalyticsModel()
        ..id = 2
        ..subject = 'Modern History'
        ..topic = 'World War II'
        ..totalSessionsPracticed = 25
        ..averageAccuracy = 80.0
        ..aggregateTimeSeconds = 72000 // 20 hours
        ..totalQuestionsAttempted = 800
        ..totalCorrect = 640
        ..lastPracticedAt = DateTime.now().subtract(const Duration(hours: 4)),
    );

    _analytics.add(
      AnalyticsModel()
        ..id = 3
        ..subject = 'Other Topics'
        ..topic = 'General'
        ..totalSessionsPracticed = 60
        ..averageAccuracy = 78.4
        ..aggregateTimeSeconds = 129600 // 36 hours
        ..totalQuestionsAttempted = 1621
        ..totalCorrect = 1271
        ..lastPracticedAt = DateTime.now().subtract(const Duration(days: 2)),
    );
  }

  @override
  Future<AnalyticsModel?> getAnalyticsForSubject(String subject, String topic) async {
    try {
      return _analytics.firstWhere((a) => a.subject == subject && a.topic == topic);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AnalyticsModel>> getGlobalAnalytics() async {
    return List<AnalyticsModel>.from(_analytics);
  }

  @override
  Future<void> updateAnalytics(AnalyticsModel analytics) async {
    final index = _analytics.indexWhere((a) => a.subject == analytics.subject && a.topic == analytics.topic);
    if (index >= 0) {
      _analytics[index] = analytics;
    } else {
      _analytics.add(analytics);
    }
  }

  @override
  Future<void> clearAllAnalytics() async {
    _analytics.clear();
  }
}
