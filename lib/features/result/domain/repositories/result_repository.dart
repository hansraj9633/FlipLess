import '../../models/result_model.dart';

abstract class ResultRepository {
  Future<ResultModel?> getResultForSession(String sessionId);
  Future<List<ResultModel>> getAllResults();
  Future<void> saveResult(ResultModel result);
}
