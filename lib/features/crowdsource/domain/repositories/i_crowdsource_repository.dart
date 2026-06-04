import '../entities/bathroom_report.dart';
import '../entities/bathroom_suggestion.dart';

abstract class ICrowdsourceRepository {
  Future<List<BathroomReport>> getReports();
  Future<List<BathroomSuggestion>> getSuggestions();
  Future<void> updateReportStatus(String id, String status);
  Future<void> updateSuggestionStatus(String id, String status);
}
