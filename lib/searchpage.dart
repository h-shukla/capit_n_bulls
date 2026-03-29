import 'package:capit_n_bulls/stock_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './stock.dart';

class SearchPage extends StatefulWidget {
  final List<StockData> stocks;

  const SearchPage({super.key, required this.stocks});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  // Auto-focus node so keyboard opens immediately
  final FocusNode _focusNode = FocusNode();
  List<StockData> _results = [];

  @override
  void initState() {
    super.initState();
    _results = widget.stocks;
    // Request focus after the first frame so keyboard pops up automatically
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar at top
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white60, fontSize: 16),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    // Show clear button when typing, search icon when empty
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
                              value.text.isNotEmpty ? Icons.close : Icons.search,
                              color: Colors.white,
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
                  ? const Center(
                child: Text(
                  'No results found',
                  style: TextStyle(color: Colors.grey),
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