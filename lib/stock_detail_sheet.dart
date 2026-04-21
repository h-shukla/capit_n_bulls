import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Color get _gainColor => const Color(0xFF3FD47E);
  Color get _lossColor => const Color(0xFFE05252);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final stock = widget.stock;
    final isPositive = stock.changePercent >= 0;
    final accentColor = isPositive ? _gainColor : _lossColor;

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
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
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
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    stock.exchange,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
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
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.15),
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
                      _divider(theme),
                      const SizedBox(height: 20),

                      _sectionLabel('TODAY', theme),
                      const SizedBox(height: 12),
                      _twoColumnGrid([
                        _StatItem(label: 'Open', value: '₹${_fmt(stock.open)}'),
                        _StatItem(
                          label: 'Close',
                          value: '₹${_fmt(stock.close)}',
                        ),
                        _StatItem(
                          label: 'High',
                          value: '₹${_fmt(stock.high)}',
                          valueColor: _gainColor,
                        ),
                        _StatItem(
                          label: 'Low',
                          value: '₹${_fmt(stock.low)}',
                          valueColor: _lossColor,
                        ),
                        _StatItem(
                          label: 'Volume',
                          value: stock.formattedVolume,
                        ),
                      ], theme),

                      const SizedBox(height: 8),
                      _divider(theme),
                      const SizedBox(height: 20),

                      _sectionLabel('CIRCUIT LIMITS', theme),
                      const SizedBox(height: 12),
                      _circuitBar(stock, theme),

                      const SizedBox(height: 24),
                      _divider(theme),
                      const SizedBox(height: 20),

                      _sectionLabel('52-WEEK RANGE', theme),
                      const SizedBox(height: 12),
                      _weekRangeBar(stock, theme),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // ── Sticky Buy/Sell Bar ──
                _BuySellBar(
                  stock: stock,
                  gainColor: _gainColor,
                  lossColor: _lossColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmt(double v) => v.toStringAsFixed(2);

  Widget _divider(ThemeData theme) =>
      Divider(height: 1, color: theme.dividerColor);

  Widget _sectionLabel(String label, ThemeData theme) => Text(
    label,
    style: theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );

  Widget _twoColumnGrid(List<_StatItem> items, ThemeData theme) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(child: _statCell(left, theme)),
              if (right != null) Expanded(child: _statCell(right, theme)),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _statCell(_StatItem item, ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        item.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        item.value,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: item.valueColor ?? theme.colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _circuitBar(StockData stock, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circuitLabel(
              'LC',
              '₹${_fmt(stock.lowerCircuit)}',
              _lossColor,
              theme,
            ),
            _circuitLabel(
              'UC',
              '₹${_fmt(stock.upperCircuit)}',
              _gainColor,
              theme,
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final range = stock.upperCircuit - stock.lowerCircuit;
            final ratio = ((stock.price - stock.lowerCircuit) / range).clamp(
              0.0,
              1.0,
            );
            final dotLeft = (constraints.maxWidth * ratio - 6).clamp(
              0.0,
              constraints.maxWidth - 12,
            );

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 3,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: dotLeft,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Current ₹${_fmt(stock.price)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _circuitLabel(
    String tag,
    String value,
    Color color,
    ThemeData theme,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _weekRangeBar(StockData stock, ThemeData theme) {
    final range = stock.week52High - stock.week52Low;
    final ratio = ((stock.price - stock.week52Low) / range).clamp(0.0, 1.0);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final dotLeft = (constraints.maxWidth * ratio - 6).clamp(
              0.0,
              constraints.maxWidth - 12,
            );
            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 3,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _lossColor.withValues(alpha: 0.6),
                            _gainColor.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: dotLeft,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _rangeLabel(
              '52W Low',
              '₹${_fmt(stock.week52Low)}',
              _lossColor,
              theme,
              CrossAxisAlignment.start,
            ),
            _rangeLabel(
              '52W High',
              '₹${_fmt(stock.week52High)}',
              _gainColor,
              theme,
              CrossAxisAlignment.end,
            ),
          ],
        ),
      ],
    );
  }

  Widget _rangeLabel(
    String label,
    String value,
    Color color,
    ThemeData theme,
    CrossAxisAlignment align,
  ) => Column(
    crossAxisAlignment: align,
    children: [
      Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

// ── Buy/Sell Bar ─────────────────────────────────────────────────────────────

class _BuySellBar extends StatelessWidget {
  final StockData stock;
  final Color gainColor;
  final Color lossColor;
  const _BuySellBar({
    required this.stock,
    required this.gainColor,
    required this.lossColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderButton(
              label: 'BUY',
              color: gainColor,
              stock: stock,
              isBuy: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _OrderButton(
              label: 'SELL',
              color: lossColor,
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

/// Result model returned after a successful API call.
class _OrderResult {
  final bool success;
  final String message;
  const _OrderResult({required this.success, required this.message});
}

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
  // ── Order fields ──────────────────────────────────────────────────────────
  int _qty = 1;

  /// Product type: MIS (intraday) or NRML (carry-forward).
  String _productType = 'MIS';

  /// Whether the user wants a Limit order (shows price field) or Market order.
  bool _isLimitOrder = false;

  /// Limit price controller – only used when [_isLimitOrder] is true.
  final TextEditingController _limitPriceCtrl = TextEditingController();

  // ── API state ─────────────────────────────────────────────────────────────
  bool _isLoading = false;

  // ── Derived ───────────────────────────────────────────────────────────────
  Color get _accentColor =>
      widget.isBuy ? const Color(0xFF3FD47E) : const Color(0xFFE05252);

  double get _effectivePrice => _isLimitOrder && _limitPriceCtrl.text.isNotEmpty
      ? double.tryParse(_limitPriceCtrl.text) ?? widget.stock.price
      : widget.stock.price;

  double get _total => _qty * _effectivePrice;

  @override
  void initState() {
    super.initState();
    _limitPriceCtrl.text = widget.stock.price.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _limitPriceCtrl.dispose();
    super.dispose();
  }

  // ── API call ──────────────────────────────────────────────────────────────

  Future<_OrderResult> _placeOrder() async {
    final stock = widget.stock;
    final side = widget.isBuy ? 'BUY' : 'SELL';

    final body = {
      'user_id': 'user_42',
      'contract_name': stock.symbol, // e.g. "NIFTY2550018000CE"
      'exchange_token': stock.companyName, // e.g. "35001"
      'qty': _qty,
      'side': side,
      'order_type': 'NRML', // always NRML – non-editable
      'product_type': _isLimitOrder ? 'LIMIT' : 'MARKET',
    };

    // Include limit price only for limit orders
    if (_isLimitOrder) {
      body['price'] = _effectivePrice;
    }

    try {
      final response = await http
          .post(
            Uri.parse('http://69.62.75.117:8765/orders'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const _OrderResult(
          success: true,
          message: 'Order placed successfully',
        );
      } else {
        // Try to parse error from body
        String errorMsg = 'Server error (${response.statusCode})';
        try {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          if (decoded.containsKey('message')) {
            errorMsg = decoded['message'] as String;
          } else if (decoded.containsKey('error')) {
            errorMsg = decoded['error'] as String;
          }
        } catch (_) {
          // Keep the default message
        }
        return _OrderResult(success: false, message: errorMsg);
      }
    } on http.ClientException catch (e) {
      return _OrderResult(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return _OrderResult(success: false, message: 'Unexpected error: $e');
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    final result = await _placeOrder();

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 👇 Capture root context BEFORE popping
    final messenger = ScaffoldMessenger.of(context);

    Navigator.of(context).pop();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.success
                    ? '${widget.isBuy ? 'Buy' : 'Sell'} order for $_qty × ${widget.stock.symbol} placed'
                    : result.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: result.success
            ? _accentColor
            : const Color(0xFFE05252),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colorScheme.surface,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.stock.symbol,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                'LTP ₹${widget.stock.formattedPrice}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 16),

              // ── QUANTITY ─────────────────────────────────────────────────
              _dialogLabel('QUANTITY', theme),
              const SizedBox(height: 10),
              Row(
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_qty > 1) setState(() => _qty--);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_qty',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
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

              // ── ORDER TYPE (non-editable NRML) ────────────────────────────
              _dialogLabel('ORDER TYPE', theme),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'NRML',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Fixed',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── PRODUCT TYPE ──────────────────────────────────────────────
              _dialogLabel('PRODUCT TYPE', theme),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ToggleChip(
                    label: 'MIS',
                    subtitle: 'Intraday',
                    selected: _productType == 'MIS',
                    selectedColor: _accentColor,
                    onTap: () => setState(() => _productType = 'MIS'),
                    theme: theme,
                  ),
                  const SizedBox(width: 10),
                  _ToggleChip(
                    label: 'CNC',
                    subtitle: 'Delivery',
                    selected: _productType == 'CNC',
                    selectedColor: _accentColor,
                    onTap: () => setState(() => _productType = 'CNC'),
                    theme: theme,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── PRICE TYPE ────────────────────────────────────────────────
              _dialogLabel('PRICE TYPE', theme),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ToggleChip(
                    label: 'Market',
                    subtitle: 'At LTP',
                    selected: !_isLimitOrder,
                    selectedColor: _accentColor,
                    onTap: () => setState(() => _isLimitOrder = false),
                    theme: theme,
                  ),
                  const SizedBox(width: 10),
                  _ToggleChip(
                    label: 'Limit',
                    subtitle: 'Custom',
                    selected: _isLimitOrder,
                    selectedColor: _accentColor,
                    onTap: () => setState(() => _isLimitOrder = true),
                    theme: theme,
                  ),
                ],
              ),

              // ── LIMIT PRICE (visible only for limit orders) ───────────────
              if (_isLimitOrder) ...[
                const SizedBox(height: 16),
                _dialogLabel('LIMIT PRICE', theme),
                const SizedBox(height: 8),
                TextField(
                  controller: _limitPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _accentColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 12),

              // ── TOTAL VALUE ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Est. Total',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '₹${_total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── ACTION BUTTONS ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _handleConfirm,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? _accentColor.withValues(alpha: 0.6)
                              : _accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Confirm ${widget.isBuy ? 'Buy' : 'Sell'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogLabel(String label, ThemeData theme) => Text(
    label,
    style: theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}

// ── Toggle Chip ───────────────────────────────────────────────────────────────

class _ToggleChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ToggleChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? selectedColor
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? selectedColor : colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: selected
                      ? selectedColor.withValues(alpha: 0.7)
                      : colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Qty Button ────────────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: colorScheme.onSurface),
      ),
    );
  }
}

// ── Stat Item ─────────────────────────────────────────────────────────────────

class _StatItem {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.valueColor});
}
