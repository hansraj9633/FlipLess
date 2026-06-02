import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/domain/models/session_model.dart';
import '../../../home/presentation/providers/sessions_provider.dart';
import '../../domain/models/question_answer_model.dart';

class PracticeState {
  final String sessionId;
  final String subject;
  final String topic;
  final int currentQuestionIndex;
  final int totalQuestions;
  final List<QuestionAnswerModel> answers;
  final int timeRemaining; // seconds remaining for countdown / seconds elapsed for stopwatch
  final bool isStopwatch;
  final bool isSessionCompleted;

  PracticeState({
    required this.sessionId,
    required this.subject,
    required this.topic,
    this.currentQuestionIndex = 0,
    required this.totalQuestions,
    required this.answers,
    required this.timeRemaining,
    required this.isStopwatch,
    this.isSessionCompleted = false,
  });

  PracticeState copyWith({
    String? sessionId,
    String? subject,
    String? topic,
    int? currentQuestionIndex,
    int? totalQuestions,
    List<QuestionAnswerModel>? answers,
    int? timeRemaining,
    bool? isStopwatch,
    bool? isSessionCompleted,
  }) {
    return PracticeState(
      sessionId: sessionId ?? this.sessionId,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answers: answers ?? this.answers,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isStopwatch: isStopwatch ?? this.isStopwatch,
      isSessionCompleted: isSessionCompleted ?? this.isSessionCompleted,
    );
  }
}

class PracticeNotifier extends StateNotifier<PracticeState?> {
  final Ref _ref;

  PracticeNotifier(this._ref) : super(null);

  /// Helper to convert a question answer model to JSON
  Map<String, dynamic> _answerToJson(QuestionAnswerModel model) {
    return {
      'questionNumber': model.questionNumber,
      'studentAnswer': model.studentAnswer,
      'isMarkedForReview': model.isMarkedForReview,
      'isSkipped': model.isSkipped,
    };
  }

  /// Helper to convert JSON to a question answer model
  QuestionAnswerModel _answerFromJson(Map<String, dynamic> json, String sessionId) {
    return QuestionAnswerModel()
      ..sessionId = sessionId
      ..questionNumber = json['questionNumber'] as int
      ..studentAnswer = json['studentAnswer'] as String?
      ..isMarkedForReview = json['isMarkedForReview'] as bool? ?? false
      ..isSkipped = json['isSkipped'] as bool? ?? false;
  }

  /// Start a new session in practice mode
  void startSession({
    required String sessionId,
    required String subject,
    required String topic,
    required int totalQuestions,
    required int durationMinutes,
  }) async {
    final isStopwatch = durationMinutes == 0;
    
    final quizAnswers = List.generate(
      totalQuestions,
      (index) => QuestionAnswerModel()
        ..sessionId = sessionId
        ..questionNumber = index + 1
        ..isMarkedForReview = false
        ..isSkipped = false,
    );

    state = PracticeState(
      sessionId: sessionId,
      subject: subject,
      topic: topic,
      totalQuestions: totalQuestions,
      answers: quizAnswers,
      timeRemaining: isStopwatch ? 0 : durationMinutes * 60,
      isStopwatch: isStopwatch,
    );

    // Save initial state to SharedPreferences
    await _saveToPreferences();
  }

  /// Resume an existing session
  Future<bool> loadOrResumeSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Look up session details from ref
      final sessionsAsync = _ref.read(sessionsProvider);
      SessionModel? session;
      
      sessionsAsync.whenData((list) {
        try {
          session = list.firstWhere((s) => s.sessionId == sessionId);
        } catch (_) {}
      });

      if (session == null) {
        // Try getting from repository directly as a fallback
        final repo = _ref.read(sessionRepositoryProvider);
        session = await repo.getSessionById(sessionId);
      }

      if (session == null) {
        return false;
      }

      // Check for saved state in SharedPreferences
      final String? answersJson = prefs.getString('practice_answers_$sessionId');
      final int savedTimer = prefs.getInt('practice_timer_$sessionId') ?? (session!.timer);
      final int savedIndex = prefs.getInt('practice_current_index_$sessionId') ?? 0;
      final bool isStopwatch = session!.timer == 0;

      List<QuestionAnswerModel> quizAnswers;
      if (answersJson != null) {
        final List<dynamic> decoded = jsonDecode(answersJson);
        quizAnswers = decoded.map((item) => _answerFromJson(item, sessionId)).toList();
      } else {
        quizAnswers = List.generate(
          session!.questionCount,
          (index) => QuestionAnswerModel()
            ..sessionId = sessionId
            ..questionNumber = index + 1
            ..isMarkedForReview = false
            ..isSkipped = false,
        );
      }

