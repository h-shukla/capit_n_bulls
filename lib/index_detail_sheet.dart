import 'package:flutter/material.dart';
import './stock.dart';

class IndexDetailSheet extends StatelessWidget {
  final IndexData data;

  const IndexDetailSheet({super.key, required this.data});

  static void show(BuildContext context, IndexData data) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => IndexDetailSheet(data: data),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = data.isPositive;
    final color = isPositive ? const Color(0xFF00C853) : const Color(0xFFD50000);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
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
                                'NSE Index',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data.value,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositive
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    color: color,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    data.change,
                                    style: TextStyle(
                                      color: color,
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
                    Container(height: 1, color: const Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),

                    // ── Section label ──
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Stats grid ──
                    _StatsGrid(isPositive: isPositive),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ── Buy/Sell Bar ──
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _IndexOrderButton(
                        label: 'BUY',
                        color: const Color(0xFF00C853),
                        indexData: data,
                        isBuy: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IndexOrderButton(
                        label: 'SELL',
                        color: const Color(0xFFD50000),
                        indexData: data,
                        isBuy: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final bool isPositive;
  const _StatsGrid({required this.isPositive});

  static const _labelColor = Color(0xFF9E9E9E);
  static const _valueColor = Color(0xFF1A1A1A);
  static const _green = Color(0xFF00C853);
  static const _red = Color(0xFFD50000);

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(label: 'Open',       value: '19,950.00'),
      _StatItem(label: 'Prev Close', value: '19,900.00'),
      _StatItem(label: 'High',       value: '20,120.50', valueColor: _green),
      _StatItem(label: 'Low',        value: '19,890.25', valueColor: _red),
      _StatItem(label: '52W High',   value: '21,964.00', valueColor: _green),
      _StatItem(label: '52W Low',    value: '17,025.00', valueColor: _red),
    ];

    return Column(
      children: _buildRows(stats),
    );
  }

  List<Widget> _buildRows(List<_StatItem> items) {
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

    return rows;
  }

  Widget _statCell(_StatItem item) {
    return Column(
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
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });
}

// ── Order Button ──────────────────────────────────────────────────────────────

class _IndexOrderButton extends StatelessWidget {
  final String label;
  final Color color;
  final IndexData indexData;
  final bool isBuy;

  const _IndexOrderButton({
    required this.label,
    required this.color,
    required this.indexData,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _IndexOrderDialog.show(context, indexData, isBuy),
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

class _IndexOrderDialog extends StatefulWidget {
  final IndexData indexData;
  final bool isBuy;

  const _IndexOrderDialog({required this.indexData, required this.isBuy});

  static void show(BuildContext context, IndexData indexData, bool isBuy) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _IndexOrderDialog(indexData: indexData, isBuy: isBuy),
    );
  }

  @override
  State<_IndexOrderDialog> createState() => _IndexOrderDialogState();
}

class _IndexOrderDialogState extends State<_IndexOrderDialog> {
  int _qty = 1;

  Color get _accentColor =>
      widget.isBuy ? const Color(0xFF00C853) : const Color(0xFFD50000);

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
                  widget.indexData.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              '@ ${widget.indexData.value}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),

            const SizedBox(height: 24),

            const Text(
              'QUANTITY (LOTS)',
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
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700),
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
                const Text('Lots',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                Text(
                  '$_qty × 50 units',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
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
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A)),
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
                            '${widget.isBuy ? 'Bought' : 'Sold'} $_qty lot${_qty > 1 ? 's' : ''} of ${widget.indexData.name}',
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
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
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

// ── Qty Button (shared helper) ────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}