import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeChanged extends ThemeEvent {
  final ThemeMode mode;
  const ThemeChanged(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ThemeLoaded extends ThemeEvent {
  const ThemeLoaded();
}

// ── State ─────────────────────────────────────────────────────────────────────

class ThemeState extends Equatable {
  final ThemeMode mode;
  const ThemeState(this.mode);
  @override
  List<Object?> get props => [mode];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _key = 'theme_mode';
  final SharedPreferences prefs;

  ThemeBloc({required this.prefs}) : super(const ThemeState(ThemeMode.light)) {
    on<ThemeLoaded>(_onLoaded);
    on<ThemeChanged>(_onChanged);
    add(const ThemeLoaded());
  }

  void _onLoaded(ThemeLoaded event, Emitter<ThemeState> emit) {
    final saved = prefs.getString(_key) ?? 'light';
    emit(ThemeState(_fromString(saved)));
  }

  Future<void> _onChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    await prefs.setString(_key, _toString(event.mode));
    emit(ThemeState(event.mode));
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }

  /// Converts ThemeMode to the display string used in the UI
  static String toLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Automático';
      case ThemeMode.light:
        return 'Claro';
    }
  }

  /// Converts UI label string back to ThemeMode
  static ThemeMode fromLabel(String label) {
    switch (label) {
      case 'Escuro':
        return ThemeMode.dark;
      case 'Automático':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}
