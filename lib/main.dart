import 'package:capit_n_bulls/login_screen.dart';
import 'package:capit_n_bulls/margin_screen.dart';
import 'package:capit_n_bulls/orders_screen.dart';
import 'package:capit_n_bulls/providers/theme_provider.dart';
import 'package:capit_n_bulls/settings_screen.dart';
import 'package:capit_n_bulls/trade_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './watchlist_screen.dart';
import './watchlist_app_bar.dart';
import './stock_bottom_nav_bar.dart';

void main() {
  runApp(
    const ProviderScope(
      // 👈 fix #1: wraps the entire app
      child: MyApp(),
    ),
  );
}

// 👈 fix #2: ConsumerWidget so it can read themeProvider
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Watchlist',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeAsync.valueOrNull ?? ThemeMode.system,
      home: const LoginScreen(),
    );
  }
}

// ─── Shell ────────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<String> _titles = [
    'Watchlist',
    'Orders',
    'Trade Book',
    'Margin',
    'Settings',
  ];

  final List<Widget> _screens = [
    const WatchlistScreen(),
    const OrdersScreen(),
    const TradeBookScreen(),
    const MarginScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WatchlistAppBar(title: _titles[_currentIndex]),
      body: _screens[_currentIndex],
      bottomNavigationBar: StockBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
