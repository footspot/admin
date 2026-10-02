// // Generic Infinite Scroll Grid
// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// class InfiniteScrollGrid<T> extends StatefulWidget {
//   final PagingController<int, T> pagingController;
//   final Future<List<T>> Function(int pageKey) onFetchPage;
//   final Widget Function(BuildContext context, T item, int index) itemBuilder;
//   final SliverGridDelegate gridDelegate;
//   final int pageSize;
//   final EdgeInsetsGeometry? padding;

//   const InfiniteScrollGrid({
//     super.key,
//     required this.pagingController,
//     required this.onFetchPage,
//     required this.itemBuilder,
//     required this.gridDelegate,
//     this.pageSize = 20,
//     this.padding,
//   });

//   @override
//   State<InfiniteScrollGrid<T>> createState() => _InfiniteScrollGridState<T>();
// }

// class _InfiniteScrollGridState<T> extends State<InfiniteScrollGrid<T>> {
//   @override
//   void initState() {
//     super.initState();
//     widget.pagingController.addPageRequestListener(_fetchPage);
//   }

//   @override
//   void dispose() {
//     widget.pagingController.removePageRequestListener(_fetchPage);
//     super.dispose();
//   }

//   Future<void> _fetchPage(int pageKey) async {
//     try {
//       final newItems = await widget.onFetchPage(pageKey);
//       final isLastPage = newItems.length < widget.pageSize;

//       if (isLastPage) {
//         widget.pagingController.appendLastPage(newItems);
//       } else {
//         final nextPageKey = pageKey + 1;
//         widget.pagingController.appendPage(newItems, nextPageKey);
//       }
//     } catch (error) {
//       widget.pagingController.error = error;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PagedGridView<int, T>(
//       pagingController: widget.pagingController,
//       gridDelegate: widget.gridDelegate,
//       padding: widget.padding,
//       builderDelegate: PagedChildBuilderDelegate<T>(
//         itemBuilder: widget.itemBuilder,
//       ),
//     );
//   }
// }