      state = PracticeState(
        sessionId: sessionId,
        subject: session!.subject,
        topic: session!.topic,
        totalQuestions: session!.questionCount,
        answers: quizAnswers,
        currentQuestionIndex: savedIndex,
        timeRemaining: savedTimer,
        isStopwatch: isStopwatch,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Change the currently displayed question index
  void selectQuestion(int index) {
    if (state != null && index >= 0 && index < state!.totalQuestions) {
      state = state!.copyWith(currentQuestionIndex: index);
      _saveCurrentIndexToPreferences();
    }
  }

  /// Save answers locally and persist state
  Future<void> saveAnswer(String val) async {
    if (state == null) return;
    final currentList = List<QuestionAnswerModel>.from(state!.answers);
    final currentQ = currentList[state!.currentQuestionIndex];
    currentQ.studentAnswer = val;
    currentQ.isSkipped = false;
    
    state = state!.copyWith(answers: currentList);
    await _saveToPreferences();
  }

  /// Clear standard user input
  Future<void> clearAnswer() async {
    if (state == null) return;
    final currentList = List<QuestionAnswerModel>.from(state!.answers);
    final currentQ = currentList[state!.currentQuestionIndex];
    currentQ.studentAnswer = null;
    currentQ.isSkipped = false;

    state = state!.copyWith(answers: currentList);
    await _saveToPreferences();
  }

  /// Toggle review flag
  Future<void> toggleReview() async {
    if (state == null) return;
    final currentList = List<QuestionAnswerModel>.from(state!.answers);
    final currentQ = currentList[state!.currentQuestionIndex];
    currentQ.isMarkedForReview = !currentQ.isMarkedForReview;
    
    state = state!.copyWith(answers: currentList);
    await _saveToPreferences();
  }

  /// Slip / mark as skipped
  void skipQuestion() {
    if (state == null) return;
    final currentList = List<QuestionAnswerModel>.from(state!.answers);
    final currentQ = currentList[state!.currentQuestionIndex];
    currentQ.isSkipped = true;
    state = state!.copyWith(answers: currentList);
    _saveToPreferences();
    nextQuestion();
  }

  /// Go to next index
  void nextQuestion() {
    if (state != null && state!.currentQuestionIndex < state!.totalQuestions - 1) {
      state = state!.copyWith(currentQuestionIndex: state!.currentQuestionIndex + 1);
      _saveCurrentIndexToPreferences();
    }
  }

  /// Go to previous index
  void previousQuestion() {
    if (state != null && state!.currentQuestionIndex > 0) {
      state = state!.copyWith(currentQuestionIndex: state!.currentQuestionIndex - 1);
      _saveCurrentIndexToPreferences();
    }
  }

  /// Count ticks (seconds elapsed / remaining)
  void tickTimer() {
    if (state == null) return;
    if (state!.isStopwatch) {
      state = state!.copyWith(timeRemaining: state!.timeRemaining + 1);
      _saveTimerToPreferences();
    } else {
      if (state!.timeRemaining > 0) {
        state = state!.copyWith(timeRemaining: state!.timeRemaining - 1);
        _saveTimerToPreferences();
      }
    }
  }

  /// Complete practice session and transition
  Future<void> completeSession() async {
    if (state != null) {
      state = state!.copyWith(isSessionCompleted: true);
      // Update session status in session repository to 'completed'
      await _ref.read(sessionsProvider.notifier).updateStatus(state!.sessionId, 'completed');
    }
  }

  // Define helpers to persist values using SharedPreferences
  Future<void> _saveToPreferences() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final answersJson = jsonEncode(state!.answers.map((e) => _answerToJson(e)).toList());
      
      await prefs.setString('practice_answers_${state!.sessionId}', answersJson);
      await prefs.setInt('practice_timer_${state!.sessionId}', state!.timeRemaining);
      await prefs.setInt('practice_current_index_${state!.sessionId}', state!.currentQuestionIndex);
    } catch (_) {}
  }

  Future<void> _saveTimerToPreferences() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('practice_timer_${state!.sessionId}', state!.timeRemaining);
    } catch (_) {}
  }

  Future<void> _saveCurrentIndexToPreferences() async {
    if (state == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('practice_current_index_${state!.sessionId}', state!.currentQuestionIndex);
    } catch (_) {}
  }
}

final practiceStateProvider = StateNotifierProvider<PracticeNotifier, PracticeState?>((ref) {
  return PracticeNotifier(ref);
});
