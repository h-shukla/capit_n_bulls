import 'package:capit_n_bulls/index_detail_sheet.dart';
import 'package:capit_n_bulls/searchpage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import './stock.dart';
import './index_card.dart';
import './stock_list_tile.dart';

// ── Server config ─────────────────────────────────────────────────────────────
const String kServerHost = '69.62.75.117';
const String kWsUrl = 'ws://$kServerHost:8765/ws/live-prices';
const String kNamesUrl = 'http://$kServerHost:8765/instruments/names';
// ─────────────────────────────────────────────────────────────────────────────

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final List<IndexData> _indices = const [];

  /// token → StockData  (all tokens the backend ever sends)
  final Map<int, StockData> _stockMap = {};

  /// token → {symbol, exchange}  — fetched once from REST, falls back to token string
  final Map<int, ({String symbol, String exchange})> _tokenMeta = {};

  bool _awaitingFirstTick = true;

  // debug
  static const bool _debug = true;
  String _debugMsg = 'Connecting…';
  bool _showDebugBanner = true;

  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchInstrumentNames(); // fire-and-forget; WS works even if this fails
    _connectWebSocket();
  }

  // ── REST: fetch token→symbol map from backend ─────────────────────────────
  Future<void> _fetchInstrumentNames() async {
    try {
      final res = await http
          .get(Uri.parse(kNamesUrl))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(res.body) as Map<String, dynamic>;
        // Expected shape: {"492033": {"symbol": "SBIN", "exchange": "NSE"}, …}
        body.forEach((key, value) {
          final token = int.tryParse(key);
          if (token != null && value is Map<String, dynamic>) {
            _tokenMeta[token] = (
              symbol: (value['symbol'] as String? ?? key),
              exchange: (value['exchange'] as String? ?? 'NSE'),
            );
          }
        });
        // Refresh any already-received stocks with proper names
        if (mounted) setState(() {});
      }
    } catch (_) {
      // Names endpoint not available — will use token-string fallback
    }
  }

  // ── Resolve display name for a token ─────────────────────────────────────
  String _symbol(int token) => _tokenMeta[token]?.symbol ?? 'TOKEN-$token';
  String _exchange(int token) => _tokenMeta[token]?.exchange ?? 'NSE';

  // ── WebSocket ─────────────────────────────────────────────────────────────
  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(kWsUrl));
    _channel.stream.listen(
      _onMessage,
      onError: (e) {
        debugPrint('WS error: $e');
        if (mounted) setState(() => _debugMsg = 'WS error: $e');
      },
      onDone: () {
        debugPrint('WS closed');
        if (mounted) setState(() => _debugMsg = 'WS closed');
      },
    );
  }

  Map<String, dynamic>? _extractFeed(Map<String, dynamic> decoded) {
    if (decoded.containsKey('price_feed')) {
      final inner = decoded['price_feed'];
      if (inner is Map<String, dynamic>) return inner;
    }
    if (decoded.isNotEmpty && int.tryParse(decoded.keys.first) != null) {
      return decoded;
    }
    return null;
  }

  void _onMessage(dynamic raw) {
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      print(decoded);
    } catch (e) {
      if (mounted) setState(() => _debugMsg = 'JSON parse error: $e');
      return;
    }

    // ── Parse mapper: token_string → symbol ─────────────────────────────────
    final mapper = decoded['mapper'];
    if (mapper is Map<String, dynamic>) {
      mapper.forEach((tokenStr, symbol) {
        final token = int.tryParse(tokenStr);
        if (token != null && symbol is String) {
          _tokenMeta[token] = (symbol: symbol, exchange: 'NSE');
        }
      });
    }
    // ────────────────────────────────────────────────────────────────────────

    // ── Parse price_feed: symbol_string → data ───────────────────────────────
    final priceFeed = decoded['price_feed'];
    if (priceFeed is! Map<String, dynamic>) {
      if (mounted) {
        setState(
          () => _debugMsg = 'No price_feed. Keys: ${decoded.keys.toList()}',
        );
      }
      return;
    }

    bool didChange = false;

    for (final entry in priceFeed.entries) {
      if (entry.value is! Map<String, dynamic>) continue;
      final feedEntry = entry.value as Map<String, dynamic>;

      // Use instrument_token from inside the feed entry as the key
      final tokenFromFeed = feedEntry['instrument_token'];
      final int token;
      if (tokenFromFeed is int) {
        token = tokenFromFeed;
      } else if (tokenFromFeed is double) {
        token = tokenFromFeed.toInt();
      } else {
        // Fallback: hash the symbol string
        token = entry.key.hashCode;
      }

      // Symbol: prefer mapper lookup, fallback to the feed key (e.g. "M&M")
      final symbol = _tokenMeta[token]?.symbol ?? entry.key;
      final exchange = feedEntry['tradable'] == false ? 'BSE' : 'NSE';

      // Update tokenMeta if not already set
      _tokenMeta.putIfAbsent(token, () => (symbol: symbol, exchange: exchange));

      final prev = _stockMap[token];

      _stockMap[token] = StockData.fromWsFeed(
        token: token,
        map: feedEntry,
        symbol: symbol,
        exchange: exchange,
        prevUpperCircuit: prev?.upperCircuit,
        prevLowerCircuit: prev?.lowerCircuit,
        prevWeek52High: prev?.week52High,
        prevWeek52Low: prev?.week52Low,
      );

      didChange = true;
    }

    if (!mounted) return;
    if (didChange) {
      final wasAwaiting = _awaitingFirstTick;
      setState(() {
        _awaitingFirstTick = false;
        _debugMsg =
            '✅ Live | ${_stockMap.length} stocks | '
            'tokens: ${_stockMap.keys.take(4).join(', ')}…';
      });
      if (wasAwaiting) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _showDebugBanner = false);
        });
      }
    }
  }

  List<StockData> get _stocks => _stockMap.values.toList();

  void _openSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SearchPage(stocks: _stocks),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
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
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stripBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade200;
    final searchBg = isDark ? const Color(0xFF272727) : Colors.black;
    final searchBorder = isDark ? const Color(0xFF272727) : Colors.transparent;

    return Column(
      children: [
        // ── Debug banner ───────────────────────────────────────────────────
        if (_debug && _showDebugBanner)
          Material(
            color: _awaitingFirstTick
                ? Colors.orange.shade900
                : Colors.green.shade900,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Row(
                children: [
                  Icon(
                    _awaitingFirstTick ? Icons.hourglass_top : Icons.wifi,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _debugMsg,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Index strip + search bar ───────────────────────────────────────
        Container(
          color: stripBg,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Column(
            children: [
              if (_indices.isNotEmpty) ...[
                Row(
                  children: _indices
                      .map(
                        (idx) => IndexCard(
                          data: idx,
                          onTap: () => IndexDetailSheet.show(context, idx),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              GestureDetector(
                onTap: _openSearch,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: searchBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: searchBorder, width: 0.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

        // ── Stock list ─────────────────────────────────────────────────────
        Expanded(
          child: _awaitingFirstTick
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _stocks.length,
                  itemBuilder: (_, i) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StockListTile(stock: _stocks[i]),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
