import 'dart:async';
import 'dart:convert';
import 'package:capit_n_bulls/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

enum OrderStatus { open, pending, closed, cancelled }

// ─── Model ────────────────────────────────────────────────────────────────────

class Order {
  final String orderId;
  final String time;
  final String symbol;
  final String exchangeToken; // key used in pnl feed
  final String action;
  final int quantity;
  final double price; // entry price
  final double totalValue;
  final OrderStatus status;
  final double currentPrice; // updated from WS pnl feed

  const Order({
    required this.orderId,
    required this.time,
    required this.symbol,
    required this.exchangeToken,
    required this.action,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.status,
    required this.currentPrice,
  });

  Order copyWithLtp(double ltp) => Order(
    orderId: orderId,
    time: time,
    symbol: symbol,
    exchangeToken: exchangeToken,
    action: action,
    quantity: quantity,
    price: price,
    totalValue: totalValue,
    status: status,
    currentPrice: ltp,
  );

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] as String? ?? '').toUpperCase();
    final status = switch (rawStatus) {
      'OPEN' => OrderStatus.open,
      'PENDING' => OrderStatus.pending,
      'CLOSED' => OrderStatus.closed,
      'CANCELLED' || 'CANCELED' => OrderStatus.cancelled,
      _ => OrderStatus.open,
    };

    final contractName =
        json['contract_name'] as String? ??
            json['exchange_token'] as String? ??
            'UNKNOWN';
    final exchangeToken = json['exchange_token'] as String? ?? contractName;
    final symbol = _parseSymbol(contractName);

    final createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ??
            DateTime.now();
    final time =
        '${createdAt.hour}.${createdAt.minute.toString().padLeft(2, '0')}';

    final side = json['side'] as String? ?? 'BUY';
    final action = side[0].toUpperCase() + side.substring(1).toLowerCase();

    final entryPrice = (json['entry_price'] as num?)?.toDouble() ?? 0.0;
    final qty = (json['qty'] as num?)?.toInt() ?? 1;

    return Order(
      orderId: json['order_id'] as String? ?? '',
      time: time,
      symbol: symbol,
      exchangeToken: exchangeToken,
      action: action,
      quantity: qty,
      price: entryPrice,
      totalValue: entryPrice * qty,
      status: status,
      currentPrice: entryPrice, // will be overwritten by WS feed
    );
  }

  static String _parseSymbol(String contractName) {
    var s = contractName.replaceAll(RegExp(r'(FUT|CE|PE)$'), '');
    s = s.replaceAll(RegExp(r'\d{2}[A-Z]{3}$'), '');
    return s.isEmpty ? contractName : s;
  }
}

// ─── Repository ───────────────────────────────────────────────────────────────

class OrdersRepository {
  static const String _baseUrl = 'http://69.62.75.117:8765';

  Future<List<Order>> fetchOrders(String userId) async {
    final uri = Uri.parse('$_baseUrl/orders/$userId');
    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load orders (HTTP ${response.statusCode})');
    }

    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> closeOrder(String orderId) async {
    final uri = Uri.parse('$_baseUrl/orders/$orderId/close');
    final response =
    await http.patch(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to close order (HTTP ${response.statusCode})');
    }
  }
}

// ─── WS PnL provider ─────────────────────────────────────────────────────────
//
// Connects to ws://host/ws/pnl/{userId} and exposes a stream of
// Map<exchangeToken, ltp> so the UI can update prices without re-fetching REST.

class PnlWebSocket {
  static const String _wsBase = 'ws://69.62.75.117:8765';

  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, double>>.broadcast();
  Timer? _pingTimer;

  Stream<Map<String, double>> get ltpStream => _controller.stream;

