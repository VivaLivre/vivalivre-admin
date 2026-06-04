abstract class CrowdsourceEvent {}

class LoadReportsEvent extends CrowdsourceEvent {}

class LoadSuggestionsEvent extends CrowdsourceEvent {}

class UpdateReportStatusEvent extends CrowdsourceEvent {
  final String id;
  final String status;

  UpdateReportStatusEvent(this.id, this.status);
}

class UpdateSuggestionStatusEvent extends CrowdsourceEvent {
  final String id;
  final String status;

  UpdateSuggestionStatusEvent(this.id, this.status);
}
