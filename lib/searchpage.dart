import 'package:capit_n_bulls/index_detail_sheet.dart';
import 'package:capit_n_bulls/providers/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './stock.dart';
import './stock_list_tile.dart';

class SearchPage extends ConsumerStatefulWidget {
  final List<StockData> stocks;
  final List<IndexData> indices;

  const SearchPage({super.key, required this.stocks, this.indices = const []});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<dynamic> _results = []; // StockData or IndexData

  @override
  void initState() {
    super.initState();

    _results = [...widget.stocks, ...widget.indices];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = [...widget.stocks, ...widget.indices];
      } else {
        final lowerQuery = query.toLowerCase();

        final filteredStocks = widget.stocks
            .where((s) => s.symbol.toLowerCase().contains(lowerQuery))
            .toList();

        final filteredIndices = widget.indices
            .where((i) => i.name.toLowerCase().contains(lowerQuery))
            .toList();

        _results = [...filteredStocks, ...filteredIndices];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final watchlistAsync = ref.watch(watchlistProvider);
    final watchlistSymbols = watchlistAsync.value ?? {};

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: theme.dividerColor) : null,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        cursorColor: theme.colorScheme.primary,
                        decoration: InputDecoration(
                          hintText: 'Search stocks...',
                          hintStyle: TextStyle(
                            color: theme.hintColor,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, value, _) {
                        return GestureDetector(
                          onTap: value.text.isNotEmpty
                              ? () {
                                  _controller.clear();
                                  _onChanged('');
                                }
                              : () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              value.text.isNotEmpty
                                  ? Icons.close
                                  : Icons.search,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Results ──────────────────────────────────────────────────
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];

                        // ── STOCK ────────────────────────────────────────
                        if (result is StockData) {
                          final stock = result;

                          final isInWatchlist = watchlistSymbols.contains(
                            stock.symbol,
                          );

                          return Row(
                            children: [
                              Expanded(child: StockListTile(stock: stock)),

                              GestureDetector(
                                onTap: () async {
                                  final notifier = ref.read(
                                    watchlistProvider.notifier,
                                  );

                                  if (isInWatchlist) {
                                    await notifier.remove(stock.symbol);
                                  } else {
                                    await notifier.add(stock.symbol);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isInWatchlist
                                        ? Icon(
                                            Icons.check_circle,
                                            key: const ValueKey('added'),
                                            color: theme.colorScheme.primary,
                                            size: 26,
                                          )
                                        : Icon(
                                            Icons.add_circle_outline,
                                            key: const ValueKey('add'),
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black45,
                                            size: 26,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // ── INDEX ────────────────────────────────────────
                        final indexData = result as IndexData;

                        return GestureDetector(
                          onTap: () =>
                              IndexDetailSheet.show(context, indexData),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        indexData.name,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        'Open: ${indexData.open} | High: ${indexData.high} | Low: ${indexData.low}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      indexData.value,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      indexData.change,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: indexData.isPositive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