  void connect(String userId) {
    _channel?.sink.close();
    final uri = Uri.parse('$_wsBase/ws/pnl/$userId');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
          (message) {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          // WS payload: { user_id, timestamp, total_pnl, orders: [...] }
          // Each order has exchange_token + pnl. We need ltp.
          // ltp = entry_price + pnl/qty  (BUY)  or  entry_price - pnl/qty (SELL)
          final orders = data['orders'] as List<dynamic>? ?? [];
          final ltpMap = <String, double>{};

          for (final o in orders) {
            final order = o as Map<String, dynamic>;
            final token = order['exchange_token'] as String? ?? '';
            final ltp = order['ltp'];
            if (token.isNotEmpty && ltp != null) {
              ltpMap[token] = (ltp as num).toDouble();
            }
          }

          if (ltpMap.isNotEmpty) _controller.add(ltpMap);
        } catch (_) {}
      },
      onError: (_) => _scheduleReconnect(userId),
      onDone: () => _scheduleReconnect(userId),
    );

    // Keep-alive ping every 20 s
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _channel?.sink.add('ping');
      } catch (_) {}
    });
  }

  void _scheduleReconnect(String userId) {
    Future.delayed(const Duration(seconds: 3), () => connect(userId));
  }

  void dispose() {
    _pingTimer?.cancel();
    _channel?.sink.close();
    _controller.close();
  }
}

// ─── Bottom sheet popup ───────────────────────────────────────────────────────

void _showOrderDetail(
    BuildContext context,
    Order order, {
      VoidCallback? onClosed,
      Stream<Map<String, double>>? ltpStream,
    }) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white,
    builder: (context) => _OrderDetailSheet(
      order: order,
      onClosed: onClosed,
      ltpStream: ltpStream,
    ),
  );
}

class _OrderDetailSheet extends StatefulWidget {
  final Order order;
  final VoidCallback? onClosed;
  final Stream<Map<String, double>>? ltpStream;

  const _OrderDetailSheet({
    required this.order,
    this.onClosed,
    this.ltpStream,
  });

  @override
  State<_OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends State<_OrderDetailSheet> {
  final _repo = OrdersRepository();
  bool _isClosing = false;
  late double _currentPrice;
  StreamSubscription<Map<String, double>>? _ltpSub;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.order.currentPrice;
    _ltpSub = widget.ltpStream?.listen((ltpMap) {
      final ltp = ltpMap[widget.order.exchangeToken];
      if (ltp != null && mounted) {
        setState(() => _currentPrice = ltp);
      }
    });
  }

  @override
  void dispose() {
    _ltpSub?.cancel();
    super.dispose();
  }

