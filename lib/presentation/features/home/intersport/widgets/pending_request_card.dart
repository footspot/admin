import 'package:flutter/material.dart';
import 'package:fs_sa/core/utils/club_name_match.dart';
import 'package:fs_sa/data/models/legacy/intersport_pending_request.dart';
import 'package:fs_sa/data/services/intersport_service.dart';
import 'package:fs_sa/presentation/features/home/clubs/clubs_controller.dart';
import 'package:fs_sa/presentation/features/home/intersport/intersport_controller.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/confirm_link_dialog.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/crest_avatar.dart';
import 'package:fs_sa/presentation/features/home/intersport/widgets/reject_reason_dialog.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Verify integration" card: a side-by-side comparison of the Footspot club
/// vs the Intersport shop being linked, so the PDG can catch a mismatched
/// pairing before accepting a Flow-1 request.
class PendingRequestCard extends StatefulWidget {
  const PendingRequestCard({super.key, required this.request});

  final IntersportPendingRequest request;

  @override
  State<PendingRequestCard> createState() => _PendingRequestCardState();
}

class _PendingRequestCardState extends State<PendingRequestCard> {
  bool _busy = false;

  // * Club-logo URL via the app's club-docs storage builder, or null.
  String? get _clubLogoUrl {
    final path = widget.request.club?.logoPath;
    if (path == null || path.isEmpty) return null;
    final url = clubsCtrler.getClubLogoUrl(path);
    return url.isEmpty ? null : url;
  }

  bool get _namesMatch => ClubNameMatch.isMatch(
        widget.request.club?.name,
        widget.request.intersportClubName,
      );

  Future<void> _accept() async {
    final r = widget.request;
    final clubName = r.club?.name ?? 'Club #${r.clubId}';

    // * Final confirmation that repeats both names before the definitive link.
    final confirmed = await ConfirmLinkDialog.show(
      context,
      clubName: clubName,
      shopName: r.intersportClubName,
      mismatch: !_namesMatch,
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    final ok = await intersportService.decideRequest(
      requestId: r.id,
      decision: 'accepted',
    );
    if (!mounted) return;
    if (ok) {
      intersportCtrler.removeRequestLocally(r.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted')),
      );
      await intersportCtrler.refreshRequests();
      // * Surface the decision in the History tab right away.
      await intersportCtrler.refreshHistory();
    } else {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept failed — check Logs')),
      );
    }
  }

  Future<void> _reject() async {
    final reason = await RejectReasonDialog.show(
      context,
      clubName: widget.request.club?.name ?? 'this club',
    );
    if (reason == null) return; // * cancelled (a reason is now required)

    setState(() => _busy = true);
    final ok = await intersportService.decideRequest(
      requestId: widget.request.id,
      decision: 'rejected',
      rejectedReason: reason,
    );
    if (!mounted) return;
    if (ok) {
      intersportCtrler.removeRequestLocally(widget.request.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected')),
      );
      await intersportCtrler.refreshRequests();
      // * Surface the decision in the History tab right away.
      await intersportCtrler.refreshHistory();
    } else {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reject failed — check Logs')),
      );
    }
  }

  Future<void> _openShop() async {
    final url = widget.request.shopUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // * Header
            Row(
              children: [
                Icon(Icons.compare_arrows, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Verify integration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('d MMM yyyy, HH:mm').format(r.requestedAt),
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _matchBanner(),
            const SizedBox(height: 12),
            // * Two columns
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _clubColumn()),
                  const VerticalDivider(width: 24, thickness: 1),
                  Expanded(child: _shopColumn()),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // * Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _reject,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: _busy ? null : _accept,
                    icon:
                        _busy
                            ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // * Advisory match indicator — green when names align, red when they differ.
  Widget _matchBanner() {
    final match = _namesMatch;
    final color = match ? Colors.green : Colors.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            match ? Icons.check_circle : Icons.warning_amber_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              match
                  ? 'The names match.'
                  : 'The names do not match — verify before accepting.',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clubColumn() {
    final c = widget.request.club;
    final req = widget.request.requester;
    final cityLine = [c?.zipCode, c?.city]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _sideLabel('Footspot Club'),
        const SizedBox(height: 8),
        CrestAvatar(url: _clubLogoUrl),
        const SizedBox(height: 8),
        Text(
          c?.name ?? 'Club #${widget.request.clubId}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (cityLine.isNotEmpty) _detailCentered(cityLine),
        if (c?.clubNumber != null && c!.clubNumber!.isNotEmpty)
          _detailCentered('Club no.: ${c.clubNumber}'),
        // * Requester block
        if (req != null) ...[
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(Icons.person_outline, req.displayName),
                if (req.email != null && req.email!.isNotEmpty)
                  _kv(Icons.email_outlined, req.email!),
                if (req.phone != null && req.phone!.isNotEmpty)
                  _kv(Icons.phone_outlined, req.phone!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _shopColumn() {
    final r = widget.request;
    final p = r.partner;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _sideLabel('Intersport Shop'),
        const SizedBox(height: 8),
        CrestAvatar(url: r.intersportClubLogoUrl),
        const SizedBox(height: 8),
        Text(
          r.intersportClubName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (p != null) _detailCentered('${p.name} · ${p.region}'),
        const SizedBox(height: 4),
        Text(
          r.intersportClubId,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
        if (r.shopUrl != null && r.shopUrl!.isNotEmpty) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _openShop,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open shop'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ],
    );
  }

  Widget _sideLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _detailCentered(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _kv(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
