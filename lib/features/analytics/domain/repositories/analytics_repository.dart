import '../../models/analytics_model.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsModel?> getAnalyticsForSubject(String subject, String topic);
  Future<List<AnalyticsModel>> getGlobalAnalytics();
  Future<void> updateAnalytics(AnalyticsModel analytics);
  Future<void> clearAllAnalytics();
}
