import 'package:flutter/material.dart';
import 'stock.dart';
import 'stock_detail_sheet.dart';

class StockListTile extends StatelessWidget {
  final StockData stock;
  const StockListTile({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.changePercent >= 0;
    final color = isPositive ? const Color(0xFF00C853) : const Color(0xFFD50000);
    final changeText =
        '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%';

    return InkWell(
      onTap: () => StockDetailSheet.show(context, stock),   // ← tap handler
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stock.symbol,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(stock.exchange,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(stock.price.toStringAsFixed(2),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: color,
                      size: 13,
                    ),
                    Text(changeText,
                        style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}