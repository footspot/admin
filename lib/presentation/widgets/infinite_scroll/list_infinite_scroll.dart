import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// Generic Infinite Scroll List
class InfiniteScrollList<T> extends StatefulWidget {
  final PagingController<int, T> pagingController;
  final ScrollController scrollController;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? firstPageErrorIndicator;
  final Widget? newPageErrorIndicator;
  final Widget? firstPageProgressIndicator;
  final Widget? newPageProgressIndicator;
  final Widget? noItemsFoundIndicator;
  final Widget? noMoreItemsIndicator;

  const InfiniteScrollList({
    super.key,
    required this.scrollController,
    required this.pagingController,
    required this.itemBuilder,
    this.firstPageErrorIndicator,
    this.newPageErrorIndicator,
    this.firstPageProgressIndicator,
    this.newPageProgressIndicator,
    this.noItemsFoundIndicator,
    this.noMoreItemsIndicator,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: widget.pagingController,
      builder:
          (context, state, fetchNextPage) => RefreshIndicator(
            onRefresh:
                () => Future.sync(() => widget.pagingController.refresh()),
            child: PagedListView<int, T>(
              scrollController: widget.scrollController,
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<T>(
                itemBuilder: widget.itemBuilder,
                newPageErrorIndicatorBuilder:
                    (context) =>
                        widget.newPageErrorIndicator ??
                        _buildNewPageError(context),
                firstPageErrorIndicatorBuilder:
                    (context) =>
                        widget.firstPageErrorIndicator ??
                        _buildFirstPageError(context),
                firstPageProgressIndicatorBuilder:
                    (context) =>
                        widget.firstPageProgressIndicator ??
                        _buildFirstPageProgress(),
                newPageProgressIndicatorBuilder:
                    (context) =>
                        widget.newPageProgressIndicator ??
                        _buildNewPageProgress(),
                noItemsFoundIndicatorBuilder:
                    (context) =>
                        widget.noItemsFoundIndicator ?? _buildNoItemsFound(),
                noMoreItemsIndicatorBuilder:
                    (context) =>
                        widget.noMoreItemsIndicator ?? _buildNoMoreItems(),
              ),
            ),
          ),
    );
  }

  Widget _buildFirstPageError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.pagingController.refresh(),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPageError(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(height: 8),
          Text(
            'Failed to load more items',
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFirstPageProgress() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildNewPageProgress() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNoItemsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreItems() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No more items to load',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
