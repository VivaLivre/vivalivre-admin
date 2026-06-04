import '../../domain/entities/bathroom_report.dart';
import '../../domain/entities/bathroom_suggestion.dart';

abstract class CrowdsourceState {}

class CrowdsourceInitial extends CrowdsourceState {}

class CrowdsourceLoading extends CrowdsourceState {}

class CrowdsourceLoaded extends CrowdsourceState {
  final List<BathroomReport> reports;
  final List<BathroomSuggestion> suggestions;

  CrowdsourceLoaded({required this.reports, required this.suggestions});
}

class CrowdsourceError extends CrowdsourceState {
  final String message;

  CrowdsourceError(this.message);
}