  Future<void> _exitPosition() async {
    setState(() => _isClosing = true);
    try {
      await _repo.closeOrder(widget.order.orderId);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onClosed?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Position closed for ${widget.order.symbol}'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade300
              : Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isClosing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to close position: $e'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isBuy = order.action == 'Buy';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pnlPerUnit = isBuy
        ? _currentPrice - order.price
        : order.price - _currentPrice;
    final totalPnl = pnlPerUnit * order.quantity;
    final isProfit = totalPnl >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${order.action}  ·  ${order.quantity} qty  ·  ${order.time}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
          const SizedBox(height: 20),
          _DetailRow(
            label: 'Entry price',
            value: '₹${order.price.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: 'Current price',
            value: _currentPrice > 0
                ? '₹${_currentPrice.toStringAsFixed(2)}'
                : '—',
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live P&L',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              _currentPrice > 0
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isProfit ? '+' : ''}₹${totalPnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isProfit
                          ? const Color(0xFF81C784)
                          : const Color(0xFFE57373),
                    ),
                  ),
                  Text(
                    '${isProfit ? '+' : ''}${order.price > 0 ? (pnlPerUnit / order.price * 100).toStringAsFixed(2) : '0.00'}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isProfit
                          ? const Color(0xFF81C784)
                          : const Color(0xFFE57373),
                    ),
                  ),
                ],
              )
                  : Text(
                '—',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.grey.shade500
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
          if (order.status == OrderStatus.open) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isClosing ? null : _exitPosition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  const Color(0xFFD32F2F).withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isClosing
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Exit position',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, bg, fg) = switch (status) {
      OrderStatus.open || OrderStatus.pending => (
      status == OrderStatus.pending ? 'Pending' : 'Open',
      isDark
          ? const Color(0xFF0D47A1).withValues(alpha: 0.3)
          : const Color(0xFFE3F2FD),
      isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0),
      ),
      OrderStatus.closed => (
      'Closed',
      isDark
          ? const Color(0xFF1B5E20).withValues(alpha: 0.3)
          : const Color(0xFFE8F5E9),
      isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
      ),
      OrderStatus.cancelled => (
      'Cancelled',
      isDark ? Colors.white10 : const Color(0xFFFAFAFA),
      isDark ? Colors.grey.shade400 : Colors.grey,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

// ─── Screen + Tabs ────────────────────────────────────────────────────────────

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = OrdersRepository();
  final _pnlWs = PnlWebSocket();

  late Future<List<Order>> _ordersFuture;

  // Live LTP map updated from WS: exchangeToken → ltp
  final Map<String, double> _ltpMap = {};
  StreamSubscription<Map<String, double>>? _ltpSub;

  String get _userId => ref.read(authProvider.notifier).userId ?? 'unknown';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _ordersFuture = _repo.fetchOrders(_userId);

    _pnlWs.connect(_userId);
    _ltpSub = _pnlWs.ltpStream.listen((ltpMap) {
      if (mounted) {
        setState(() => _ltpMap.addAll(ltpMap));
      }
    });
  }

  @override
  void dispose() {
    _ltpSub?.cancel();
    _pnlWs.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _ordersFuture = _repo.fetchOrders(_userId);
    });
  }

  /// Merge live LTP into fetched orders
  List<Order> _withLivePrices(List<Order> orders) {
    return orders.map((o) {
      final ltp = _ltpMap[o.exchangeToken];
      return ltp != null && ltp > 0 ? o.copyWithLtp(ltp) : o;
    }).toList();
  }

  List<Order> _filteredOrders(List<Order> all, int tabIndex) {
    return switch (tabIndex) {
      0 => all,
      1 => all.where((o) => o.status == OrderStatus.open).toList(),
      2 => all.where((o) => o.status == OrderStatus.pending).toList(),
      3 => all.where((o) => o.status == OrderStatus.cancelled).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      child: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 52,
                        color: isDark
                            ? Colors.white24
                            : Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load orders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Apply live LTP from WS feed over the REST snapshot
          final allOrders = _withLivePrices(snapshot.data ?? []);

          return Column(
            children: [
              TabBar(
                isScrollable: true,
                controller: _tabController,
                labelColor: isDark ? Colors.white : Colors.black,
                unselectedLabelColor: Colors.grey.shade500,
                indicatorColor: isDark ? Colors.white : Colors.black,
                indicatorWeight: 2,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w400),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Open'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Cancelled'),
                ],
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? Colors.white10 : Colors.grey.shade200,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(4, (tabIndex) {
                    final orders = _filteredOrders(allOrders, tabIndex);

                    if (orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 64,
                                color: isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200),
                            const SizedBox(height: 16),
                            Text(
                              'No orders here',
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 1,
                          color: isDark
                              ? Colors.white10
                              : Colors.grey.shade100,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) => _OrderTile(
                          order: orders[index],
                          onTap: () => _showOrderDetail(
                            context,
                            orders[index],
                            onClosed: _refresh,
                            ltpStream: _pnlWs.ltpStream,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const _OrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBuy = order.action == 'Buy';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isOpen = order.status == OrderStatus.open ||
        order.status == OrderStatus.pending;
    final hasLivePrice = order.currentPrice > 0 && isOpen;

    final pnlPerUnit = isBuy
        ? order.currentPrice - order.price
        : order.price - order.currentPrice;
    final totalPnl = pnlPerUnit * order.quantity;
    final isProfit = totalPnl >= 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                order.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.symbol,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isBuy
                              ? (isDark
                              ? const Color(0xFF1B5E20)
                              .withValues(alpha: 0.3)
                              : const Color(0xFFE8F5E9))
                              : (isDark
                              ? const Color(0xFFB71C1C)
                              .withValues(alpha: 0.3)
                              : const Color(0xFFFFEBEE)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.action.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isBuy
                                ? const Color(0xFF81C784)
                                : const Color(0xFFE57373),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${order.quantity} qty  ·  avg ₹${order.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.currentPrice > 0
                      ? '₹${order.currentPrice.toStringAsFixed(2)}'
                      : '₹${order.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                // Show live P&L for open orders, total value otherwise
                hasLivePrice
                    ? Text(
                  '${isProfit ? '+' : ''}₹${totalPnl.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isProfit
                        ? const Color(0xFF81C784)
                        : const Color(0xFFE57373),
                  ),
                )
                    : Text(
                  '₹${order.totalValue.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}