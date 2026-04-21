import 'package:flutter/material.dart';
import './stock.dart';
import './stock_list_tile.dart';

class SearchPage extends StatefulWidget {
  final List<StockData> stocks;

  const SearchPage({super.key, required this.stocks});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<StockData> _results = [];

  @override
  void initState() {
    super.initState();
    _results = widget.stocks;
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
        _results = widget.stocks;
      } else {
        _results = widget.stocks
            .where((s) => s.symbol.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Uses scaffoldBackgroundColor from your theme
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar at top
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  // In dark mode, use the elevated surface var;
                  // In light mode, use a light grey or the primary container
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
                        // Uses your new slate blue color for the cursor
                        cursorColor: theme.colorScheme.primary,
                        decoration: InputDecoration(
                          hintText: 'Search stocks...',
                          hintStyle: TextStyle(
                            color: theme.hintColor,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder:
                              InputBorder.none, // Override theme borders
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

            // Results list
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
                      itemBuilder: (context, index) =>
                          StockListTile(stock: _results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
