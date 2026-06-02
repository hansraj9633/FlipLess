import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/models/session_model.dart';
import '../../../home/presentation/providers/sessions_provider.dart';

final historyProvider = Provider<AsyncValue<List<SessionModel>>>((ref) {
  final sessionState = ref.watch(sessionsProvider);

  return sessionState.when(
    data: (sessions) {
      // Filter sessions by completed status
      final completed = sessions.where((s) => s.status == 'completed').toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return AsyncValue.data(completed);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});
