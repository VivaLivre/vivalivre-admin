import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bathroom_request_entity.dart';
import '../bloc/admin_moderation_bloc.dart';
import '../bloc/admin_moderation_event.dart';
import '../bloc/admin_moderation_state.dart';

class ModerationPage extends StatefulWidget {
  const ModerationPage({super.key});

  @override
  State<ModerationPage> createState() => _ModerationPageState();
}

class _ModerationPageState extends State<ModerationPage> {
  String _filtroAtual = 'todos';

  @override
  void initState() {
    super.initState();
    context.read<AdminModerationBloc>().add(LoadPendingRequests());
  }

  void _aprovar(String id) => context.read<AdminModerationBloc>().add(ApproveRequest(id));
  void _rejeitar(String id) => context.read<AdminModerationBloc>().add(RejectRequest(id));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF1F3F9) : const Color(0xFF2D3748);
    final mutedText = isDark ? const Color(0xFF8891A8) : Colors.black54;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabeçalho ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Moderação de Locais',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryText)),
                const SizedBox(height: 8),
                Text('Revise e aprove as sugestões de locais enviadas pelos usuários',
                    style: TextStyle(color: mutedText, fontSize: 16)),
              ],
            ),
          ),

          BlocBuilder<AdminModerationBloc, AdminModerationState>(
            builder: (context, state) {
              if (state is AdminModerationLoading || state is AdminModerationInitial) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(color: theme.colorScheme.primary),
                  ),
                );
              }

              if (state is AdminModerationError) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A1010) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
                      const SizedBox(height: 16),
                      const Text('Erro ao carregar os locais pendentes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                      const SizedBox(height: 8),
                      Text(state.message, style: const TextStyle(color: Color(0xFFEF4444))),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<AdminModerationBloc>().add(LoadPendingRequests()),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              if (state is AdminModerationLoaded) {
                final sugestoes = state.requests;
                final sugestoesFiltradas = sugestoes.where((s) {
                  if (_filtroAtual == 'acessiveis') return s.isAccessible;
                  return true;
                }).toList();

                return Column(
                  children: [
                    // Stat cards
                    LayoutBuilder(builder: (context, constraints) {
                      final count = constraints.maxWidth >= 1024 ? 4 : (constraints.maxWidth >= 600 ? 2 : 1);
                      return GridView.count(
                        crossAxisCount: count,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          _buildStatCard(isDark, 'Pendentes', '${sugestoes.length}', Icons.access_time, const Color(0xFF2563EB), const Color(0xFF1E2D4A), const Color(0xFFE0E7FF)),
                          _buildStatCard(isDark, 'Aprovados Hoje', '24', Icons.check, const Color(0xFF10B981), const Color(0xFF0F2A1E), const Color(0xFFD1FAE5)),
                          _buildStatCard(isDark, 'Rejeitados Hoje', '3', Icons.close, const Color(0xFFEF4444), const Color(0xFF2A1010), const Color(0xFFFEE2E2)),
                          _buildStatCard(isDark, 'Total de Locais', '1.247', Icons.location_on, isDark ? const Color(0xFFF1F3F9) : const Color(0xFF2D3748), const Color(0xFF232634), const Color(0xFFF3F4F6)),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),

                    // Filtros
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Filtrar por:', style: TextStyle(fontWeight: FontWeight.w500, color: primaryText)),
                          _buildFilterButton('Todos', 'todos', isDark),
                          _buildFilterButton('Mais Recentes', 'recentes', isDark),
                          _buildFilterButton('Somente Acessíveis', 'acessiveis', isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Grid de cards
                    if (sugestoesFiltradas.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(48),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1D27) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF232634) : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check, size: 32, color: isDark ? const Color(0xFF8891A8) : Colors.black26),
                            ),
                            const SizedBox(height: 16),
                            Text('Tudo revisado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryText)),
                            const SizedBox(height: 8),
                            Text('Não há mais sugestões pendentes para revisar no momento.', style: TextStyle(color: mutedText)),
                          ],
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisExtent: 520,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: sugestoesFiltradas.length,
                        itemBuilder: (context, index) => _buildSugestaoCard(sugestoesFiltradas[index], isDark, primaryText, mutedText),
                      ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(bool isDark, String title, String value, IconData icon, Color iconColor, Color darkBg, Color lightBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(color: isDark ? const Color(0xFF8891A8) : Colors.black54, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: iconColor, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? darkBg : lightBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value, bool isDark) {
    final isSelected = _filtroAtual == value;
    return InkWell(
      onTap: () => setState(() => _filtroAtual = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF232634) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? const Color(0xFFCDD3E0) : Colors.black87),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSugestaoCard(BathroomRequestEntity sugestao, bool isDark, Color primaryText, Color mutedText) {
    final isNovo = DateTime.now().difference(sugestao.createdAt).inHours < 24;
    final tempoStr =
        '${sugestao.createdAt.day.toString().padLeft(2, '0')}/${sugestao.createdAt.month.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          SizedBox(
            height: 192,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  sugestao.photoUrl.isNotEmpty ? sugestao.photoUrl : 'https://via.placeholder.com/400x300?text=Sem+Foto',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: isDark ? const Color(0xFF232634) : Colors.grey[300]),
                ),
                if (isNovo)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Text('NOVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sugestao.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 16, color: mutedText),
                      const SizedBox(width: 4),
                      Expanded(child: Text(sugestao.address, style: TextStyle(fontSize: 14, color: mutedText), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Comentário
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${sugestao.comment.isNotEmpty ? sugestao.comment : 'Sem comentário adicional.'}"',
                      style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? const Color(0xFFCDD3E0) : const Color(0xFF374151), fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (sugestao.isAccessible) _buildBadge('Acessível', Icons.accessible, const Color(0xFF10B981), isDark ? const Color(0xFF0F2A1E) : const Color(0xFFD1FAE5)),
                      if (sugestao.hasChangingTable) _buildBadge('Fraldário', Icons.baby_changing_station, const Color(0xFFA78BFA), isDark ? const Color(0xFF1E1530) : const Color(0xFFF3E8FF)),
                      if (sugestao.isFree) _buildBadge('Gratuito', Icons.attach_money, const Color(0xFF3B82F6), isDark ? const Color(0xFF1E2D4A) : const Color(0xFFDBEAFE)),
                    ],
                  ),

                  const Spacer(),
                  Divider(color: isDark ? const Color(0xFF2E3347) : null),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 14, color: mutedText),
                        const SizedBox(width: 4),
                        Text('Usuário Anônimo', style: TextStyle(fontSize: 12, color: mutedText)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('•', style: TextStyle(color: mutedText)),
                        ),
                        Icon(Icons.access_time, size: 14, color: mutedText),
                        const SizedBox(width: 4),
                        Text(tempoStr, style: TextStyle(fontSize: 12, color: mutedText)),
                      ],
                    ),
                  ),

                  // Botões
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejeitar(sugestao.id),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Rejeitar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _aprovar(sugestao.id),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Aprovar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
