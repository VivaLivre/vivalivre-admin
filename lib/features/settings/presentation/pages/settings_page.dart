import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifNovasSugestoes = true;
  bool _notifNovosUsuarios = false;
  bool _notifRelatorios = true;
  String _densidade = 'Confortável';
  String _idioma = 'Português (Brasil)';
  String _fusoHorario = 'América/São Paulo (BRT)';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final currentThemeLabel = ThemeBloc.toLabel(themeState.mode);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cabeçalho ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configurações',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gerencie as configurações da plataforma',
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // ── Notificações ──────────────────────────────────────────────
              _buildSection(
                theme: theme,
                isDark: isDark,
                title: 'Notificações',
                subtitle: 'Configure como você recebe notificações',
                icon: Icons.notifications,
                iconColor: const Color(0xFF2563EB),
                iconBg: isDark ? const Color(0xFF1E2D4A) : const Color(0xFFEFF6FF),
                children: [
                  _buildSwitchItem(
                    theme: theme,
                    isDark: isDark,
                    title: 'Novas sugestões de locais',
                    subtitle: 'Receber notificação quando novos locais forem sugeridos',
                    value: _notifNovasSugestoes,
                    onChanged: (val) => setState(() => _notifNovasSugestoes = val),
                  ),
                  _buildSwitchItem(
                    theme: theme,
                    isDark: isDark,
                    title: 'Novos usuários cadastrados',
                    subtitle: 'Notificar quando novos usuários se registrarem',
                    value: _notifNovosUsuarios,
                    onChanged: (val) => setState(() => _notifNovosUsuarios = val),
                  ),
                  _buildSwitchItem(
                    theme: theme,
                    isDark: isDark,
                    title: 'Relatórios semanais',
                    subtitle: 'Receber resumo semanal de atividades',
                    value: _notifRelatorios,
                    onChanged: (val) => setState(() => _notifRelatorios = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Segurança ─────────────────────────────────────────────────
              _buildSection(
                theme: theme,
                isDark: isDark,
                title: 'Segurança',
                subtitle: 'Configurações de segurança e acesso',
                icon: Icons.lock,
                iconColor: const Color(0xFF10B981),
                iconBg: isDark ? const Color(0xFF0F2A1E) : const Color(0xFFF0FDF4),
                children: [
                  _buildActionItem(theme: theme, isDark: isDark, title: 'Alterar senha', subtitle: 'Atualizar sua senha de acesso'),
                  _buildActionItem(theme: theme, isDark: isDark, title: 'Autenticação de dois fatores', subtitle: 'Adicionar camada extra de segurança'),
                  _buildActionItem(theme: theme, isDark: isDark, title: 'Sessões ativas', subtitle: 'Gerenciar dispositivos conectados'),
                ],
              ),
              const SizedBox(height: 24),

              // ── Aparência (Tema) ──────────────────────────────────────────
              _buildSection(
                theme: theme,
                isDark: isDark,
                title: 'Aparência',
                subtitle: 'Personalize a aparência do painel',
                icon: Icons.palette,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: isDark ? const Color(0xFF1E1530) : const Color(0xFFF5F3FF),
                children: [
                  // Seletor de tema visual em cards
                  _buildThemeSelector(context, theme, isDark, currentThemeLabel),
                  const SizedBox(height: 8),
                  _buildDropdownItem(
                    theme: theme,
                    isDark: isDark,
                    title: 'Densidade da interface',
                    value: _densidade,
                    items: const ['Confortável', 'Compacta', 'Espaçosa'],
                    onChanged: (val) => setState(() => _densidade = val!),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Regionalização ────────────────────────────────────────────
              _buildSection(
                theme: theme,
                isDark: isDark,
                title: 'Regionalização',
                subtitle: 'Idioma e fuso horário',
                icon: Icons.language,
                iconColor: const Color(0xFFF59E0B),
                iconBg: isDark ? const Color(0xFF2A2010) : const Color(0xFFFFFBEB),
                children: [
                  _buildDropdownItem(
                    theme: theme,
                    isDark: isDark,
                    title: 'Idioma',
                    value: _idioma,
                    items: const ['Português (Brasil)', 'English', 'Español'],
                    onChanged: (val) => setState(() => _idioma = val!),
                  ),
                  _buildDropdownItem(
                    theme: theme,
                    isDark: isDark,
                    title: 'Fuso horário',
                    value: _fusoHorario,
                    items: const ['América/São Paulo (BRT)', 'América/New York (EST)', 'Europa/Lisboa (WET)'],
                    onChanged: (val) => setState(() => _fusoHorario = val!),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Sistema ───────────────────────────────────────────────────
              _buildSection(
                theme: theme,
                isDark: isDark,
                title: 'Sistema',
                subtitle: 'Configurações avançadas do sistema',
                icon: Icons.storage,
                iconColor: const Color(0xFFEF4444),
                iconBg: isDark ? const Color(0xFF2A1010) : const Color(0xFFFEF2F2),
                children: [
                  _buildActionItem(theme: theme, isDark: isDark, title: 'Backup de dados', subtitle: 'Fazer backup do banco de dados'),
                  _buildActionItem(theme: theme, isDark: isDark, title: 'Logs do sistema', subtitle: 'Visualizar logs de atividades'),
                  _buildActionItem(theme: theme, isDark: isDark, title: 'Limpar cache', subtitle: 'Remover arquivos temporários do sistema', isDestructive: true),
                ],
              ),
              const SizedBox(height: 32),

              // ── Botões de Ação ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textTheme.bodyLarge?.color,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      side: BorderSide(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configurações salvas com sucesso!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save, size: 20),
                    label: const Text('Salvar Alterações'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  /// Seletor visual de tema com 3 cards: Claro, Escuro, Automático
  Widget _buildThemeSelector(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String currentLabel,
  ) {
    final options = [
      _ThemeOption(label: 'Claro', icon: Icons.light_mode_rounded, mode: ThemeMode.light),
      _ThemeOption(label: 'Escuro', icon: Icons.dark_mode_rounded, mode: ThemeMode.dark),
      _ThemeOption(label: 'Automático', icon: Icons.brightness_auto_rounded, mode: ThemeMode.system),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232634) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((opt) {
              final isSelected = opt.label == currentLabel;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: opt != options.last ? 12 : 0),
                  child: GestureDetector(
                    onTap: () {
                      context.read<ThemeBloc>().add(ThemeChanged(opt.mode));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF1E2D4A) : const Color(0xFFEFF6FF))
                            : (isDark ? const Color(0xFF1A1D27) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : (isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.3 : 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            opt.icon,
                            size: 24,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : (isDark ? const Color(0xFF8891A8) : Colors.black45),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            opt.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : (isDark ? const Color(0xFF8891A8) : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFE5E7EB)),
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
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children.expand((w) => [w, const SizedBox(height: 16)]).toList()..removeLast(),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required ThemeData theme,
    required bool isDark,
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
          color: isDark ? const Color(0xFF232634) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String subtitle,
    bool isDestructive = false,
  }) {
    final bg = isDestructive
        ? (isDark ? const Color(0xFF2A1010) : const Color(0xFFFEF2F2))
        : (isDark ? const Color(0xFF232634) : const Color(0xFFF9FAFB));

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
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
                      color: isDestructive ? const Color(0xFFEF4444) : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive
                          ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                          : theme.textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive ? const Color(0xFFEF4444) : theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232634) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1D27) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF2E3347) : const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF232634) : Colors.white,
                iconEnabledColor: theme.textTheme.bodySmall?.color,
                icon: const Icon(Icons.keyboard_arrow_down),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 15),
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

class _ThemeOption {
  final String label;
  final IconData icon;
  final ThemeMode mode;
  const _ThemeOption({required this.label, required this.icon, required this.mode});
}
