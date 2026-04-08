import 'package:capit_n_bulls/margin_screen.dart';
import 'package:capit_n_bulls/orders_screen.dart';
import 'package:capit_n_bulls/settings_screen.dart';
import 'package:capit_n_bulls/trade_book_screen.dart';
import 'package:flutter/material.dart';
import './watchlist_screen.dart';
import './watchlist_app_bar.dart';
import './stock_bottom_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watchlist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Titles mapped to each tab index
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
      backgroundColor: Colors.white,
      appBar: WatchlistAppBar(title: _titles[_currentIndex]), // Pass title here
      body: _screens[_currentIndex],
      bottomNavigationBar: StockBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
