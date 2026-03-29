import 'package:capit_n_bulls/index_detail_sheet.dart';
import 'package:capit_n_bulls/searchpage.dart';
import 'package:flutter/material.dart';
import './stock.dart';
import './index_card.dart';
import './stock_list_tile.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final List<IndexData> _indices = const [
    IndexData(name: 'NIFTY', value: '20,000', change: '+0.25%', isPositive: true),
    IndexData(name: 'SENSEX', value: '68,000', change: '-0.25%', isPositive: false),
    IndexData(name: 'BNKNFTY', value: '45,000', change: '+0.25%', isPositive: true),
  ];

  final List<StockData> _stocks = const [
    StockData(
      symbol: 'RELIANCE', exchange: 'NSE', price: 2847.40, changePercent: 1.23,
      open: 2810.00, high: 2860.00, low: 2798.50, close: 2820.00,
      volume: 4523100, upperCircuit: 3102.65, lowerCircuit: 2538.15,
      week52High: 3024.90, week52Low: 2220.30,
    ),
    StockData(
      symbol: 'SBIN', exchange: 'NSE', price: 1410.65, changePercent: 3.25,
      open: 1365.00, high: 1422.80, low: 1360.10, close: 1368.90,
      volume: 8901200, upperCircuit: 1509.75, lowerCircuit: 1231.55,
      week52High: 1430.00, week52Low: 875.60,
    ),
    StockData(
      symbol: 'TCS', exchange: 'NSE', price: 3140.00, changePercent: 18.2,
      open: 2658.00, high: 3155.00, low: 2640.00, close: 2660.00,
      volume: 2134500, upperCircuit: 3426.00, lowerCircuit: 2800.50,
      week52High: 3160.00, week52Low: 2365.00,
    ),
    StockData(
      symbol: 'HDFCBANK', exchange: 'NSE', price: 1620.45, changePercent: 23.33,
      open: 1314.00, high: 1635.00, low: 1310.50, close: 1313.80,
      volume: 6782300, upperCircuit: 1766.30, lowerCircuit: 1443.90,
      week52High: 1640.00, week52Low: 1363.55,
    ),
    StockData(
      symbol: 'INFY', exchange: 'NSE', price: 1455.20, changePercent: -4.28,
      open: 1520.00, high: 1525.00, low: 1448.00, close: 1519.60,
      volume: 5341800, upperCircuit: 1671.55, lowerCircuit: 1366.70,
      week52High: 1992.00, week52Low: 1351.00,
    ),
    StockData(
      symbol: 'IRCTC', exchange: 'NSE', price: 534.15, changePercent: -2.52,
      open: 548.00, high: 550.00, low: 530.20, close: 547.95,
      volume: 1892600, upperCircuit: 602.70, lowerCircuit: 492.55,
      week52High: 1101.90, week52Low: 528.40,
    ),
  ];

  void _openSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SearchPage(stocks: _stocks),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide up from bottom
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grey background container wrapping indices + search bar (matches design)
        Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            children: [
              // Index Cards Strip
              Row(
                children: _indices.map((idx) => IndexCard(data: idx, onTap: () => IndexDetailSheet.show(context, idx))).toList(),
              ),
              const SizedBox(height: 12),

              // Search Bar — non-interactive, tap opens full screen
              GestureDetector(
                onTap: _openSearch,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.search, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Stock List
        Expanded(
          child: ListView.builder(
            itemCount: _stocks.length,
            itemBuilder: (context, index) =>
                StockListTile(stock: _stocks[index]),
          ),
        ),
      ],
    );
  }
}
