import 'dart:io';

abstract class PdfExportService {
  /// Exports a detailed evaluation result of a practice session to a PDF File.
  Future<File> exportSessionResult({
    required String sessionId,
    required Map<String, dynamic> sessionDetails,
    required List<Map<String, dynamic>> questionsAnswers,
  });
}
