abstract class GeminiService {
  /// Initializes the Gemini model with the user's API Key.
  Future<void> initialize(String apiKey);

  /// Generates explanations or solutions for a given question input.
  Future<String> getExplanationForQuestion({
    required String questionContent,
    required String subject,
    required String topic,
  });

  /// Evaluates the student's answered questions against correct keys and retrieves an assessment.
  Future<Map<String, dynamic>> evaluatePracticeAnswers({
    required String originalQuestionsJson,
    required List<String> studentAnswers,
    required List<String> actualAnswerKeys,
  });
}
