import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/analytics_model.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../data/repositories/analytics_repository_impl.dart';

class AnalyticsNotifier extends StateNotifier<AsyncValue<List<AnalyticsModel>>> {
  final AnalyticsRepository _repository;

  AnalyticsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getGlobalAnalytics();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> recordSessionMetrics(AnalyticsModel model) async {
    try {
      await _repository.updateAnalytics(model);
      await loadAnalytics();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl();
});

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AsyncValue<List<AnalyticsModel>>>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return AnalyticsNotifier(repo);
});
