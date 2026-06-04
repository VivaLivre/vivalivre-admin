import 'package:flutter/material.dart';

class DashboardShellPage extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const DashboardShellPage({
    super.key,
    required this.child,
    this.currentPath = '/admin/dashboard',
  });

  @override
  State<DashboardShellPage> createState() => _DashboardShellPageState();
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String path;
  final int? badge;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.path,
    this.badge,
  });
}

class _DashboardShellPageState extends State<DashboardShellPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_MenuItem> _menuItems = [
    _MenuItem(icon: Icons.dashboard, label: 'Visão Geral', path: '/admin/dashboard'),
    _MenuItem(icon: Icons.list_alt, label: 'Todos os Locais', path: '/admin/locais'),
    _MenuItem(icon: Icons.check_box, label: 'Banheiros Pendentes', path: '/admin/moderacao', badge: 12),
    _MenuItem(icon: Icons.forum, label: 'Comunidade', path: '/admin/crowdsource'),
    _MenuItem(icon: Icons.people, label: 'Usuários', path: '/admin/usuarios'),
    _MenuItem(icon: Icons.settings, label: 'Configurações', path: '/admin/configuracoes'),
  ];

  void _navigateTo(String path) {
    if (widget.currentPath == path) return;
    Navigator.of(context).pushReplacementNamed(path);
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacementNamed('/admin/login');
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme, bool isDark) {
    final sidebarBg = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB);
    final mutedText = isDark ? const Color(0xFF8891A8) : Colors.black54;
    final primaryText = isDark ? const Color(0xFFF1F3F9) : const Color(0xFF2D3748);

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          // ── Logo ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VivaLivre', style: TextStyle(fontWeight: FontWeight.bold, color: primaryText, fontSize: 16)),
                    Text('Admin', style: TextStyle(color: mutedText, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // ── Navegação ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isActive = widget.currentPath == item.path;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (Scaffold.of(context).hasDrawer) {
                          Navigator.of(context).pop();
                        }
                        _navigateTo(item.path);
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.04),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isActive ? Colors.white : mutedText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? Colors.white : primaryText,
                                ),
                              ),
                            ),
                            if (item.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.white : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item.badge}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? const Color(0xFF2563EB) : Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Rodapé ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
            child: Center(
              child: Text(
                'v1.0.0 • © 2026 VivaLivre',
                style: TextStyle(fontSize: 12, color: mutedText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final topbarBg = isDark ? const Color(0xFF1A1D27) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB);
    final bgColor = isDark ? const Color(0xFF0F1117) : const Color(0xFFF9FAFB);
    final primaryText = isDark ? const Color(0xFFF1F3F9) : const Color(0xFF2D3748);
    final mutedText = isDark ? const Color(0xFF8891A8) : Colors.black54;
    final iconColor = isDark ? const Color(0xFFCDD3E0) : Colors.black87;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      drawer: isDesktop
          ? null
          : Drawer(child: _buildSidebar(context, theme, isDark)),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, theme, isDark),

          Expanded(
            child: Column(
              children: [
                // ── Topbar ─────────────────────────────────────────────────
                Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: topbarBg,
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        IconButton(
                          icon: Icon(Icons.menu, color: iconColor),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        ),

                      const Spacer(),

                      // Notificações
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_outlined, color: iconColor),
                            onPressed: () {},
                          ),
                          Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Avatar + Menu
                      PopupMenuButton(
                        offset: const Offset(0, 50),
                        color: isDark ? const Color(0xFF232634) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: borderColor),
                        ),
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 20, color: iconColor),
                                const SizedBox(width: 12),
                                Text('Meu Perfil', style: TextStyle(color: primaryText)),
                              ],
                            ),
                          ),
                          PopupMenuDivider(color: borderColor),
                          PopupMenuItem<String>(
                            value: 'logout',
                            onTap: _handleLogout,
                            child: const Row(
                              children: [
                                Icon(Icons.logout, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Sair', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 12),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, color: primaryText, fontSize: 14)),
                                    Text('Administrador', style: TextStyle(color: mutedText, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Conteúdo ───────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
