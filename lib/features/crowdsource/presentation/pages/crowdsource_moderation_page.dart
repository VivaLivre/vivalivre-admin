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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final appBarBg = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final scaffoldBg = isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF2E3347) : Colors.transparent;
    final titleColor = isDark ? const Color(0xFFF1F3F9) : const Color(0xFF1E293B);
    final unselectedTabColor = isDark ? const Color(0xFF8891A8) : const Color(0xFF64748B);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: appBarBg,
          elevation: 0,
          title: Text(
            'Moderação da Comunidade',
            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: unselectedTabColor,
            indicatorColor: const Color(0xFF2563EB),
            dividerColor: borderColor,
            tabs: const [
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
              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
            }
            if (state is CrowdsourceLoaded) {
              return TabBarView(
                children: [
                  _buildReportsTab(state.reports, isDark, theme),
                  _buildSuggestionsTab(state.suggestions, isDark, theme),
                ],
              );
            }
            return Center(child: Text('Nenhum dado encontrado.', style: theme.textTheme.bodyMedium));
          },
        ),
      ),
    );
  }

  Widget _buildReportsTab(List<BathroomReport> reports, bool isDark, ThemeData theme) {
    final pendingReports = reports.where((r) => r.status == 'pending').toList();
    final inProgressReports = reports.where((r) => r.status == 'in_progress').toList();

    if (pendingReports.isEmpty && inProgressReports.isEmpty) {
      return Center(child: Text('Não há reportes ativos.', style: theme.textTheme.bodyMedium));
    }

    final primaryText = isDark ? const Color(0xFFF1F3F9) : const Color(0xFF1E293B);
    final secondaryText = isDark ? const Color(0xFF8891A8) : const Color(0xFF64748B);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inProgressReports.isNotEmpty) ...[
          Text('Minhas Tarefas (Em Andamento)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
          const SizedBox(height: 12),
          ...inProgressReports.map((r) => _buildReportCard(r, isInProgress: true, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText)),
          const SizedBox(height: 24),
        ],
        if (pendingReports.isNotEmpty) ...[
          Text('Novos Reportes (Pendentes)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText)),
          const SizedBox(height: 12),
          ...pendingReports.map((r) => _buildReportCard(r, isInProgress: false, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText)),
        ],
      ],
    );
  }

  Widget _buildReportCard(BathroomReport report, {
    required bool isInProgress,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1A1D27) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInProgress
            ? const BorderSide(color: Color(0xFF2563EB), width: 2)
            : BorderSide(color: isDark ? const Color(0xFF2E3347) : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.bathroomName ?? 'Banheiro Desconhecido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${report.createdAt.day.toString().padLeft(2, '0')}/${report.createdAt.month.toString().padLeft(2, '0')}/${report.createdAt.year}',
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Motivo: ${report.reason}', style: TextStyle(fontWeight: FontWeight.w600, color: primaryText)),
            if (report.description != null && report.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Descrição: ${report.description}', style: TextStyle(color: secondaryText)),
              ),
            const SizedBox(height: 8),
            Text('Reportado por: ${report.userEmail ?? "Desconhecido"}',
                style: TextStyle(color: secondaryText, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    context.read<CrowdsourceBloc>().add(UpdateReportStatusEvent(
                          report.id, isInProgress ? 'pending' : 'rejected'));
                  },
                  child: Text(isInProgress ? 'Desistir' : 'Rejeitar'),
                ),
                const SizedBox(width: 8),
                if (!isInProgress)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () => context.read<CrowdsourceBloc>().add(UpdateReportStatusEvent(report.id, 'in_progress')),
                    child: const Text('Aceitar Tarefa', style: TextStyle(color: Colors.white)),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => context.read<CrowdsourceBloc>().add(UpdateReportStatusEvent(report.id, 'resolved')),
                    child: const Text('Marcar Resolvido', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsTab(List<BathroomSuggestion> suggestions, bool isDark, ThemeData theme) {
    final pendingSuggestions = suggestions.where((s) => s.status == 'pending').toList();
    final inProgressSuggestions = suggestions.where((s) => s.status == 'in_progress').toList();

    if (pendingSuggestions.isEmpty && inProgressSuggestions.isEmpty) {
      return Center(child: Text('Não há sugestões ativas.', style: theme.textTheme.bodyMedium));
    }

    final primaryText = isDark ? const Color(0xFFF1F3F9) : const Color(0xFF1E293B);
    final secondaryText = isDark ? const Color(0xFF8891A8) : const Color(0xFF64748B);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (inProgressSuggestions.isNotEmpty) ...[
          Text('Minhas Tarefas (Em Andamento)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
          const SizedBox(height: 12),
          ...inProgressSuggestions.map((s) => _buildSuggestionCard(s, isInProgress: true, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText)),
          const SizedBox(height: 24),
        ],
        if (pendingSuggestions.isNotEmpty) ...[
          Text('Novas Sugestões (Pendentes)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText)),
          const SizedBox(height: 12),
          ...pendingSuggestions.map((s) => _buildSuggestionCard(s, isInProgress: false, isDark: isDark, primaryText: primaryText, secondaryText: secondaryText)),
        ],
      ],
    );
  }

  Widget _buildSuggestionCard(BathroomSuggestion suggestion, {
    required bool isInProgress,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final updatesPretty = const JsonEncoder.withIndent('  ').convert(suggestion.suggestedUpdates);
    final codeBg = isDark ? const Color(0xFF0F1117) : Colors.grey[100];
    final codeText = isDark ? const Color(0xFF34D399) : Colors.black87;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1A1D27) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInProgress
            ? const BorderSide(color: Color(0xFF2563EB), width: 2)
            : BorderSide(color: isDark ? const Color(0xFF2E3347) : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    suggestion.bathroomName ?? 'Banheiro Desconhecido',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${suggestion.createdAt.day.toString().padLeft(2, '0')}/${suggestion.createdAt.month.toString().padLeft(2, '0')}/${suggestion.createdAt.year}',
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Alterações Propostas:', style: TextStyle(fontWeight: FontWeight.w600, color: primaryText)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: codeBg, borderRadius: BorderRadius.circular(8)),
              width: double.infinity,
              child: Text(
                updatesPretty,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: codeText),
              ),
            ),
            const SizedBox(height: 8),
            Text('Sugerido por: ${suggestion.userEmail ?? "Desconhecido"}',
                style: TextStyle(color: secondaryText, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    context.read<CrowdsourceBloc>().add(UpdateSuggestionStatusEvent(
                        suggestion.id, isInProgress ? 'pending' : 'rejected'));
                  },
                  child: Text(isInProgress ? 'Desistir' : 'Rejeitar'),
                ),
                const SizedBox(width: 8),
                if (!isInProgress)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () => context.read<CrowdsourceBloc>().add(UpdateSuggestionStatusEvent(suggestion.id, 'in_progress')),
                    child: const Text('Aceitar Tarefa', style: TextStyle(color: Colors.white)),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: () => context.read<CrowdsourceBloc>().add(UpdateSuggestionStatusEvent(suggestion.id, 'applied')),
                    child: const Text('Aplicar Alteração', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
