import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class LogEntity {
  @Id()
  int id = 0;

  String message;
  String? stackTrace;

  @Property(type: PropertyType.date)
  DateTime timestamp;

  String level; // 'error', 'warning', 'info', 'debug'
  String? source; // optional: where the error occurred

  String get timestampFormat => DateFormat('EEE d MMM yy').format(timestamp);

  LogEntity({
    required this.message,
    this.stackTrace,
    this.level = 'error',
    this.source,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'Log id: $id\n\n MESSAGE: $message\n\n LEVEL: $level\n\n TIMESTAMP: $timestampFormat\n\n SOURCE: $source';
  }
}
