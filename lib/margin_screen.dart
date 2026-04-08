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
  MarginPosition(symbolName: 'AAPL', symbolCode: 'AAPL', qty: 20, avgPrice: 160.20, ltp: 165.20),
  MarginPosition(symbolName: 'TSLA', symbolCode: 'TSAL', qty: 15, avgPrice: 163.30, ltp: 165.20),
  MarginPosition(symbolName: 'SBIN', symbolCode: 'SBIN', qty: 5, avgPrice: 130.30, ltp: 165.20),
  MarginPosition(symbolName: 'GOOGLE', symbolCode: 'GOOG', qty: 15, avgPrice: 140.20, ltp: 165.20),
  MarginPosition(symbolName: 'HDFCBANK', symbolCode: 'HDFCBNK', qty: 20, avgPrice: 155.10, ltp: 165.20),
  MarginPosition(symbolName: 'RELIANCE', symbolCode: 'RELIANCE', qty: 12, avgPrice: 165.00, ltp: 165.20)
];

const double _availableMargin = 12500;
const double _usedMargin = 7500;
const double _totalMargin = 20000;

class MarginScreen extends StatelessWidget {
  const MarginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final utilization = _usedMargin / _totalMargin;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Margin summary card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5E7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MarginRow(label: 'Available Margin', value: '₹${_fmt(_availableMargin)}'),
                const SizedBox(height: 12),
                _MarginRow(label: 'Used Margin', value: '₹${_fmt(_usedMargin)}'),
                const SizedBox(height: 12),
                _MarginRow(label: 'Total Margin', value: '₹${_fmt(_totalMargin)}'),
                const SizedBox(height: 16),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: utilization,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E5E7),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                ),
                const SizedBox(height: 12),

                // Margin Utilization row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Margin Utilization',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${(utilization * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Positions table card ──
          ClipRRect(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Positions" header
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE5E5E7),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: const Text(
                      'Positions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: const Color(0xFFE5E5E7)),

                  // Column headers
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        _PosHeaderCell(label: 'Symbol', flex: 3),
                        _PosHeaderCell(label: 'Qty', flex: 2),
                        _PosHeaderCell(label: 'Avg. Price', flex: 3),
                        _PosHeaderCell(label: 'LTP', flex: 2, align: TextAlign.right),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: const Color(0xFFE5E5E7)),

                  // Position rows
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mockPositions.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E7)),
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
    );
  }

  String _fmt(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PosHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;

  const _PosHeaderCell({required this.label, required this.flex, this.align = TextAlign.left});

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
          color: Colors.grey.shade600,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                Text(
                  position.symbolCode,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

          // Qty
          Expanded(
            flex: 2,
            child: Text(
              '${position.qty}',
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),

          // Avg. Price
          Expanded(
            flex: 3,
            child: Text(
              '₹${position.avgPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),

          // LTP
          Expanded(
            flex: 2,
            child: Text(
              '₹${position.ltp.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}