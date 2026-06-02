import '../../domain/models/result_model.dart';
import '../../domain/repositories/result_repository.dart';

class ResultRepositoryImpl implements ResultRepository {
  final List<ResultModel> _results = [];

  ResultRepositoryImpl() {
    _seedResults();
  }

  void _seedResults() {
    _results.add(
      ResultModel()
        ..id = 1
        ..sessionId = 'completed_calc'
        ..totalQuestions = 10
        ..correctAnswersCount = 9
        ..incorrectAnswersCount = 1
        ..skippedAnswersCount = 0
        ..totalMarksScored = 36.0
        ..accuracyPercentage = 92.0
        ..timeSpentSeconds = 600
        ..feedbackOverview = 'Excellent grasp of Vector Fields.',
    );

    _results.add(
      ResultModel()
        ..id = 2
        ..sessionId = 'completed_chem'
        ..totalQuestions = 15
        ..correctAnswersCount = 11
        ..incorrectAnswersCount = 4
        ..skippedAnswersCount = 0
        ..totalMarksScored = 33.0
        ..accuracyPercentage = 74.0
        ..timeSpentSeconds = 900
        ..feedbackOverview = 'Good, but focus on Alkanes properties.',
    );

    _results.add(
      ResultModel()
        ..id = 3
        ..sessionId = 'completed_algo'
        ..totalQuestions = 25
        ..correctAnswersCount = 22
        ..incorrectAnswersCount = 3
        ..skippedAnswersCount = 0
        ..totalMarksScored = 88.0
        ..accuracyPercentage = 88.0
        ..timeSpentSeconds = 1800
        ..feedbackOverview = 'Strong results in Graph Theory!',
    );

    _results.add(
      ResultModel()
        ..id = 4
        ..sessionId = 'completed_ethics'
        ..totalQuestions = 10
        ..correctAnswersCount = 10
        ..incorrectAnswersCount = 0
        ..skippedAnswersCount = 0
        ..totalMarksScored = 40.0
        ..accuracyPercentage = 100.0
        ..timeSpentSeconds = 450
        ..feedbackOverview = 'Perfect understanding of Utilitarianism philosophies.',
    );

    _results.add(
      ResultModel()
        ..id = 5
        ..sessionId = 'completed_micro'
        ..totalQuestions = 13
        ..correctAnswersCount = 8
        ..incorrectAnswersCount = 5
        ..skippedAnswersCount = 0
        ..totalMarksScored = 24.0
        ..accuracyPercentage = 62.0
        ..timeSpentSeconds = 1100
        ..feedbackOverview = 'Cell Wall structures need thorough revision.',
    );
  }

  @override
  Future<ResultModel?> getResultForSession(String sessionId) async {
    try {
      return _results.firstWhere((r) => r.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ResultModel>> getAllResults() async {
    return List<ResultModel>.from(_results);
  }

  @override
  Future<void> saveResult(ResultModel result) async {
    final index = _results.indexWhere((r) => r.sessionId == result.sessionId);
    if (index >= 0) {
      _results[index] = result;
    } else {
      _results.add(result);
    }
  }
}
