import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fs_sa/presentation/utils/responsive.dart';
import 'package:fs_sa/presentation/widgets/infinite_scroll/list_infinite_scroll.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class GenericSearchBar<T> extends StatefulWidget {
  final ScrollController mainScrollController;
  final Future<List<T>> Function(String query) onSearch;
  final Widget Function(BuildContext context, T item, int index)
  mainItemBuilder;
  final PagingController<int, T> mainPagingController;
  final Widget Function(BuildContext context, T item, int index)
  searchItemBuilder;
  final String? hintText;
  final Duration debounceTime;
  final int minQueryLength;
  final Widget? emptyStateWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onSearchStart;
  final VoidCallback? onSearchEnd;
  final bool showSearchResults;

  const GenericSearchBar({
    super.key,
    required this.onSearch,
    required this.mainScrollController,
    required this.mainItemBuilder,
    required this.mainPagingController,
    required this.searchItemBuilder,
    this.hintText = 'Search...',
    this.debounceTime = const Duration(milliseconds: 300),
    this.minQueryLength = 1,
    this.emptyStateWidget,
    this.loadingWidget,
    this.errorWidget,
    this.onSearchStart,
    this.onSearchEnd,
    this.showSearchResults = true,
  });

  @override
  State<GenericSearchBar<T>> createState() => _GenericSearchBarState<T>();
}

class _GenericSearchBarState<T> extends State<GenericSearchBar<T>>
    with Responsive {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<T> _results = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSearching = false;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _results.clear();
        _isLoading = false;
        _hasError = false;
      });
      widget.onSearchEnd?.call();
      return;
    }

    if (query.length < widget.minQueryLength) {
      return;
    }

    if (!_isSearching) {
      setState(() {
        _isSearching = true;
      });
      widget.onSearchStart?.call();
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await widget.onSearch(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
      _results.clear();
      _isLoading = false;
      _hasError = false;
    });
    widget.onSearchEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isSearching)
          Expanded(
            child: InfiniteScrollList<T>(
              scrollController: widget.mainScrollController,
              pagingController: widget.mainPagingController,
              itemBuilder: widget.mainItemBuilder,
            ),
          ),

        if (_isSearching && widget.showSearchResults)
          Expanded(child: _buildSearchResults()),

        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            // onTapOutside:
            //     (event) => setState(() {
            //       if (_controller.text.isEmpty && _isSearching == true)
            //         _clearSearch();
            //     }),
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon:
                  _controller.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        // Search Results

        // Search Input
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return widget.loadingWidget ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (_hasError) {
      return widget.errorWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
    }

    if (_results.isEmpty) {
      return widget.emptyStateWidget ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, color: Colors.grey, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No results found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        return widget.searchItemBuilder(context, item, index);
      },
    );
  }
}
