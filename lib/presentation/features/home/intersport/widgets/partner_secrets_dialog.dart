import 'package:flutter/material.dart';

import 'package:fs_sa/core/utils/secure_clipboard.dart';

/// One-time display of a newly created partner's HMAC secret + shop token.
/// The values are NEVER persisted on this side; the PDG must copy them now
/// and share with the partner Intersport region's tech team.
class PartnerSecretsDialog extends StatelessWidget {
  const PartnerSecretsDialog({
    super.key,
    required this.partnerName,
    required this.partnerId,
    required this.hmacSecret,
    required this.shopToken,
  });

  final String partnerName;
  final String partnerId;
  final String hmacSecret;
  final String shopToken;

  static Future<void> show(
    BuildContext context, {
    required String partnerName,
    required String partnerId,
    required String hmacSecret,
    required String shopToken,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PartnerSecretsDialog(
            partnerName: partnerName,
            partnerId: partnerId,
            hmacSecret: hmacSecret,
            shopToken: shopToken,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.shield, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(child: Text('Secrets — shown ONCE')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                'Copy these secrets and send them to the partner\'s tech team via a secure channel. They will NEVER be shown again.',
                style: TextStyle(color: Colors.orange[200], fontSize: 12),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              partnerName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 14),
            _secretRow(context, 'Partner ID', partnerId),
            const SizedBox(height: 8),
            _secretRow(context, 'HMAC secret', hmacSecret),
            const SizedBox(height: 8),
            _secretRow(context, 'Shop token', shopToken),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('I\'ve copied them'),
        ),
      ],
    );
  }

  Widget _secretRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () async {
                  await SecureClipboard.copy(value);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied to clipboard'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
