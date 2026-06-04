import 'package:flutter/material.dart';

/// AppThemes — paleta de design do VivaLivre Admin
/// Azul primário: #2563EB (mantido nos dois temas)
abstract class AppThemes {
  // ── Shared Brand Colors ──────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1E40AF);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueGlow = Color(0xFF60A5FA);

  // ── TEMA CLARO ────────────────────────────────────────────────────────────
  // Backgrounds
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderFaint = Color(0xFFF0F0F0);

  // Text
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF374151);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightTextDisabled = Color(0xFF9CA3AF);

  // Sidebar
  static const Color lightSidebar = Color(0xFFFFFFFF);
  static const Color lightTopbar = Color(0xFFFFFFFF);

  // ── TEMA ESCURO ───────────────────────────────────────────────────────────
  // Backgrounds (layered depths, nunca puro #000)
  static const Color darkBg = Color(0xFF0F1117);        // nível 0 — fundo geral
  static const Color darkSurface = Color(0xFF1A1D27);   // nível 1 — cards / sidebar
  static const Color darkSurfaceRaised = Color(0xFF232634); // nível 2 — inputs, rows
  static const Color darkSurfaceHighest = Color(0xFF2C3047); // nível 3 — hover, badges
  
  // Borders
  static const Color darkBorder = Color(0xFF2E3347);
  static const Color darkBorderFaint = Color(0xFF1E2235);

  // Text
  static const Color darkTextPrimary = Color(0xFFF1F3F9);
  static const Color darkTextSecondary = Color(0xFFCDD3E0);
  static const Color darkTextMuted = Color(0xFF8891A8);
  static const Color darkTextDisabled = Color(0xFF5A6478);

  // Blue accents (slightly brighter for dark bg readability)
  static const Color darkPrimaryBlue = Color(0xFF3B82F6);    // base
  static const Color darkPrimaryBlueHover = Color(0xFF60A5FA); // hover
  static const Color darkPrimaryBlueBg = Color(0xFF1E2D4A);  // soft background
  static const Color darkPrimaryBlueBorder = Color(0xFF2563EB); // border

  // Status colors (dark-adjusted)
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkSuccessBg = Color(0xFF0F2A1E);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkWarningBg = Color(0xFF2A2010);
  static const Color darkDanger = Color(0xFFF87171);
  static const Color darkDangerBg = Color(0xFF2A1010);
  static const Color darkPurple = Color(0xFFA78BFA);
  static const Color darkPurpleBg = Color(0xFF1E1530);

  // ── ThemeData: CLARO ──────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          surface: lightSurface,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: lightBg,
        cardColor: lightSurface,
        dividerColor: lightBorder,
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? primaryBlue : lightTextDisabled),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? primaryBlue.withValues(alpha: 0.3)
                  : lightBorderFaint),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          hintStyle: const TextStyle(color: lightTextDisabled),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: lightTextSecondary),
          bodyLarge: TextStyle(color: lightTextPrimary),
          bodyMedium: TextStyle(color: lightTextSecondary),
          bodySmall: TextStyle(color: lightTextMuted),
          labelLarge: TextStyle(color: lightTextMuted, fontSize: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: lightSurface,
          surfaceTintColor: Colors.transparent,
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(lightSurface),
          ),
        ),
      );

  // ── ThemeData: ESCURO ─────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkPrimaryBlue,
          primary: darkPrimaryBlue,
          surface: darkSurface,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: darkBg,
        cardColor: darkSurface,
        dividerColor: darkBorder,
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected) ? darkPrimaryBlueHover : darkTextDisabled),
          trackColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? darkPrimaryBlue.withValues(alpha: 0.4)
                  : darkSurfaceHighest),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurfaceRaised,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: darkPrimaryBlue, width: 2),
          ),
          hintStyle: const TextStyle(color: darkTextDisabled),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: darkTextSecondary),
          bodyLarge: TextStyle(color: darkTextPrimary),
          bodyMedium: TextStyle(color: darkTextSecondary),
          bodySmall: TextStyle(color: darkTextMuted),
          labelLarge: TextStyle(color: darkTextMuted, fontSize: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: darkSurfaceRaised,
          surfaceTintColor: Colors.transparent,
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(darkSurfaceRaised),
          ),
        ),
      );
}
