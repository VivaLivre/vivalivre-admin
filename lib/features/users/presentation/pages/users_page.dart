import 'package:flutter/material.dart';

// Modelo Temporário para preparar o terreno para o BLoC
class Usuario {
  final int id;
  final String nome;
  final String email;
  final int locais;
  final String status;
  final String role;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.locais,
    required this.status,
    required this.role,
  });
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  // Lista que no futuro virá do estado do BLoC
  List<Usuario> _usuarios = [];

  @override
  void initState() {
    super.initState();
    // Preenchendo com dados temporários para validação visual, simulando resposta da API
    _usuarios = [
      const Usuario(id: 1, nome: 'Maria Silva', email: 'maria@email.com', locais: 12, status: 'ativo', role: 'Usuário'),
      const Usuario(id: 2, nome: 'João Costa', email: 'joao@email.com', locais: 8, status: 'ativo', role: 'Usuário'),
      const Usuario(id: 3, nome: 'Ana Paula', email: 'ana@email.com', locais: 24, status: 'ativo', role: 'Moderador'),
      const Usuario(id: 4, nome: 'Carlos Mendes', email: 'carlos@email.com', locais: 5, status: 'inativo', role: 'Usuário'),
      const Usuario(id: 5, nome: 'Fernanda Souza', email: 'fernanda@email.com', locais: 15, status: 'ativo', role: 'Usuário'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
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

          // Estatísticas Rápidas
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth >= 768 ? 3 : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 2.5,
                children: [
                  _buildStatCard('Total de Usuários', '8.432', Icons.people, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                  _buildStatCard('Usuários Ativos', '7.891', Icons.check_circle, const Color(0xFF10B981), const Color(0xFFF0FDF4)),
                  _buildStatCard('Moderadores', '23', Icons.security, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Barra de Ferramentas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar usuários por nome ou email...',
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
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtros'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tabela de Usuários
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                dataRowMinHeight: 72,
                dataRowMaxHeight: 72,
                columns: const [
                  DataColumn(label: Text('Usuário', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                  DataColumn(label: Text('Locais Enviados', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                  DataColumn(label: Text('Função', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                  DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                ],
                rows: _usuarios.map((usuario) {
                  return DataRow(
                    cells: [
                      // Usuário (Avatar + Nome)
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
                                  usuario.nome.split(' ').map((n) => n[0]).take(2).join(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(usuario.nome, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF111827))),
                          ],
                        ),
                      ),
                      
                      // Email
                      DataCell(Text(usuario.email, style: const TextStyle(color: Colors.black54))),
                      
                      // Locais Enviados
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${usuario.locais}',
                            style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      
                      // Status
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: usuario.status == 'ativo' ? const Color(0xFFD1FAE5) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                usuario.status == 'ativo' ? Icons.check_circle : Icons.cancel,
                                size: 14,
                                color: usuario.status == 'ativo' ? const Color(0xFF10B981) : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                usuario.status == 'ativo' ? 'Ativo' : 'Inativo',
                                style: TextStyle(
                                  color: usuario.status == 'ativo' ? const Color(0xFF10B981) : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Função
                      DataCell(
                        usuario.role == 'Moderador'
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.security, size: 14, color: Color(0xFF7E22CE)),
                                    const SizedBox(width: 6),
                                    Text(
                                      usuario.role,
                                      style: const TextStyle(color: Color(0xFF7E22CE), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            : Text(usuario.role, style: const TextStyle(color: Colors.black54)),
                      ),

                      // Ações
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.black54),
                          onPressed: () {
                            // Menu de ações do usuário (editar, suspender, etc)
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, Color bgColor) {
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
              Text(title, style: const TextStyle(color: Colors.black54, fontSize: 14)),
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
}
