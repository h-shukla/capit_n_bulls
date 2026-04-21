import 'package:flutter/material.dart';

class MarginPosition {
  final String symbolName;
  final String symbolCode;
  final int qty;
  final double avgPrice;
  final double ltp;

  const MarginPosition({
    required this.symbolName,
    required this.symbolCode,
    required this.qty,
    required this.avgPrice,
    required this.ltp,
  });
}

final List<MarginPosition> _mockPositions = [
  MarginPosition(
    symbolName: 'AAPL',
    symbolCode: 'AAPL',
    qty: 20,
    avgPrice: 160.20,
    ltp: 165.20,
  ),
  MarginPosition(
    symbolName: 'TSLA',
    symbolCode: 'TSAL',
    qty: 15,
    avgPrice: 163.30,
    ltp: 165.20,
  ),
  MarginPosition(
    symbolName: 'SBIN',
    symbolCode: 'SBIN',
    qty: 5,
    avgPrice: 130.30,
    ltp: 165.20,
  ),
  MarginPosition(
    symbolName: 'GOOGLE',
    symbolCode: 'GOOG',
    qty: 15,
    avgPrice: 140.20,
    ltp: 165.20,
  ),
  MarginPosition(
    symbolName: 'HDFCBANK',
    symbolCode: 'HDFCBNK',
    qty: 20,
    avgPrice: 155.10,
    ltp: 165.20,
  ),
  MarginPosition(
    symbolName: 'RELIANCE',
    symbolCode: 'RELIANCE',
    qty: 12,
    avgPrice: 165.00,
    ltp: 165.20,
  ),
];

const double _availableMargin = 12500;
const double _usedMargin = 7500;
const double _totalMargin = 20000;

class MarginScreen extends StatelessWidget {
  const MarginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final utilization = _usedMargin / _totalMargin;

    // Theme colors
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white10 : const Color(0xFFE5E5E7);
    final headerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF4F4F5);
    final primaryTextColor = isDark ? Colors.white : Colors.black;

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Margin summary card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MarginRow(
                    label: 'Available Margin',
                    value: '₹${_fmt(_availableMargin)}',
                  ),
                  const SizedBox(height: 12),
                  _MarginRow(
                    label: 'Used Margin',
                    value: '₹${_fmt(_usedMargin)}',
                  ),
                  const SizedBox(height: 12),
                  _MarginRow(
                    label: 'Total Margin',
                    value: '₹${_fmt(_totalMargin)}',
                  ),
                  const SizedBox(height: 20),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: utilization,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.white10
                          : const Color(0xFFE5E5E7),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark
                            ? const Color(0xFF81C784)
                            : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Margin Utilization row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Margin Utilization',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${(utilization * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Positions table card ──
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(12),
                  color: cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Positions" header
                    Container(
                      width: double.infinity,
                      color: headerColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        'Positions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: borderColor),

                    // Column headers
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          _PosHeaderCell(label: 'Symbol', flex: 3),
                          _PosHeaderCell(label: 'Qty', flex: 2),
                          _PosHeaderCell(label: 'Avg. Price', flex: 3),
                          _PosHeaderCell(
                            label: 'LTP',
                            flex: 2,
                            align: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: borderColor),

                    // Position rows
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mockPositions.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, thickness: 1, color: borderColor),
                      itemBuilder: (context, index) {
                        return _PositionRow(position: _mockPositions[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

class _MarginRow extends StatelessWidget {
  final String label;
  final String value;

  const _MarginRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey.shade400 : Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PosHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;

  const _PosHeaderCell({
    required this.label,
    required this.flex,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  final MarginPosition position;

  const _PositionRow({required this.position});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Symbol
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.symbolName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  position.symbolCode,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),

          // Qty
          Expanded(
            flex: 2,
            child: Text(
              '${position.qty}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Avg. Price
          Expanded(
            flex: 3,
            child: Text(
              '₹${position.avgPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // LTP
          Expanded(
            flex: 2,
            child: Text(
              '₹${position.ltp.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
