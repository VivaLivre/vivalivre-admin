import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../bloc/crowdsource_bloc.dart';
import '../bloc/crowdsource_event.dart';
import '../bloc/crowdsource_state.dart';
import '../../domain/entities/bathroom_report.dart';
import '../../domain/entities/bathroom_suggestion.dart';

class CrowdsourceModerationPage extends StatefulWidget {
  const CrowdsourceModerationPage({super.key});

  @override
  State<CrowdsourceModerationPage> createState() => _CrowdsourceModerationPageState();
}

class _CrowdsourceModerationPageState extends State<CrowdsourceModerationPage> {
  @override
  void initState() {
    super.initState();
    context.read<CrowdsourceBloc>().add(LoadReportsEvent());
    context.read<CrowdsourceBloc>().add(LoadSuggestionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Moderação da Comunidade',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF2563EB),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF2563EB),
            tabs: [
              Tab(text: 'Reportes'),
              Tab(text: 'Sugestões'),
            ],
          ),
        ),
        body: BlocConsumer<CrowdsourceBloc, CrowdsourceState>(
          listener: (context, state) {
            if (state is CrowdsourceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is CrowdsourceLoading && state is! CrowdsourceLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CrowdsourceLoaded) {
              return TabBarView(
                children: [
                  _buildReportsTab(state.reports),
                  _buildSuggestionsTab(state.suggestions),
                ],
              );
            }

            return const Center(child: Text('Nenhum dado encontrado.'));
          },
        ),
      ),
    );
  }

  Widget _buildReportsTab(List<BathroomReport> reports) {
    final pendingReports = reports.where((r) => r.status == 'pending').toList();
    final inProgressReports = reports.where((r) => r.status == 'in_progress').toList();

    if (pendingReports.isEmpty && inProgressReports.isEmpty) {
      return const Center(child: Text('Não há reportes ativos.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inProgressReports.isNotEmpty) ...[
          const Text('Minhas Tarefas (Em Andamento)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          const SizedBox(height: 12),
          ...inProgressReports.map((report) => _buildReportCard(report, isInProgress: true)),
          const SizedBox(height: 24),
        ],
        if (pendingReports.isNotEmpty) ...[
          const Text('Novos Reportes (Pendentes)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          ...pendingReports.map((report) => _buildReportCard(report, isInProgress: false)),
        ],
      ],
    );
  }

  Widget _buildReportCard(BathroomReport report, {required bool isInProgress}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInProgress ? const BorderSide(color: Color(0xFF2563EB), width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  report.bathroomName ?? 'Banheiro Desconhecido',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year} ${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Motivo: ${report.reason}', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (report.description != null && report.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Descrição: ${report.description}'),
              ),
            const SizedBox(height: 8),
            Text('Reportado por: ${report.userEmail ?? "Desconhecido"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    if (isInProgress) {
                      context.read<CrowdsourceBloc>().add(UpdateReportStatusEvent(report.id, 'pending'));
                    } else {
                      context.read<CrowdsourceBloc>().add(UpdateReportStatusEvent(report.id, 'rejected'));
                    }
                  },
                  child: Text(isInProgress ? 'Desistir' : 'Rejeitar'),
                ),
                const SizedBox(width: 8),
                if (!isInProgress)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                      context.read<CrowdsourceBloc>().add(UpdateReportStatusEvent(report.id, 'in_progress'));
                    },
                    child: const Text('Aceitar Tarefa', style: TextStyle(color: Colors.white)),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      context.read<CrowdsourceBloc>().add(UpdateReportStatusEvent(report.id, 'resolved'));
                    },
                    child: const Text('Marcar Resolvido', style: TextStyle(color: Colors.white)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsTab(List<BathroomSuggestion> suggestions) {
    final pendingSuggestions = suggestions.where((s) => s.status == 'pending').toList();
    final inProgressSuggestions = suggestions.where((s) => s.status == 'in_progress').toList();

    if (pendingSuggestions.isEmpty && inProgressSuggestions.isEmpty) {
      return const Center(child: Text('Não há sugestões ativas.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inProgressSuggestions.isNotEmpty) ...[
          const Text('Minhas Tarefas (Em Andamento)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          const SizedBox(height: 12),
          ...inProgressSuggestions.map((suggestion) => _buildSuggestionCard(suggestion, isInProgress: true)),
          const SizedBox(height: 24),
        ],
        if (pendingSuggestions.isNotEmpty) ...[
          const Text('Novas Sugestões (Pendentes)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          ...pendingSuggestions.map((suggestion) => _buildSuggestionCard(suggestion, isInProgress: false)),
        ],
      ],
    );
  }

  Widget _buildSuggestionCard(BathroomSuggestion suggestion, {required bool isInProgress}) {
    final updatesPretty = const JsonEncoder.withIndent('  ').convert(suggestion.suggestedUpdates);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInProgress ? const BorderSide(color: Color(0xFF2563EB), width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  suggestion.bathroomName ?? 'Banheiro Desconhecido',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${suggestion.createdAt.day.toString().padLeft(2, '0')}/${suggestion.createdAt.month.toString().padLeft(2, '0')}/${suggestion.createdAt.year} ${suggestion.createdAt.hour.toString().padLeft(2, '0')}:${suggestion.createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Alterações Propostas:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(
                updatesPretty,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text('Sugerido por: ${suggestion.userEmail ?? "Desconhecido"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    if (isInProgress) {
                      context.read<CrowdsourceBloc>().add(UpdateSuggestionStatusEvent(suggestion.id, 'pending'));
                    } else {
                      context.read<CrowdsourceBloc>().add(UpdateSuggestionStatusEvent(suggestion.id, 'rejected'));
                    }
                  },
                  child: Text(isInProgress ? 'Desistir' : 'Rejeitar'),
                ),
                const SizedBox(width: 8),
                if (!isInProgress)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () {
                      context.read<CrowdsourceBloc>().add(UpdateSuggestionStatusEvent(suggestion.id, 'in_progress'));
                    },
                    child: const Text('Aceitar Tarefa', style: TextStyle(color: Colors.white)),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: () {
                      context.read<CrowdsourceBloc>().add(UpdateSuggestionStatusEvent(suggestion.id, 'applied'));
                    },
                    child: const Text('Aplicar Alteração', style: TextStyle(color: Colors.white)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
