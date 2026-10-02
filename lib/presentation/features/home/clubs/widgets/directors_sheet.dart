import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fs_sa/data/models/objectbox/user_entity.dart';
import 'package:fs_sa/presentation/core/themes.dart';
import 'package:fs_sa/presentation/features/home/clubs/clubs_controller.dart';

// * Opens the scrollable directors bottom sheet for a club
Future<void> showDirectorsSheet(
  BuildContext context, {
  required int clubId,
  required int index,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DirectorsSheet(clubId: clubId, index: index),
  );
}

class _DirectorsSheet extends StatefulWidget {
  const _DirectorsSheet({required this.clubId, required this.index});

  final int clubId;
  final int index;

  @override
  State<_DirectorsSheet> createState() => _DirectorsSheetState();
}

class _DirectorsSheetState extends State<_DirectorsSheet> {
  late final bool isEven;
  late final Color _accent;
  late final List<Color> _gradient;

  // * Fetch once — DraggableScrollableSheet rebuilds its builder on every drag
  late final Future<List<UserEntity>> _future;

  @override
  void initState() {
    super.initState();
    isEven = widget.index % 2 == 0;
    _accent = isEven ? primary : secondaryDark;
    _gradient =
        isEven
            ? const [primaryDark, primary, primaryLight]
            : const [secondaryDark, secondary, secondaryLight];
    _future = clubsCtrler.getDirectors(widget.clubId);
  }

  void _copy(String label, String? value) {
    if (value == null || value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: _accent,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('$label copied'),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final bodyColor = Color.lerp(surface, _accent, 0.05)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bodyColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _grabHandle(),
              FutureBuilder<List<UserEntity>>(
                future: _future,
                builder: (context, snapshot) {
                  final loading =
                      snapshot.connectionState == ConnectionState.waiting;
                  return _header(loading ? null : (snapshot.data?.length ?? 0));
                },
              ),
              Expanded(
                child: FutureBuilder<List<UserEntity>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: _accent,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _placeholder(
                        Icons.error_outline_rounded,
                        'Could not load directors',
                      );
                    }
                    final directors = snapshot.data ?? [];
                    if (directors.isEmpty) {
                      return _placeholder(
                        Icons.person_off_rounded,
                        'No directors yet',
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
                      itemCount: directors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _directorTile(directors[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _grabHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _header(int? count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Directors',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: _accent.withValues(alpha: 0.6)),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _directorTile(UserEntity user) {
    final fullName =
        '${user.name ?? ''} ${user.lastname ?? ''}'.trim().isEmpty
            ? 'n/c'
            : '${user.name ?? ''} ${user.lastname ?? ''}'.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          _avatar(user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                _infoLine(Icons.email_rounded, user.emailContact),
                _infoLine(Icons.phone_rounded, user.phone),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // * Copy buttons (email + phone)
          Column(
            children: [
              _copyButton(
                Icons.alternate_email_rounded,
                'Email',
                user.emailContact,
              ),
              const SizedBox(height: 8),
              _copyButton(Icons.call_rounded, 'Phone', user.phone),
            ],
          ),
        ],
      ),
    );
  }

  Widget _copyButton(IconData icon, String label, String? value) {
    final enabled = value != null && value.isNotEmpty;
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: _accent.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? () => _copy(label, value) : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: _accent),
          ),
        ),
      ),
    );
  }

  Widget _avatar(UserEntity user) {
    final initials =
        '${(user.name?.isNotEmpty ?? false) ? user.name![0] : ''}'
                '${(user.lastname?.isNotEmpty ?? false) ? user.lastname![0] : ''}'
            .toUpperCase();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoLine(IconData icon, String? value) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: _accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'n/c',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
