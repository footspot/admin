import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/object_box_service.dart';
import 'package:fs_sa/objectbox.g.dart';

final logLocal = LogRepository();

class LogRepository {
  final ObjectBoxService _instance = ObjectBoxService.instance;

  Box<LogEntity> get _logBox => _instance.logBox;

  // Create - Add new error log
  Future<int> addLog(LogEntity log) async {
    return _logBox.put(log);
  }

  int getTotalCount() {
    return _logBox.count();
  }

  // Read - Get all logs with pagination
  List<LogEntity> getErrorLogs({int offset = 0, int limit = 20}) {
    final query =
        _logBox
            .query()
            .order(LogEntity_.timestamp, flags: Order.descending)
            .build();

    final results = query.find();
    query.close();

    if (offset >= results.length) return [];

    final endIndex =
        (offset + limit) > results.length ? results.length : offset + limit;

    return results.sublist(offset, endIndex);
  }

  // Read - Get single log by ID
  LogEntity? getErrorLogById(int id) {
    return _logBox.get(id);
  }

  // Read - Get logs by level
  List<LogEntity> getErrorLogsByLevel(
    String level, {
    int offset = 0,
    int limit = 20,
  }) {
    final query =
        _logBox
            .query(LogEntity_.level.equals(level))
            .order(LogEntity_.timestamp, flags: Order.descending)
            .build();

    final results = query.find();
    query.close();

    if (offset >= results.length) return [];

    final endIndex =
        (offset + limit) > results.length ? results.length : offset + limit;

    return results.sublist(offset, endIndex);
  }

  // Update - Update existing log
  Future<void> updateErrorLog(LogEntity log) async {
    _logBox.put(log);
  }

  // Delete - Delete specific log
  Future<bool> deleteErrorLog(int id) async {
    return _logBox.remove(id);
  }

  // Delete - Clear all logs
  Future<int> clearAllLogs() async {
    return _logBox.removeAll();
  }

  // Delete - Delete logs older than specified days
  Future<int> deleteOldLogs(int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final query =
        _logBox
            .query(
              LogEntity_.timestamp.lessThan(cutoffDate.millisecondsSinceEpoch),
            )
            .build();

    final oldLogs = query.find();
    query.close();

    if (oldLogs.isEmpty) return 0;

    final idsToRemove = oldLogs.map((log) => log.id).toList();
    _logBox.removeMany(idsToRemove);

    return oldLogs.length;
  }
}
