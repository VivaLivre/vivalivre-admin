import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Estado local simulando configurações carregadas do BLoC
  bool _notifNovasSugestoes = true;
  bool _notifNovosUsuarios = false;
  bool _notifRelatorios = true;
  String _tema = 'Claro';
  String _densidade = 'Confortável';
  String _idioma = 'Português (Brasil)';
  String _fusoHorario = 'América/São Paulo (BRT)';

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
                  'Configurações',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gerencie as configurações da plataforma',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ),

          // Seção Notificações
          _buildSettingsSection(
            title: 'Notificações',
            subtitle: 'Configure como você recebe notificações',
            icon: Icons.notifications,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            children: [
              _buildSwitchItem(
                title: 'Novas sugestões de locais',
                subtitle: 'Receber notificação quando novos locais forem sugeridos',
                value: _notifNovasSugestoes,
                onChanged: (val) => setState(() => _notifNovasSugestoes = val),
              ),
              _buildSwitchItem(
                title: 'Novos usuários cadastrados',
                subtitle: 'Notificar quando novos usuários se registrarem',
                value: _notifNovosUsuarios,
                onChanged: (val) => setState(() => _notifNovosUsuarios = val),
              ),
              _buildSwitchItem(
                title: 'Relatórios semanais',
                subtitle: 'Receber resumo semanal de atividades',
                value: _notifRelatorios,
                onChanged: (val) => setState(() => _notifRelatorios = val),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Seção Segurança
          _buildSettingsSection(
            title: 'Segurança',
            subtitle: 'Configurações de segurança e acesso',
            icon: Icons.lock,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFF0FDF4),
            children: [
              _buildActionItem('Alterar senha', 'Atualizar sua senha de acesso'),
              _buildActionItem('Autenticação de dois fatores', 'Adicionar camada extra de segurança'),
              _buildActionItem('Sessões ativas', 'Gerenciar dispositivos conectados'),
            ],
          ),
          const SizedBox(height: 24),

          // Seção Aparência
          _buildSettingsSection(
            title: 'Aparência',
            subtitle: 'Personalize a aparência do painel',
            icon: Icons.palette,
            iconColor: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFFF5F3FF),
            children: [
              _buildDropdownItem(
                title: 'Tema',
                value: _tema,
                items: ['Claro', 'Escuro', 'Automático'],
                onChanged: (val) => setState(() => _tema = val!),
              ),
              _buildDropdownItem(
                title: 'Densidade da interface',
                value: _densidade,
                items: ['Confortável', 'Compacta', 'Espaçosa'],
                onChanged: (val) => setState(() => _densidade = val!),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Seção Regionalização
          _buildSettingsSection(
            title: 'Regionalização',
            subtitle: 'Idioma e fuso horário',
            icon: Icons.language,
            iconColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
            children: [
              _buildDropdownItem(
                title: 'Idioma',
                value: _idioma,
                items: ['Português (Brasil)', 'English', 'Español'],
                onChanged: (val) => setState(() => _idioma = val!),
              ),
              _buildDropdownItem(
                title: 'Fuso horário',
                value: _fusoHorario,
                items: ['América/São Paulo (BRT)', 'América/New York (EST)', 'Europa/Lisboa (WET)'],
                onChanged: (val) => setState(() => _fusoHorario = val!),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Seção Sistema
          _buildSettingsSection(
            title: 'Sistema',
            subtitle: 'Configurações avançadas do sistema',
            icon: Icons.storage,
            iconColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
            children: [
              _buildActionItem('Backup de dados', 'Fazer backup do banco de dados'),
              _buildActionItem('Logs do sistema', 'Visualizar logs de atividades'),
              _buildActionItem('Limpar cache', 'Remover arquivos temporários do sistema', isDestructive: true),
            ],
          ),
          const SizedBox(height: 32),

          // Botões de Ação Final
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // context.read<SettingsBloc>().add(SaveSettingsEvent(...));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configurações salvas com sucesso!'), backgroundColor: Color(0xFF10B981)),
                  );
                },
                icon: const Icon(Icons.save, size: 20),
                label: const Text('Salvar Alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children.expand((widget) => [widget, const SizedBox(height: 16)]).toList()..removeLast(),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, {bool isDestructive = false}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFEF2F2) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive ? Colors.red.withValues(alpha: 0.8) : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDestructive ? Colors.red : Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
