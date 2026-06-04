import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_crowdsource_repository.dart';
import '../../domain/entities/bathroom_report.dart';
import '../../domain/entities/bathroom_suggestion.dart';
import 'crowdsource_event.dart';
import 'crowdsource_state.dart';

class CrowdsourceBloc extends Bloc<CrowdsourceEvent, CrowdsourceState> {
  final ICrowdsourceRepository repository;
  
  List<BathroomReport> _reports = [];
  List<BathroomSuggestion> _suggestions = [];

  CrowdsourceBloc({required this.repository}) : super(CrowdsourceInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<LoadSuggestionsEvent>(_onLoadSuggestions);
    on<UpdateReportStatusEvent>(_onUpdateReportStatus);
    on<UpdateSuggestionStatusEvent>(_onUpdateSuggestionStatus);
  }

  Future<void> _onLoadReports(LoadReportsEvent event, Emitter<CrowdsourceState> emit) async {
    emit(CrowdsourceLoading());
    try {
      _reports = await repository.getReports();
      emit(CrowdsourceLoaded(reports: _reports, suggestions: _suggestions));
    } catch (e) {
      emit(CrowdsourceError(e.toString()));
    }
  }

  Future<void> _onLoadSuggestions(LoadSuggestionsEvent event, Emitter<CrowdsourceState> emit) async {
    emit(CrowdsourceLoading());
    try {
      _suggestions = await repository.getSuggestions();
      emit(CrowdsourceLoaded(reports: _reports, suggestions: _suggestions));
    } catch (e) {
      emit(CrowdsourceError(e.toString()));
    }
  }

  Future<void> _onUpdateReportStatus(UpdateReportStatusEvent event, Emitter<CrowdsourceState> emit) async {
    try {
      await repository.updateReportStatus(event.id, event.status);
      add(LoadReportsEvent());
    } catch (e) {
      emit(CrowdsourceError(e.toString()));
    }
  }

  Future<void> _onUpdateSuggestionStatus(UpdateSuggestionStatusEvent event, Emitter<CrowdsourceState> emit) async {
    try {
      await repository.updateSuggestionStatus(event.id, event.status);
      add(LoadSuggestionsEvent());
    } catch (e) {
      emit(CrowdsourceError(e.toString()));
    }
  }
}
