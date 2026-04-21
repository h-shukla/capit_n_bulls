import 'package:flutter/material.dart';

enum OrderStatus { open, completed, cancelled }

class Order {
  final String time;
  final String symbol;
  final String action;
  final int quantity;
  final double price; // avg/entry price
  final double totalValue;
  final OrderStatus status;
  final double currentPrice; // for live P&L

  const Order({
    required this.time,
    required this.symbol,
    required this.action,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.status,
    required this.currentPrice,
  });
}

final List<Order> _mockOrders = [
  Order(
    time: '10.22',
    symbol: 'Reliance',
    action: 'Sell',
    quantity: 4,
    price: 457.60,
    totalValue: 3454.00,
    status: OrderStatus.open,
    currentPrice: 462.10,
  ),
  Order(
    time: '10.18',
    symbol: 'SBIN',
    action: 'Buy',
    quantity: 3,
    price: 67.60,
    totalValue: 670.00,
    status: OrderStatus.open,
    currentPrice: 69.40,
  ),
  Order(
    time: '10.18',
    symbol: 'TCS',
    action: 'Buy',
    quantity: 3,
    price: 972.60,
    totalValue: 2200.00,
    status: OrderStatus.completed,
    currentPrice: 980.00,
  ),
  Order(
    time: '9.49',
    symbol: 'AAPL',
    action: 'Buy',
    quantity: 3,
    price: 165.50,
    totalValue: 175.00,
    status: OrderStatus.completed,
    currentPrice: 170.00,
  ),
  Order(
    time: '9.28',
    symbol: 'Tesla',
    action: 'Sell',
    quantity: 5,
    price: 130.60,
    totalValue: 1556.00,
    status: OrderStatus.completed,
    currentPrice: 128.00,
  ),
  Order(
    time: '9.28',
    symbol: 'AAPL',
    action: 'Sell',
    quantity: 8,
    price: 5.10,
    totalValue: 3200.00,
    status: OrderStatus.cancelled,
    currentPrice: 170.00,
  ),
  Order(
    time: '9.10',
    symbol: 'INFY',
    action: 'Buy',
    quantity: 10,
    price: 210.00,
    totalValue: 2100.00,
    status: OrderStatus.cancelled,
    currentPrice: 215.00,
  ),
  Order(
    time: '8.55',
    symbol: 'HDFC',
    action: 'Buy',
    quantity: 2,
    price: 1540.00,
    totalValue: 3080.00,
    status: OrderStatus.open,
    currentPrice: 1558.50,
  ),
  Order(
    time: '8.40',
    symbol: 'Wipro',
    action: 'Sell',
    quantity: 6,
    price: 88.00,
    totalValue: 528.00,
    status: OrderStatus.cancelled,
    currentPrice: 90.00,
  ),
  Order(
    time: '8.30',
    symbol: 'ICICI',
    action: 'Buy',
    quantity: 4,
    price: 320.50,
    totalValue: 1282.00,
    status: OrderStatus.completed,
    currentPrice: 330.00,
  ),
];

// ─── Bottom sheet popup ───────────────────────────────────────────────────────

void _showOrderDetail(BuildContext context, Order order) {
  final isBuy = order.action == 'Buy';
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final pnlPerUnit = isBuy
      ? order.currentPrice - order.price
      : order.price - order.currentPrice;
  final totalPnl = pnlPerUnit * order.quantity;
  final isProfit = totalPnl >= 0;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    builder: (context) {
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
              value: '₹${order.currentPrice.toStringAsFixed(2)}',
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
                Column(
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
                      '${isProfit ? '+' : ''}${(pnlPerUnit / order.price * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isProfit
                            ? const Color(0xFF81C784)
                            : const Color(0xFFE57373),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (order.status == OrderStatus.open) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exit order placed for ${order.symbol}'),
                        backgroundColor: isDark
                            ? Colors.grey.shade900
                            : Colors.black87,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Exit position',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
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
      OrderStatus.open => (
        'Open',
        isDark
            ? const Color(0xFF0D47A1).withValues(alpha: 0.3)
            : const Color(0xFFE3F2FD),
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0),
      ),
      OrderStatus.completed => (
        'Completed',
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

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _filteredOrders(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _mockOrders;
      case 1:
        return _mockOrders.where((o) => o.status == OrderStatus.open).toList();
      case 2:
        return _mockOrders
            .where((o) => o.status == OrderStatus.completed)
            .toList();
      case 3:
        return _mockOrders
            .where((o) => o.status == OrderStatus.cancelled)
            .toList();
      default:
        return _mockOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            controller: _tabController,
            labelColor: isDark ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: isDark ? Colors.white : Colors.black,
            indicatorWeight: 2,
            dividerColor: Colors.transparent, // Removes bottom line
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Open'),
              Tab(text: 'Completed'),
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
                final orders = _filteredOrders(tabIndex);
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders here',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) => _OrderTile(
                    order: orders[index],
                    onTap: () => _showOrderDetail(context, orders[index]),
                  ),
                );
              }),
            ),
          ),
        ],
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isBuy
                              ? (isDark
                                    ? const Color(
                                        0xFF1B5E20,
                                      ).withValues(alpha: 0.3)
                                    : const Color(0xFFE8F5E9))
                              : (isDark
                                    ? const Color(
                                        0xFFB71C1C,
                                      ).withValues(alpha: 0.3)
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
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
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
                  '₹${order.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${order.totalValue.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
