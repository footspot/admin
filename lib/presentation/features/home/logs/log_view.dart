import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/objectbox/log.dart';
import 'package:fs_sa/data/services/local/log_local.dart';
import 'package:fs_sa/presentation/features/home/logs/log_controller.dart';
import 'package:fs_sa/presentation/utils/responsive.dart';
import 'package:fs_sa/presentation/widgets/infinite_scroll/list_infinite_scroll.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> with Responsive {
  final List<String> _levels = ['all', 'error', 'warning', 'info', 'debug'];

  @override
  void initState() {
    super.initState();
  }

  void _filterByLevel(String level) {
    setState(() {
      logCtrler.selectedLevel = level;
    });
    logCtrler.paginationController.refresh();
  }

  Future<void> _clearAllLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Logs'),
            content: const Text(
              'Are you sure you want to delete all error logs? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete All'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await logLocal.clearAllLogs();

      logCtrler.paginationController.refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All logs cleared successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterByLevel,
            itemBuilder:
                (context) =>
                    _levels.map((level) {
                      return PopupMenuItem<String>(
                        value: level,
                        child: Row(
                          children: [
                            if (logCtrler.selectedLevel == level)
                              const Icon(Icons.check, size: 16),
                            if (logCtrler.selectedLevel == level)
                              const SizedBox(width: 8),
                            Text(level.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
            child: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _clearAllLogs,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All Logs',
          ),
        ],
      ),
      body: InfiniteScrollList<LogEntity>(
        scrollController: ScrollController(),
        pagingController: logCtrler.paginationController,
        itemBuilder: (context, log, index) {
          return _buildLogItem(log);
        },
      ),
    );
  }

  Widget _buildLogItem(LogEntity log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: _buildLevelIcon(log.level),
        title: Text(
          'Log #${log.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.message, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(log.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),

        trailing: Column(
          children: [
            IconButton(
              icon: Icon(
                Icons.share,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed:
                  () => SharePlus.instance.share(
                    ShareParams(
                      title: 'Share',
                      subject: log.level,
                      text: log.toString(),
                    ),
                  ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', log.id.toString()),
                _buildDetailRow('Level', log.level.toUpperCase()),
                _buildDetailRow('Timestamp', _formatTimestamp(log.timestamp)),
                if (log.source != null) _buildDetailRow('Source', log.source!),
                const SizedBox(height: 8),
                const Text(
                  'Message:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    log.message,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ),
                if (log.stackTrace != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Stack Trace:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.stackTrace!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  width: widthScreen,
                  child: ElevatedButton(
                    onPressed: () async {
                      await logLocal.deleteErrorLog(log.id);
                      setState(() {
                        logCtrler.paginationController.refresh();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('DELETE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildLevelIcon(String level) {
    IconData icon;
    Color color;

    switch (level.toLowerCase()) {
      case 'error':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'warning':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'info':
        icon = Icons.info;
        color = Colors.blue;
        break;
      case 'debug':
        icon = Icons.bug_report;
        color = Colors.green;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${DateFormat('EEE d MMM yy, hh:mm a').format(now)}  (${difference.inDays}d ago)';
    } else if (difference.inHours > 0) {
      return '${DateFormat('EEE d MMM yy, hh:mm a').format(now)}  (${difference.inHours}h ago)';
    } else if (difference.inMinutes > 0) {
      return '${DateFormat('EEE d MMM yy, hh:mm a').format(now)}  (${difference.inMinutes}m ago)';
    } else {
      return DateFormat('EEE d MMM yy, hh:mm a').format(now);
    }
  }

  // @override
  // void dispose() {
  //   logCtrler.paginationController.dispose();
  //   super.dispose();
  // }
}
