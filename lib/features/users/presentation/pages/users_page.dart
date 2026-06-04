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
    final bloc = context.read<UsersBlocImpl>();
    showModalBottomSheet(
      context: context,
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(),
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
              const Padding(
                padding: EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuários',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gerencie os usuários da plataforma VivaLivre',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // ── Estatísticas Rápidas ───────────────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 768 ? 3 : 1;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 2.5,
                    children: [
                      _buildStatCard(
                        'Total de Usuários',
                        state is UsersLoaded ? '$totalUsers' : '—',
                        Icons.people,
                        const Color(0xFF2563EB),
                        const Color(0xFFEFF6FF),
                      ),
                      _buildStatCard(
                        'Usuários Ativos (página)',
                        state is UsersLoaded ? '$activeUsers' : '—',
                        Icons.check_circle,
                        const Color(0xFF10B981),
                        const Color(0xFFF0FDF4),
                      ),
                      _buildStatCard(
                        'Moderadores (página)',
                        state is UsersLoaded ? '$moderators' : '—',
                        Icons.security,
                        const Color(0xFF8B5CF6),
                        const Color(0xFFF5F3FF),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ── Barra de Pesquisa ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar usuários por nome ou email...',
                    prefixIcon: const Icon(Icons.search, color: Colors.black45),
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
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Tabela / Loading / Erro ────────────────────────────────────
              if (state is UsersLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  ),
                )
              else if (state is UsersError)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<UsersBlocImpl>().add(const FetchUsers()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              else if (state is UsersLoaded) ...[
                _buildTable(context, state),
                const SizedBox(height: 16),
                _buildPagination(context, state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, UsersLoaded state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: state.users.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.black26),
                    SizedBox(height: 12),
                    Text('Nenhum usuário encontrado.',
                        style: TextStyle(color: Colors.black45)),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(
                      label: Text('Usuário',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))),
                  DataColumn(
                      label: Text('Email',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))),
                  DataColumn(
                      label: Text('Membro desde',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))),
                  DataColumn(
                      label: Text('Status',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))),
                  DataColumn(
                      label: Text('Função',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))),
                  DataColumn(
                      label: Text('Ações',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))),
                ],
                rows: state.users.map((user) {
                  return DataRow(cells: [
                    // Avatar + Nome
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                user.name
                                    .split(' ')
                                    .map((n) => n.isEmpty ? '' : n[0])
                                    .take(2)
                                    .join()
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            user.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827)),
                          ),
                        ],
                      ),
                    ),

                    // Email
                    DataCell(Text(user.email,
                        style: const TextStyle(color: Colors.black54))),

                    // Data de criação
                    DataCell(Text(
                      _formatDate(user.createdAt),
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    )),

                    // Status badge
                    DataCell(_buildStatusBadge(user.status)),

                    // Função
                    DataCell(_buildRoleBadge(user.role)),

                    // Ações
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.black54),
                        tooltip: 'Ações',
                        onPressed: () => _showStatusMenu(context, user),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildPagination(BuildContext context, UsersLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mostrando ${state.users.length} de ${state.total} usuários',
          style: const TextStyle(color: Colors.black45, fontSize: 13),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Página anterior',
              onPressed: state.currentPage > 1
                  ? () => _changePage(state.currentPage - 1, state)
                  : null,
            ),
            ...List.generate(state.totalPages, (i) {
              final pageNum = i + 1;
              final isActive = pageNum == state.currentPage;
              return GestureDetector(
                onTap: () => _changePage(pageNum, state),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isActive
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE5E7EB)),
                  ),
                  child: Center(
                    child: Text(
                      '$pageNum',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Próxima página',
              onPressed: state.currentPage < state.totalPages
                  ? () => _changePage(state.currentPage + 1, state)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color fgColor;
    IconData icon;
    String label;

    switch (status) {
      case 'active':
        bgColor = const Color(0xFFD1FAE5);
        fgColor = const Color(0xFF10B981);
        icon = Icons.check_circle;
        label = 'Ativo';
        break;
      case 'suspended':
        bgColor = const Color(0xFFFEF3C7);
        fgColor = const Color(0xFFF59E0B);
        icon = Icons.pause_circle;
        label = 'Suspenso';
        break;
      case 'banned':
        bgColor = const Color(0xFFFEE2E2);
        fgColor = const Color(0xFFEF4444);
        icon = Icons.block;
        label = 'Banido';
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        fgColor = Colors.black54;
        icon = Icons.help_outline;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fgColor),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    if (role == 'admin' || role == 'moderator') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, size: 13, color: Color(0xFF7E22CE)),
            const SizedBox(width: 5),
            Text(
              role == 'admin' ? 'Admin' : 'Moderador',
              style: const TextStyle(
                  color: Color(0xFF7E22CE),
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ],
        ),
      );
    }
    return Text(
      role == 'user' ? 'Usuário' : role,
      style: const TextStyle(color: Colors.black54),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.black54, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
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
