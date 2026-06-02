import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/session_model.dart';
import '../../domain/repositories/session_repository.dart';
import '../../data/repositories/session_repository_impl.dart';

class SessionsNotifier extends StateNotifier<AsyncValue<List<SessionModel>>> {
  final SessionRepository _repository;

  SessionsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getAllSessions();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSession(SessionModel session) async {
    try {
      await _repository.saveSession(session);
      await loadSessions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateStatus(String sessionId, String status) async {
    try {
      await _repository.updateSessionStatus(sessionId, status);
      await loadSessions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// We'll expose a real default repository provider.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl();
});

final sessionsProvider = StateNotifierProvider<SessionsNotifier, AsyncValue<List<SessionModel>>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return SessionsNotifier(repo);
});
