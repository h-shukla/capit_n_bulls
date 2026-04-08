import 'package:flutter/material.dart';

enum OrderStatus { open, completed, cancelled }

class Order {
  final String time;
  final String symbol;
  final String action;
  final int quantity;
  final double price;       // avg/entry price
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
  Order(time: '10.22', symbol: 'Reliance', action: 'Sell', quantity: 4, price: 457.60, totalValue: 3454.00, status: OrderStatus.open, currentPrice: 462.10),
  Order(time: '10.18', symbol: 'SBIN', action: 'Buy', quantity: 3, price: 67.60, totalValue: 670.00, status: OrderStatus.open, currentPrice: 69.40),
  Order(time: '10.18', symbol: 'TCS', action: 'Buy', quantity: 3, price: 972.60, totalValue: 2200.00, status: OrderStatus.completed, currentPrice: 980.00),
  Order(time: '9.49', symbol: 'AAPL', action: 'Buy', quantity: 3, price: 165.50, totalValue: 175.00, status: OrderStatus.completed, currentPrice: 170.00),
  Order(time: '9.28', symbol: 'Tesla', action: 'Sell', quantity: 5, price: 130.60, totalValue: 1556.00, status: OrderStatus.completed, currentPrice: 128.00),
  Order(time: '9.28', symbol: 'AAPL', action: 'Sell', quantity: 8, price: 5.10, totalValue: 3200.00, status: OrderStatus.cancelled, currentPrice: 170.00),
  Order(time: '9.10', symbol: 'INFY', action: 'Buy', quantity: 10, price: 210.00, totalValue: 2100.00, status: OrderStatus.cancelled, currentPrice: 215.00),
  Order(time: '8.55', symbol: 'HDFC', action: 'Buy', quantity: 2, price: 1540.00, totalValue: 3080.00, status: OrderStatus.open, currentPrice: 1558.50),
  Order(time: '8.40', symbol: 'Wipro', action: 'Sell', quantity: 6, price: 88.00, totalValue: 528.00, status: OrderStatus.cancelled, currentPrice: 90.00),
  Order(time: '8.30', symbol: 'ICICI', action: 'Buy', quantity: 4, price: 320.50, totalValue: 1282.00, status: OrderStatus.completed, currentPrice: 330.00),
];

// ─── Bottom sheet popup ───────────────────────────────────────────────────────

void _showOrderDetail(BuildContext context, Order order) {
  final isBuy = order.action == 'Buy';

  final pnlPerUnit = isBuy
      ? order.currentPrice - order.price
      : order.price - order.currentPrice;
  final totalPnl = pnlPerUnit * order.quantity;
  final isProfit = totalPnl >= 0;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.symbol,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${order.action}  ·  ${order.quantity} qty  ·  ${order.time}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),

            _DetailRow(label: 'Entry price', value: '₹${order.price.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            _DetailRow(label: 'Current price', value: '₹${order.currentPrice.toStringAsFixed(2)}'),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live P&L',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isProfit ? '+' : ''}₹${totalPnl.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isProfit
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                    Text(
                      '${isProfit ? '+' : ''}${(pnlPerUnit / order.price * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isProfit
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (order.status == OrderStatus.open) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Exit order placed for ${order.symbol}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Exit position',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      OrderStatus.open => ('Open', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      OrderStatus.completed => ('Completed', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      OrderStatus.cancelled => ('Cancelled', const Color(0xFFFAFAFA), Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
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
        return _mockOrders.where((o) => o.status == OrderStatus.completed).toList();
      case 3:
        return _mockOrders.where((o) => o.status == OrderStatus.cancelled).toList();
      default:
        return _mockOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            isScrollable: true,
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: Colors.black,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Open'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
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
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No orders here',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: orders.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade100,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  return _OrderTile(
                    order: orders[index],
                    onTap: () => _showOrderDetail(context, orders[index]),
                  );
                },
              );
            }),
          ),
        ),
      ],
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36,
              child: Text(
                order.time,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.3),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.symbol,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isBuy
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          order.action,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isBuy
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${order.quantity}  ·  avg ₹${order.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                const SizedBox(height: 2),
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