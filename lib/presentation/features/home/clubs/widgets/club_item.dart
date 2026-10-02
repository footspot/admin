import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fs_sa/data/models/objectbox/club_sub_entity.dart';
import 'package:fs_sa/presentation/core/constants.dart';
import 'package:fs_sa/presentation/core/themes.dart';
import 'package:fs_sa/presentation/features/home/clubs/clubs_controller.dart';
import 'package:fs_sa/presentation/features/home/clubs/widgets/directors_sheet.dart';
import 'package:fs_sa/presentation/features/home/clubs/widgets/subwidgets/add_member_form.dart';
import 'package:fs_sa/presentation/features/home/clubs/widgets/subwidgets/edit_club_form.dart';
import 'package:fs_sa/presentation/features/home/clubs/widgets/subwidgets/show_payment_infos.dart';
import 'package:fs_sa/presentation/utils/responsive.dart';

class ClubItem extends StatefulWidget {
  const ClubItem({super.key, required this.data, this.index = -1});

  final ClubSubscriptionEntity data;
  final int index;

  @override
  State<ClubItem> createState() => _ClubItemState();
}

class _ClubItemState extends State<ClubItem> with Responsive {
  bool showSecond = false;

  Widget secondChild = const Placeholder();

  late final bool isEven;

  // * Cohesive per-row accent palette (green for even rows, amber for odd)
  late final Color _accent;
  late final List<Color> _gradient;

  @override
  void initState() {
    super.initState();
    isEven = widget.index % 2 == 0;
    _accent = isEven ? primary : secondaryDark;
    _gradient =
        isEven
            ? const [primaryDark, primary, primaryLight]
            : const [secondaryDark, secondary, secondaryLight];
  }

  closeWidget() => setState(() => showSecond = false);

  void _scrollToTop() {
    final double itemHeight = 198;
    final double targetOffset = widget.index * itemHeight;

    Timer(
      const Duration(milliseconds: 250),
      () => clubsCtrler.scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.data.club.target;
    final surface = Theme.of(context).colorScheme.surface;
    // * Faintly tint the body with the row accent for a cohesive glow
    final bodyColor = Color.lerp(surface, _accent, 0.05)!;

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: float12 / 3,
        horizontal: float12 / 4,
      ),
      width: widthScreen - float12,
      decoration: BoxDecoration(
        color: bodyColor,
        borderRadius: BorderRadius.circular(float12 + 6),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.28),
            blurRadius: 18,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(float12 + 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(club),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: _buildBody(club),
            ),
            _buildActions(),
            const SizedBox(height: 10),
            if (!showSecond) _directorsBar(club),
          ],
        ),
      ),
    );
  }

  // * Full-width bar that opens the scrollable directors bottom sheet
  Widget _directorsBar(club) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            club == null
                ? null
                : () => showDirectorsSheet(
                  context,
                  clubId: club.id,
                  index: widget.index,
                ),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF37474F), Color(0xFF263238)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'View directors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // * Glossy gradient header with logo, name and a sweeping light reflection
  Widget _buildHeader(club) {
    return SizedBox(
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // * Base gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradient,
              ),
            ),
          ),

          // * Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _buildLogo(club),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        club?.name ?? 'n/c',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _headerBadge(
                        Icons.inventory_2_rounded,
                        club != null
                            ? club.stockType.toString().split('.').last
                            : 'n/c',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(club) {
    final hasLogo = club?.logoPath != null;
    return Container(
      width: 48,
      height: 48,
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
            hasLogo
                ? Image.network(
                  clubsCtrler.getClubLogoUrl(club!.logoPath!),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(Icons.shield_rounded, color: _accent, size: 26),
                )
                : Icon(Icons.shield_rounded, color: _accent, size: 26),
      ),
    );
  }

  Widget _buildBody(club) {
    final members = widget.data.members;
    final limit = widget.data.membersLimit;
    final ratio = limit > 0 ? (members / limit).clamp(0.0, 1.0) : 0.0;
    final price = widget.data.priceMember;
    final total = (limit * price).toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // * Capacity bar
        Row(
          children: [
            Icon(Icons.groups_rounded, size: 16, color: _accent),
            const SizedBox(width: 6),
            Text(
              'Members',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '$members / $limit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: _accent.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation(_accent),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // * Stat pills
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _statPill(Icons.euro_rounded, '$price /member'),
            _statPill(Icons.payments_rounded, '$total€ /year'),
            _statPill(Icons.event_rounded, widget.data.createdAtFormat),
            _statPill(Icons.tag_rounded, 'FFF ${club?.clubNumber ?? 'n/c'}'),
            _statPill(Icons.badge_rounded, 'ID ${club?.id ?? 'n/c'}'),
          ],
        ),
      ],
    );
  }

  Widget _statPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _accent),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 220),
        crossFadeState:
            !showSecond ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: Row(
          key: const ValueKey('action-buttons'),
          children: [
            _actionButton(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Add',
              color: primary,
              onTap: () {
                setState(() {
                  secondChild = AddDirectorForm(
                    close: closeWidget,
                    club: widget.data,
                  );
                  showSecond = true;
                  _scrollToTop();
                });
              },
            ),
            const SizedBox(width: 8),
            _actionButton(
              icon: Icons.edit_rounded,
              label: 'Edit',
              color: secondaryDark,
              onTap: () {
                setState(() {
                  secondChild = EditClubForm(close: closeWidget, rs: widget.data);
                  showSecond = true;
                  _scrollToTop();
                });
              },
            ),
            const SizedBox(width: 8),
            _actionButton(
              icon: Icons.credit_card_rounded,
              label: 'Payment',
              color: Colors.indigo,
              onTap: () {
                setState(() {
                  secondChild = ShowPaymentInfos(
                    close: closeWidget,
                    stripeId: widget.data.club.target?.sid,
                    paypalEmail: widget.data.club.target?.ppmail,
                  );
                  showSecond = true;
                });
              },
            ),
          ],
        ),
        secondChild: secondChild,
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Color.lerp(color, Colors.black, 0.18)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
