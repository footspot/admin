import 'package:flutter/material.dart';

/// Circular crest/logo loader with a shield-icon fallback, mirroring the
/// club-item logo pattern. Works for any full image URL (club crest built via
/// the club-logo URL builder, or an Intersport shop logo URL). Falls back to a
/// shield when [url] is null/empty or the network image fails to load.
class CrestAvatar extends StatelessWidget {
  const CrestAvatar({super.key, required this.url, this.size = 56});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final hasUrl = url != null && url!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child:
            hasUrl
                ? Image.network(
                  url!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => _fallback(accent),
                )
                : _fallback(accent),
      ),
    );
  }

  Widget _fallback(Color accent) =>
      Icon(Icons.shield_rounded, color: accent, size: size * 0.5);
}
