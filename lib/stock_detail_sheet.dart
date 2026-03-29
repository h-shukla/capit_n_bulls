import 'package:flutter/material.dart';
import 'stock.dart';

class StockDetailSheet extends StatefulWidget {
  final StockData stock;

  const StockDetailSheet({super.key, required this.stock});

  static void show(BuildContext context, StockData stock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      useSafeArea: true,
      builder: (_) => StockDetailSheet(stock: stock),
    );
  }

  @override
  State<StockDetailSheet> createState() => _StockDetailSheetState();
}

class _StockDetailSheetState extends State<StockDetailSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _green = Color(0xFF00C853);
  static const _red = Color(0xFFD50000);
  static const _labelColor = Color(0xFF9E9E9E);
  static const _valueColor = Color(0xFF1A1A1A);
  static const _dividerColor = Color(0xFFEEEEEE);
  static const _sectionLabelColor = Color(0xFFBDBDBD);
  static const _bgColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final stock = widget.stock;
    final isPositive = stock.changePercent >= 0;
    final accentColor = isPositive ? _green : _red;
    final changeText =
        '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%';

    return FadeTransition(
      opacity: _fadeAnim,
      child: DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // ── Drag handle ──
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Scrollable content ──
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stock.symbol,
                                  style: const TextStyle(
                                    color: _valueColor,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    stock.exchange,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${stock.formattedPrice}',
                                style: const TextStyle(
                                  color: _valueColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPositive
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      color: accentColor,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      changeText,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 20),

                      _sectionLabel('TODAY'),
                      const SizedBox(height: 12),
                      _twoColumnGrid([
                        _StatItem(label: 'Open',   value: '₹${_fmt(stock.open)}'),
                        _StatItem(label: 'Close',  value: '₹${_fmt(stock.close)}'),
                        _StatItem(label: 'High',   value: '₹${_fmt(stock.high)}',  valueColor: _green),
                        _StatItem(label: 'Low',    value: '₹${_fmt(stock.low)}',   valueColor: _red),
                        _StatItem(label: 'Volume', value: stock.formattedVolume),
                      ]),

                      const SizedBox(height: 8),
                      _divider(),
                      const SizedBox(height: 20),

                      _sectionLabel('CIRCUIT LIMITS'),
                      const SizedBox(height: 12),
                      _circuitBar(stock),

                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 20),

                      _sectionLabel('52-WEEK RANGE'),
                      const SizedBox(height: 12),
                      _weekRangeBar(stock),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // ── Sticky Buy/Sell Bar ──
                _BuySellBar(stock: stock),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmt(double v) => v.toStringAsFixed(2);

  Widget _divider() => Container(height: 1, color: _dividerColor);

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: _sectionLabelColor,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );

  Widget _twoColumnGrid(List<_StatItem> items) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(child: _statCell(left)),
              if (right != null) Expanded(child: _statCell(right)),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _statCell(_StatItem item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        item.label,
        style: const TextStyle(
          color: _labelColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        item.value,
        style: TextStyle(
          color: item.valueColor ?? _valueColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _circuitBar(StockData stock) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circuitLabel('LC', '₹${_fmt(stock.lowerCircuit)}', _red),
            _circuitLabel('UC', '₹${_fmt(stock.upperCircuit)}', _green),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(builder: (context, constraints) {
          final range = stock.upperCircuit - stock.lowerCircuit;
          final ratio = ((stock.price - stock.lowerCircuit) / range).clamp(0.0, 1.0);
          final dotLeft = (constraints.maxWidth * ratio - 6).clamp(0.0, constraints.maxWidth - 12);

          return SizedBox(
            height: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 3, left: 0, right: 0,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Positioned(
                  left: dotLeft, top: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Current ₹${_fmt(stock.price)}',
            style: const TextStyle(color: _labelColor, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _circuitLabel(String tag, String value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: _valueColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _weekRangeBar(StockData stock) {
    final range = stock.week52High - stock.week52Low;
    final ratio = ((stock.price - stock.week52Low) / range).clamp(0.0, 1.0);

    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final dotLeft = (constraints.maxWidth * ratio - 6).clamp(0.0, constraints.maxWidth - 12);

          return SizedBox(
            height: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 3, left: 0, right: 0,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _red.withValues(alpha: 0.5),
                        _green.withValues(alpha: 0.5),
                      ]),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Positioned(
                  left: dotLeft, top: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('52W Low', style: TextStyle(color: _labelColor, fontSize: 11)),
              const SizedBox(height: 2),
              Text('₹${_fmt(stock.week52Low)}',
                  style: const TextStyle(color: _red, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('52W High', style: TextStyle(color: _labelColor, fontSize: 11)),
              const SizedBox(height: 2),
              Text('₹${_fmt(stock.week52High)}',
                  style: const TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ],
        ),
      ],
    );
  }
}

// ── Buy/Sell Bar ─────────────────────────────────────────────────────────────

class _BuySellBar extends StatelessWidget {
  final StockData stock;
  const _BuySellBar({required this.stock});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderButton(
              label: 'BUY',
              color: const Color(0xFF00C853),
              stock: stock,
              isBuy: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OrderButton(
              label: 'SELL',
              color: const Color(0xFFD50000),
              stock: stock,
              isBuy: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderButton extends StatelessWidget {
  final String label;
  final Color color;
  final StockData stock;
  final bool isBuy;

  const _OrderButton({
    required this.label,
    required this.color,
    required this.stock,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _OrderDialog.show(context, stock, isBuy),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ── Order Dialog ──────────────────────────────────────────────────────────────

class _OrderDialog extends StatefulWidget {
  final StockData stock;
  final bool isBuy;

  const _OrderDialog({required this.stock, required this.isBuy});

  static void show(BuildContext context, StockData stock, bool isBuy) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _OrderDialog(stock: stock, isBuy: isBuy),
    );
  }

  @override
  State<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<_OrderDialog> {
  int _qty = 1;

  Color get _accentColor =>
      widget.isBuy ? const Color(0xFF00C853) : const Color(0xFFD50000);

  double get _total => _qty * widget.stock.price;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.isBuy ? 'BUY' : 'SELL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.stock.symbol,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              '@ ₹${widget.stock.formattedPrice}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),

            const SizedBox(height: 24),

            const Text(
              'QUANTITY',
              style: TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () { if (_qty > 1) setState(() => _qty--); },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_qty',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _qty++),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Value',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                ),
                Text(
                  '₹${_total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.isBuy ? 'Bought' : 'Sold'} $_qty × ${widget.stock.symbol} @ ₹${widget.stock.formattedPrice}',
                          ),
                          backgroundColor: _accentColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Confirm ${widget.isBuy ? 'Buy' : 'Sell'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _StatItem {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.valueColor});
}