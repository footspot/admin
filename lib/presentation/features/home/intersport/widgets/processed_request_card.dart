import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/legacy/intersport_pending_request.dart';
import 'package:intl/intl.dart';

// * Read-only card for the History tab: a past integration decision
// * (accepted or rejected). No action buttons — this is an audit view for the
// * PDG to see what was done previously.
class ProcessedRequestCard extends StatelessWidget {
  const ProcessedRequestCard({super.key, required this.request});

  final IntersportPendingRequest request;

  bool get _isAccepted => request.status == 'accepted';

  Color get _statusColor => _isAccepted ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.club?.name ?? 'Club #${r.clubId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusBadge(),
              ],
            ),
            const SizedBox(height: 8),
            if (r.partner != null) _line('Partner', r.partner!.name),
            _line('Intersport club', r.intersportClubName),
            _line('Requester', r.requester?.displayName ?? '—'),
            _line(
              'Requested at',
              DateFormat('d MMM yyyy, HH:mm').format(r.requestedAt),
            ),
            if (r.processedAt != null)
              _line(
                _isAccepted ? 'Accepted at' : 'Rejected at',
                DateFormat('d MMM yyyy, HH:mm').format(r.processedAt!),
              ),
            if (!_isAccepted &&
                r.rejectedReason != null &&
                r.rejectedReason!.isNotEmpty)
              _line('Reason', r.rejectedReason!),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isAccepted ? Icons.check : Icons.close,
            color: _statusColor,
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            _isAccepted ? 'Accepted' : 'Rejected',
            style: TextStyle(
              color: _statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              k,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(v, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
