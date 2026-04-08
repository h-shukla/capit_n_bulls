import 'package:flutter/material.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class TradeBookEntry {
  final DateTime tradeDateTime;
  final String symbolName;
  final String symbolCode;
  final String action;
  final int quantity;
  final double tradePrice;
  final List<double> executionPrices;

  const TradeBookEntry({
    required this.tradeDateTime,
    required this.symbolName,
    required this.symbolCode,
    required this.action,
    required this.quantity,
    required this.tradePrice,
    this.executionPrices = const [],
  });

  bool get hasMultipleFills => executionPrices.length > 1;

  double get avgPrice {
    if (!hasMultipleFills) return tradePrice;
    return executionPrices.reduce((a, b) => a + b) / executionPrices.length;
  }
}

// ─── Mock data ────────────────────────────────────────────────────────────────

final List<TradeBookEntry> _mockTrades = [
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 9, 45, 12, 340),
    symbolName: 'AAPL', symbolCode: 'AAPL', action: 'Buy', quantity: 20,
    tradePrice: 165.20,
    executionPrices: [163.50, 165.20, 167.10],
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 9, 45, 33, 870),
    symbolName: 'TSLA', symbolCode: 'TSLA', action: 'Sell', quantity: 12,
    tradePrice: 182.50,
    executionPrices: [182.50, 183.80],
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 9, 45, 55, 120),
    symbolName: 'SBIN', symbolCode: 'SBIN', action: 'Buy', quantity: 3,
    tradePrice: 67.60,
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 9, 46, 4, 210),
    symbolName: 'GOOGLE', symbolCode: 'GOOG', action: 'Buy', quantity: 6,
    tradePrice: 175.80,
    executionPrices: [174.20, 175.80, 176.50],
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 9, 46, 28, 990),
    symbolName: 'HDFCBANK', symbolCode: 'HDFCBNK', action: 'Sell', quantity: 14,
    tradePrice: 1540.00,
    executionPrices: [1538.00, 1540.00],
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 9, 47, 1, 450),
    symbolName: 'RELIANCE', symbolCode: 'RELIANCE', action: 'Sell', quantity: 20,
    tradePrice: 457.60,
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 10, 12, 8, 660),
    symbolName: 'INFY', symbolCode: 'INFY', action: 'Buy', quantity: 8,
    tradePrice: 210.00,
    executionPrices: [209.00, 210.00, 211.50],
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 10, 30, 44, 230),
    symbolName: 'TCS', symbolCode: 'TCS', action: 'Sell', quantity: 5,
    tradePrice: 330.50,
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 11, 5, 19, 780),
    symbolName: 'WIPRO', symbolCode: 'WIPRO', action: 'Buy', quantity: 15,
    tradePrice: 88.75,
    executionPrices: [87.90, 88.75],
  ),
  TradeBookEntry(
    tradeDateTime: DateTime(2025, 6, 12, 11, 45, 36, 100),
    symbolName: 'ICICI', symbolCode: 'ICICI', action: 'Buy', quantity: 4,
    tradePrice: 320.00,
  ),
];

// ─── Formatters ───────────────────────────────────────────────────────────────

String _formatTimeShort(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _formatDateFull(DateTime dt) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

String _formatTimeFull(DateTime dt) {
  final h  = dt.hour.toString().padLeft(2, '0');
  final m  = dt.minute.toString().padLeft(2, '0');
  final s  = dt.second.toString().padLeft(2, '0');
  final ms = dt.millisecond.toString().padLeft(3, '0');
  return '$h:$m:$s.$ms';
}

// ─── Popup ────────────────────────────────────────────────────────────────────

void _showTradeDetail(BuildContext context, TradeBookEntry entry) {
  final isBuy      = entry.action == 'Buy';
  final totalValue = entry.tradePrice * entry.quantity;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.symbolName,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(entry.symbolCode,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBuy ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    entry.action,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isBuy ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),

            // ── Date / time ──
            _DetailRow(label: 'Date', value: _formatDateFull(entry.tradeDateTime)),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Exact time',
              value: _formatTimeFull(entry.tradeDateTime),
              valueMono: true,
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),

            // ── Price section ──
            if (entry.hasMultipleFills) ...[
              _DetailRow(
                label: 'Avg price',
                value: '₹${entry.avgPrice.toStringAsFixed(2)}',
                valueBold: true,
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fill breakdown  ·  ${entry.executionPrices.length} executions',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.executionPrices.asMap().entries.map((e) {
                      final fillNum = e.key + 1;
                      final fillPrice = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fill $fillNum',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                            Text(
                              '₹${fillPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ] else ...[
              _DetailRow(
                label: 'Trade price',
                value: '₹${entry.tradePrice.toStringAsFixed(2)}',
              ),
            ],

            const SizedBox(height: 10),
            _DetailRow(label: 'Quantity', value: '${entry.quantity}'),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Total value',
              value: '₹${totalValue.toStringAsFixed(2)}',
              valueBold: true,
            ),
          ],
        ),
      );
    },
  );
}

// ─── Detail row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;
  final bool valueMono;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
    this.valueMono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w600 : FontWeight.w500,
            fontFamily: valueMono ? 'monospace' : null,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class TradeBookScreen extends StatelessWidget {
  const TradeBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE5E5E7)),
              left: BorderSide(color: Color(0xFFE5E5E7)),
              right: BorderSide(color: Color(0xFFE5E5E7)),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFE5E5E7),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _HeaderCell(label: 'Trade\nTime', flex: 2),
                    _HeaderCell(label: 'Symbol', flex: 3),
                    _HeaderCell(label: 'Buy/Sell', flex: 3),
                    _HeaderCell(label: 'Trade\nPrice', flex: 2, align: TextAlign.right),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E7)),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _mockTrades.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E7)),
                  itemBuilder: (context, index) {
                    return _TradeRow(
                      entry: _mockTrades[index],
                      onTap: () => _showTradeDetail(context, _mockTrades[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header cell ──────────────────────────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;

  const _HeaderCell({
    required this.label,
    required this.flex,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
          height: 1.3,
        ),
      ),
    );
  }
}

// ─── Trade row ────────────────────────────────────────────────────────────────

class _TradeRow extends StatelessWidget {
  final TradeBookEntry entry;
  final VoidCallback onTap;

  const _TradeRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBuy = entry.action == 'Buy';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                _formatTimeShort(entry.tradeDateTime),
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.symbolName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  Text(
                    entry.symbolCode,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${entry.action} ${entry.quantity}',
                style: TextStyle(
                  fontSize: 13,
                  color: isBuy ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '₹${entry.tradePrice.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}