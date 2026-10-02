import 'package:flutter/material.dart';
import 'package:fs_sa/data/services/intersport_service.dart';
import 'package:fs_sa/presentation/features/home/intersport/intersport_controller.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/partner_secrets_dialog.dart';

class AddPartnerDialog extends StatefulWidget {
  const AddPartnerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AddPartnerDialog(),
    );
  }

  @override
  State<AddPartnerDialog> createState() => _AddPartnerDialogState();
}

class _AddPartnerDialogState extends State<AddPartnerDialog> {
  final _name = TextEditingController();
  final _region = TextEditingController();
  final _baseUrl = TextEditingController();
  final _shopUrlPrefix = TextEditingController();

  bool _submitting = false;
  String? _error;

  bool get _isValid =>
      _name.text.trim().isNotEmpty &&
      _region.text.trim().isNotEmpty &&
      _baseUrl.text.trim().isNotEmpty &&
      _shopUrlPrefix.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _region.dispose();
    _baseUrl.dispose();
    _shopUrlPrefix.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await intersportService.createPartner(
      name: _name.text.trim(),
      region: _region.text.trim(),
      baseUrl: _baseUrl.text.trim(),
      shopUrlPrefix: _shopUrlPrefix.text.trim(),
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _submitting = false;
        _error = 'Failed to create partner. Check the logs tab for details.';
      });
      return;
    }

    intersportCtrler.addPartnerLocally(result.partner);

    // * Close the form dialog, then show the secrets dialog on top.
    Navigator.of(context).pop();
    await PartnerSecretsDialog.show(
      context,
      partnerName: result.partner.name,
      partnerId: result.partner.id,
      hmacSecret: result.hmacSecret,
      shopToken: result.shopToken,
    );

    // * Refetch canonical state (with linked_clubs_count etc.)
    await intersportCtrler.refreshPartners();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Intersport partner'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              _name,
              label: 'Name',
              hint: 'Intersport IDF',
            ),
            _field(
              _region,
              label: 'Region',
              hint: 'Île-de-France',
            ),
            _field(
              _baseUrl,
              label: 'Base URL',
              hint: 'https://idf.intersport.fr/functions/v1',
            ),
            // * Public club-page URL prefix — the full club URL is this prefix
            // * + the club UUID (e.g. ".../?club=<uuid>"), so include the
            // * trailing separator. Flow 1 matches a pasted URL to its partner
            // * by this prefix; stored verbatim by intersport-pdg-create-partner.
            _field(
              _shopUrlPrefix,
              label: 'Shop URL prefix',
              hint: 'https://idf.intersport.fr/?club=',
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting || !_isValid ? null : _submit,
          child:
              _submitting
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Create'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController c, {
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
