import 'package:flutter/material.dart';

/// Captures a required rejection reason. Returns the trimmed string, or null
/// if the user cancelled. The confirm button stays disabled until a reason is
/// entered.
class RejectReasonDialog extends StatefulWidget {
  const RejectReasonDialog({super.key, required this.clubName});

  final String clubName;

  static Future<String?> show(
    BuildContext context, {
    required String clubName,
  }) {
    return showDialog<String?>(
      context: context,
      builder: (_) => RejectReasonDialog(clubName: clubName),
    );
  }

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // * Re-evaluate the confirm button's enabled state as the PDG types.
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasReason = _ctrl.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Reject request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are about to reject the integration request from ${widget.clubName}.',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Reason (required)',
              hintText: 'Visible to the director.',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed:
              hasReason
                  ? () => Navigator.of(context).pop(_ctrl.text.trim())
                  : null,
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
