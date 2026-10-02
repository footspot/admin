import 'package:flutter/material.dart';

/// Final confirmation before linking a Footspot club to an Intersport shop.
/// Repeats BOTH names so the PDG re-reads the pairing one last time.
/// Returns true only if the PDG confirms.
class ConfirmLinkDialog extends StatelessWidget {
  const ConfirmLinkDialog({
    super.key,
    required this.clubName,
    required this.shopName,
    required this.mismatch,
  });

  final String clubName;
  final String shopName;

  // * When the names look different, the dialog leans red to slow the PDG down.
  final bool mismatch;

  static Future<bool> show(
    BuildContext context, {
    required String clubName,
    required String shopName,
    required bool mismatch,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => ConfirmLinkDialog(
            clubName: clubName,
            shopName: shopName,
            mismatch: mismatch,
          ),
    );
    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            mismatch ? Icons.warning_amber_rounded : Icons.link,
            color: mismatch ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('Confirm link')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mismatch) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Text(
                'The names do not appear to match. Double-check before linking.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
          ],
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, height: 1.4),
              children: [
                const TextSpan(text: 'Link the Footspot club '),
                TextSpan(
                  text: '« $clubName »',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' to the Intersport shop '),
                TextSpan(
                  text: '« $shopName »',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' ?'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This action is final.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirm & link'),
        ),
      ],
    );
  }
}
