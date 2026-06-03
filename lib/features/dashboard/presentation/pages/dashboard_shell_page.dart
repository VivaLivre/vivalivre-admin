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
    _MenuItem(icon: Icons.check_box, label: 'Moderação de Locais', path: '/admin/moderacao', badge: 12),
    _MenuItem(icon: Icons.people, label: 'Usuários', path: '/admin/usuarios'),
    _MenuItem(icon: Icons.settings, label: 'Configurações', path: '/admin/configuracoes'),
  ];

  void _navigateTo(String path) {
    if (widget.currentPath == path) return;
    // Usar pushReplacementNamed para não empilhar dezenas de páginas ao clicar no menu
    Navigator.of(context).pushReplacementNamed(path);
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacementNamed('/admin/login');
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 256, // w-64
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB)), // border-gray-200
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
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
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VivaLivre',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu de Navegação
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
                          Navigator.of(context).pop(); // Fechar drawer se for mobile
                        }
                        _navigateTo(item.path);
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.black.withOpacity(0.04),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withOpacity(0.3),
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
                              color: isActive ? Colors.white : Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isActive ? Colors.white : Colors.black87,
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

          // Rodapé da Sidebar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: const Center(
              child: Text(
                'v1.0.0 • © 2026 VivaLivre',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: isDesktop
          ? null
          : Drawer(
              child: _buildSidebar(context),
            ),
      body: Row(
        children: [
          // Sidebar Desktop
          if (isDesktop) _buildSidebar(context),

          // Conteúdo Principal
          Expanded(
            child: Column(
              children: [
                // Topbar
                Container(
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.0 : 16.0),
                  child: Row(
                    children: [
                      // Menu Mobile
                      if (!isDesktop)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),

                      // Barra de Busca
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar locais, usuários...',
                              prefixIcon: const Icon(Icons.search, color: Colors.black45),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Notificações
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
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

                      // Avatar e Menu
                      PopupMenuButton(
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Row(
                              children: const [
                                Icon(Icons.person_outline, size: 20),
                                SizedBox(width: 12),
                                Text('Meu Perfil'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'logout',
                            onTap: _handleLogout,
                            child: Row(
                              children: const [
                                Icon(Icons.logout, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text(
                                  'Sair',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                ),
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
                                  child: Text(
                                    'AD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 12),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Administrador',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Conteúdo Principal Renderizado
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
