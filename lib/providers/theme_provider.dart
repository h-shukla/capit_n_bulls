import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'isDarkMode';

// ─── Colour tokens ────────────────────────────────────────────────────────────

const _darkBackground = Color(0xFF151515);
const _darkSurface = Color(0xFF1E1E1E);
const _darkSurfaceVar = Color(0xFF252525);

// Updated Primary: Changed from Purple to #7495B9
const _primary = Color(0xFF7495B9);
const _onPrimary = Color(0xFFFFFFFF);
const _darkOnSurface = Color(0xFFE8E8E8);
const _darkOnBg = Color(0xFFF2F2F2);
const _darkSubtle = Color(0xFF9E9E9E);

// ─── Gain / Loss semantic colours ─────────────────────────────────────────────

const gainGreen = Color(0xFF3FD47E);
const gainGreenBg = Color(0xFF0D2E1A);
const lossRed = Color(0xFFE05252);
const lossRedBg = Color(0xFF2E0D0D);

// ─── Themes ───────────────────────────────────────────────────────────────────

final lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.light,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkBackground,
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: _primary,
    onPrimary: _onPrimary,
    secondary: _primary,
    onSecondary: _onPrimary,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    surfaceContainerHighest: _darkSurfaceVar,
    outline: Color(0xFF3A3A3A),
    error: Color(0xFFCF6679),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _darkBackground,
    foregroundColor: _darkOnBg,
    elevation: 0,
    scrolledUnderElevation: 2,
    surfaceTintColor: Colors.transparent,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _darkSurface,
    selectedItemColor: _primary, // Now Slate Blue
    unselectedItemColor: _darkSubtle,
  ),
  cardTheme: CardThemeData(
    color: _darkSurface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF2C2C2C)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _darkSurfaceVar,
    hintStyle: const TextStyle(color: _darkSubtle),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: _primary,
        width: 1.5,
      ), // Now Slate Blue
    ),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFF2C2C2C), thickness: 1),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _primary, // Now Slate Blue
    foregroundColor: _onPrimary,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: _darkSurfaceVar,
    labelStyle: const TextStyle(color: _darkOnSurface),
    side: const BorderSide(color: Color(0xFF2C2C2C)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  iconTheme: const IconThemeData(color: _darkOnBg),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: _darkOnBg),
    bodyMedium: TextStyle(color: _darkOnBg),
    bodySmall: TextStyle(color: _darkSubtle),
    titleLarge: TextStyle(color: _darkOnBg, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: _darkOnBg, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: _darkSubtle),
  ),
);

// ─── Provider remains unchanged ───────────────────────────────────────────────

final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  late SharedPreferences _prefs;

  @override
  Future<ThemeMode> build() async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs.getBool(_kThemeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? ThemeMode.light;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _prefs.setBool(_kThemeKey, next == ThemeMode.dark);
    state = AsyncData(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setBool(_kThemeKey, mode == ThemeMode.dark);
    state = AsyncData(mode);
  }
}
