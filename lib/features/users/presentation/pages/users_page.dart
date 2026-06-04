import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_bloc_impl.dart';
import '../../domain/entities/admin_user.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load first page on startup
    context.read<UsersBlocImpl>().add(const FetchUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<UsersBlocImpl>().add(FetchUsers(search: value));
    });
  }

  void _changePage(int page, UsersLoaded state) {
    context.read<UsersBlocImpl>().add(
          FetchUsers(page: page, limit: state.limit, search: state.search),
        );
  }

  void _showStatusMenu(BuildContext context, AdminUser user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bloc = context.read<UsersBlocImpl>();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1D27) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Alterar status de ${user.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? const Color(0xFFF1F3F9) : null,
                ),
              ),
            ),
            Divider(color: isDark ? const Color(0xFF2E3347) : null),
            _statusTile(
              icon: Icons.check_circle,
              label: 'Ativar',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.pop(context);
                bloc.add(UpdateUserStatusEvent(userId: user.id, status: 'active'));
              },
            ),
            _statusTile(
              icon: Icons.pause_circle,
              label: 'Suspender',
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.pop(context);
                bloc.add(UpdateUserStatusEvent(userId: user.id, status: 'suspended'));
              },
            ),
            _statusTile(
              icon: Icons.block,
              label: 'Banir',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(context);
                bloc.add(UpdateUserStatusEvent(userId: user.id, status: 'banned'));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  ListTile _statusTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBlocImpl, UsersState>(
      builder: (context, state) {
        // Derive stats
        int totalUsers = 0;
        int activeUsers = 0;
        int moderators = 0;
        if (state is UsersLoaded) {
          totalUsers = state.total;
          activeUsers = state.users.where((u) => u.status == 'active').length;
          moderators = state.users.where((u) => u.role == 'admin' || u.role == 'moderator').length;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabeçalho ──────────────────────────────────────────────────
              Builder(builder: (context) {
                final t = Theme.of(context);
                final dark = t.brightness == Brightness.dark;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuários',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                              color: dark ? const Color(0xFFF1F3F9) : const Color(0xFF2D3748))),
                      const SizedBox(height: 8),
                      Text('Gerencie os usuários da plataforma VivaLivre',
                          style: TextStyle(color: dark ? const Color(0xFF8891A8) : Colors.black54, fontSize: 16)),
                    ],
                  ),
                );
              }),

              // ── Estatísticas Rápidas ───────────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final crossAxisCount = constraints.maxWidth >= 768 ? 3 : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 2.5,
                    children: [
                      _buildStatCard(isDark, 'Total de Usuários',
                          state is UsersLoaded ? '$totalUsers' : '—', Icons.people, const Color(0xFF2563EB), const Color(0xFF1E2D4A), const Color(0xFFEFF6FF)),
                      _buildStatCard(isDark, 'Usuários Ativos (página)',
                          state is UsersLoaded ? '$activeUsers' : '—', Icons.check_circle, const Color(0xFF10B981), const Color(0xFF0F2A1E), const Color(0xFFF0FDF4)),
                      _buildStatCard(isDark, 'Moderadores (página)',
                          state is UsersLoaded ? '$moderators' : '—', Icons.security, const Color(0xFF8B5CF6), const Color(0xFF1E1530), const Color(0xFFF5F3FF)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── Barra de Pesquisa ──────────────────────────────────────────
              Builder(builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1D27) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: isDark ? const Color(0xFFF1F3F9) : null),
                    decoration: InputDecoration(
                      hintText: 'Buscar usuários por nome ou email...',
                      hintStyle: TextStyle(color: isDark ? const Color(0xFF8891A8) : Colors.black45),
                      prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF8891A8) : Colors.black45),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context.read<UsersBlocImpl>().add(const FetchUsers());
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Color(0xFF2563EB)),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF232634) : Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // ── Tabela / Loading / Erro ────────────────────────────────────
              Builder(builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                if (state is UsersLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    ),
                  );
                }
                if (state is UsersError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1D27) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        Text(state.message, textAlign: TextAlign.center,
                            style: TextStyle(color: isDark ? const Color(0xFF8891A8) : Colors.black54)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.read<UsersBlocImpl>().add(const FetchUsers()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is UsersLoaded) {
                  return Column(children: [
                    _buildTable(context, state, isDark),
                    const SizedBox(height: 16),
                    _buildPagination(context, state, isDark),
                  ]);
                }
                return const SizedBox();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, UsersLoaded state, bool isDark) {
    final mutedText = isDark ? const Color(0xFF8891A8) : Colors.black54;
    final primaryText = isDark ? const Color(0xFFF1F3F9) : const Color(0xFF111827);
    final headingBg = isDark ? const Color(0xFF232634) : const Color(0xFFF9FAFB);
    final cardBg = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: state.users.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: mutedText),
                    const SizedBox(height: 12),
                    Text('Nenhum usuário encontrado.', style: TextStyle(color: mutedText)),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(headingBg),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return isDark ? const Color(0xFF232634) : const Color(0xFFF9FAFB);
                  }
                  return Colors.transparent;
                }),
                dividerThickness: isDark ? 0.3 : 1,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
                columns: [
                  DataColumn(label: Text('Usuário', style: TextStyle(fontWeight: FontWeight.bold, color: mutedText))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: mutedText))),
                  DataColumn(label: Text('Membro desde', style: TextStyle(fontWeight: FontWeight.bold, color: mutedText))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: mutedText))),
                  DataColumn(label: Text('Função', style: TextStyle(fontWeight: FontWeight.bold, color: mutedText))),
                  DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold, color: mutedText))),
                ],
                rows: state.users.map((user) {
                  return DataRow(cells: [
                    DataCell(Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name.split(' ').map((n) => n.isEmpty ? '' : n[0]).take(2).join().toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(user.name, style: TextStyle(fontWeight: FontWeight.w500, color: primaryText)),
                    ])),
                    DataCell(Text(user.email, style: TextStyle(color: mutedText))),
                    DataCell(Text(_formatDate(user.createdAt), style: TextStyle(color: mutedText, fontSize: 13))),
                    DataCell(_buildStatusBadge(user.status, isDark)),
                    DataCell(_buildRoleBadge(user.role, isDark, mutedText)),
                    DataCell(IconButton(
                      icon: Icon(Icons.more_vert, color: mutedText),
                      tooltip: 'Ações',
                      onPressed: () => _showStatusMenu(context, user),
                    )),
                  ]);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildPagination(BuildContext context, UsersLoaded state, bool isDark) {
    final mutedText = isDark ? const Color(0xFF8891A8) : Colors.black45;
    final borderColor = isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Mostrando ${state.users.length} de ${state.total} usuários',
            style: TextStyle(color: mutedText, fontSize: 13)),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: isDark ? const Color(0xFFCDD3E0) : null),
              tooltip: 'Página anterior',
              onPressed: state.currentPage > 1 ? () => _changePage(state.currentPage - 1, state) : null,
            ),
            ...List.generate(state.totalPages, (i) {
              final pageNum = i + 1;
              final isActive = pageNum == state.currentPage;
              return GestureDetector(
                onTap: () => _changePage(pageNum, state),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isActive ? const Color(0xFF2563EB) : borderColor),
                  ),
                  child: Center(child: Text('$pageNum', style: TextStyle(
                    color: isActive ? Colors.white : mutedText,
                    fontWeight: FontWeight.w600, fontSize: 13,
                  ))),
                ),
              );
            }),
            IconButton(
              icon: Icon(Icons.chevron_right, color: isDark ? const Color(0xFFCDD3E0) : null),
              tooltip: 'Próxima página',
              onPressed: state.currentPage < state.totalPages ? () => _changePage(state.currentPage + 1, state) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color bgColor;
    Color fgColor;
    IconData icon;
    String label;

    switch (status) {
      case 'active':
        bgColor = isDark ? const Color(0xFF0F2A1E) : const Color(0xFFD1FAE5);
        fgColor = const Color(0xFF10B981);
        icon = Icons.check_circle;
        label = 'Ativo';
        break;
      case 'suspended':
        bgColor = isDark ? const Color(0xFF2A2010) : const Color(0xFFFEF3C7);
        fgColor = const Color(0xFFF59E0B);
        icon = Icons.pause_circle;
        label = 'Suspenso';
        break;
      case 'banned':
        bgColor = isDark ? const Color(0xFF2A1010) : const Color(0xFFFEE2E2);
        fgColor = const Color(0xFFEF4444);
        icon = Icons.block;
        label = 'Banido';
        break;
      default:
        bgColor = isDark ? const Color(0xFF232634) : const Color(0xFFF3F4F6);
        fgColor = isDark ? const Color(0xFF8891A8) : Colors.black54;
        icon = Icons.help_outline;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fgColor),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: fgColor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role, bool isDark, Color mutedText) {
    if (role == 'admin' || role == 'moderator') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1530) : const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, size: 13, color: Color(0xFFA78BFA)),
            const SizedBox(width: 5),
            Text(role == 'admin' ? 'Admin' : 'Moderador',
                style: const TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      );
    }
    return Text(role == 'user' ? 'Usuário' : role, style: TextStyle(color: mutedText));
  }

  Widget _buildStatCard(bool isDark, String title, String value, IconData icon, Color iconColor, Color darkBg, Color lightBg) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: iconColor, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            width: 48, height: 48,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
