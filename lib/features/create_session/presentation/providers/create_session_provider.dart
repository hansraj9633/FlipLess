import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/home/domain/models/session_model.dart';
import '../../../../features/home/presentation/providers/sessions_provider.dart';
import '../../../../features/practice/presentation/providers/practice_state_provider.dart';

class CreateSessionState {
  final String subject;
  final String topic;
  final int questionCount;
  final List<String> questionTypes;
  
  // Advanced settings
  final double marksPerCorrect;
  final double negativeMarking;
  final String timerOption; // 'No Timer', '15 min', '30 min', etc.
  final bool autoSaveDraft;
  
  // UI states
  final bool isSaving;
  final bool showErrors;
  final bool isAdvancedExpanded;

  CreateSessionState({
    this.subject = '',
    this.topic = '',
    this.questionCount = 50,
    this.questionTypes = const ['MCQ'],
    this.marksPerCorrect = 1.0,
    this.negativeMarking = 0.0,
    this.timerOption = '30 min',
    this.autoSaveDraft = true,
    this.isSaving = false,
    this.showErrors = false,
    this.isAdvancedExpanded = false,
  });

  CreateSessionState copyWith({
    String? subject,
    String? topic,
    int? questionCount,
    List<String>? questionTypes,
    double? marksPerCorrect,
    double? negativeMarking,
    String? timerOption,
    bool? autoSaveDraft,
    bool? isSaving,
    bool? showErrors,
    bool? isAdvancedExpanded,
  }) {
    return CreateSessionState(
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      questionCount: questionCount ?? this.questionCount,
      questionTypes: questionTypes ?? this.questionTypes,
      marksPerCorrect: marksPerCorrect ?? this.marksPerCorrect,
      negativeMarking: negativeMarking ?? this.negativeMarking,
      timerOption: timerOption ?? this.timerOption,
      autoSaveDraft: autoSaveDraft ?? this.autoSaveDraft,
      isSaving: isSaving ?? this.isSaving,
      showErrors: showErrors ?? this.showErrors,
      isAdvancedExpanded: isAdvancedExpanded ?? this.isAdvancedExpanded,
    );
  }

  // Validations
  bool get isSubjectValid => subject.trim().isNotEmpty;
  bool get isTopicValid => topic.trim().isNotEmpty;
  bool get isQuestionTypesValid => questionTypes.isNotEmpty;
  bool get isValid => isSubjectValid && isTopicValid && isQuestionTypesValid;
}

class CreateSessionNotifier extends StateNotifier<CreateSessionState> {
  final Ref _ref;

  CreateSessionNotifier(this._ref) : super(CreateSessionState());

  void updateSubject(String value) {
    state = state.copyWith(subject: value);
  }

  void updateTopic(String value) {
    state = state.copyWith(topic: value);
  }

  void updateQuestionCount(int value) {
    if (value > 0) {
      state = state.copyWith(questionCount: value);
    }
  }

  void incrementQuestions() {
    state = state.copyWith(questionCount: state.questionCount + 1);
  }

  void decrementQuestions() {
    if (state.questionCount > 1) {
      state = state.copyWith(questionCount: state.questionCount - 1);
    }
  }

  void toggleQuestionType(String type) {
    final list = List<String>.from(state.questionTypes);
    if (list.contains(type)) {
      list.remove(type);
    } else {
      list.add(type);
    }
    state = state.copyWith(questionTypes: list);
  }

  void updateMarksPerCorrect(double value) {
    state = state.copyWith(marksPerCorrect: value);
  }

  void updateNegativeMarking(double value) {
    state = state.copyWith(negativeMarking: value);
  }

  void updateTimerOption(String value) {
    state = state.copyWith(timerOption: value);
  }

  void toggleAutoSaveDraft() {
    state = state.copyWith(autoSaveDraft: !state.autoSaveDraft);
  }

  void toggleAdvancedExpanded() {
    state = state.copyWith(isAdvancedExpanded: !state.isAdvancedExpanded);
  }

  void setShowErrors(bool value) {
    state = state.copyWith(showErrors: value);
  }

  // Convert timer option to seconds
  int _timerOptionToSeconds(String option) {
    switch (option) {
      case '15 min':
        return 15 * 60;
      case '30 min':
        return 30 * 60;
      case '45 min':
        return 45 * 60;
      case '60 min':
        return 60 * 60;
      case '90 min':
        return 90 * 60;
      case '120 min':
        return 120 * 60;
      case 'No Timer':
      default:
        return 0;
    }
  }

  int _timerOptionToMinutes(String option) {
    switch (option) {
      case '15 min':
        return 15;
      case '30 min':
        return 30;
      case '45 min':
        return 45;
      case '60 min':
        return 60;
      case '90 min':
        return 90;
      case '120 min':
        return 120;
      case 'No Timer':
      default:
        return 0;
    }
  }

  /// Create and save the session model.
  /// Returns the sessionId if successful, null otherwise.
  Future<String?> createSession() async {
    state = state.copyWith(showErrors: true);
    if (!state.isValid) {
      return null;
    }

    state = state.copyWith(isSaving: true);

    try {
      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      final timerSeconds = _timerOptionToSeconds(state.timerOption);
      
      final sessionModel = SessionModel()
        ..sessionId = sessionId
        ..subject = state.subject.trim()
        ..topic = state.topic.trim()
        ..questionCount = state.questionCount
        ..questionTypes = state.questionTypes
        ..marksPerCorrect = state.marksPerCorrect
        ..negativeMarking = state.negativeMarking
        ..timer = timerSeconds
        ..createdAt = DateTime.now()
        ..status = 'draft'; // As requested in requirements: "status = 'draft'"

      // Save locally (using repository backed/synced locally)
      await _ref.read(sessionsProvider.notifier).addSession(sessionModel);

      // Start the practice state notifier
      _ref.read(practiceStateProvider.notifier).startSession(
        sessionId: sessionId,
        subject: state.subject.trim(),
        topic: state.topic.trim(),
        totalQuestions: state.questionCount,
        durationMinutes: _timerOptionToMinutes(state.timerOption),
      );

      state = state.copyWith(isSaving: false);
      return sessionId;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return null;
    }
  }

  void reset() {
    state = CreateSessionState();
  }
}

final createSessionProvider = StateNotifierProvider<CreateSessionNotifier, CreateSessionState>((ref) {
  return CreateSessionNotifier(ref);
});
