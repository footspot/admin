import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final logCtrler = ErrorLogController();

class ErrorLogController {
  static final ErrorLogController _singleton =
      ErrorLogController._privateConstructor();
  factory ErrorLogController() => _singleton;
  ErrorLogController._privateConstructor() {
    paginationController = PagingController(
      getNextPageKey:
          (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: fetchPage,
    );
  }

  late final PagingController<int, LogEntity> paginationController;

  static const _pageSize = 20;

  int totalItem = -1;

  String selectedLevel = 'all';

  Future<List<LogEntity>> fetchPage(int pageKey) async {
    try {
      if (!paginationController.value.hasNextPage) return [];

      if (totalItem == -1) totalItem = logLocal.getTotalCount();

      if (totalItem == paginationController.items?.length) return [];

      return selectedLevel == 'all'
          ? logLocal.getErrorLogs(offset: (pageKey - 1), limit: _pageSize)
          : logLocal.getErrorLogsByLevel(
            selectedLevel,
            offset: (pageKey - 1),
            limit: _pageSize,
          );
    } catch (error) {
      return [];
    }
  }
}
