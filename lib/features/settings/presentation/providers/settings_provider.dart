import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/settings_model.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

class SettingsNotifier extends StateNotifier<AsyncValue<SettingsModel>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateStudentName(String name) async {
    if (state is AsyncData<SettingsModel>) {
      final updated = (state as AsyncData<SettingsModel>).value..studentName = name;
      state = AsyncValue.data(updated);
      await _repository.saveStudentName(name);
    }
  }

  Future<void> updateGeminiApiKey(String key) async {
    if (state is AsyncData<SettingsModel>) {
      final updated = (state as AsyncData<SettingsModel>).value..geminiApiKey = key;
      state = AsyncValue.data(updated);
      await _repository.saveGeminiApiKey(key);
    }
  }

  Future<void> updateThemeMode(String theme) async {
    if (state is AsyncData<SettingsModel>) {
      final updated = (state as AsyncData<SettingsModel>).value..themeMode = theme;
      state = AsyncValue.data(updated);
      await _repository.saveThemeMode(theme);
    }
  }

  Future<void> toggleSound(bool enabled) async {
    if (state is AsyncData<SettingsModel>) {
      final updated = (state as AsyncData<SettingsModel>).value..soundEnabled = enabled;
      state = AsyncValue.data(updated);
      await _repository.toggleSound(enabled);
    }
  }

  Future<void> toggleHaptics(bool enabled) async {
    if (state is AsyncData<SettingsModel>) {
      final updated = (state as AsyncData<SettingsModel>).value..hapticEnabled = enabled;
      state = AsyncValue.data(updated);
      await _repository.toggleHaptics(enabled);
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsModel>>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
