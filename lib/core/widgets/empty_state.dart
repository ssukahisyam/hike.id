import 'package:flutter/material.dart';

import '../theme/color_tokens.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Empty state — DESIGN.md §6.11.
///
/// Mendorong aksi, bukan apologetic. Tidak pakai emoji.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    required this.headline,
    required this.body,
    this.action,
  });

  final IconData? icon;
  final String headline;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: HSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: s.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: s.borderSubtle),
                ),
                child: Icon(icon, color: HColors.forest300, size: 28),
              ),
              const SizedBox(height: HSpacing.s5),
            ],
            Text(
              headline,
              style: HTypography.headingLg.copyWith(color: s.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HSpacing.s2),
            Text(
              body,
              style: HTypography.bodyMd.copyWith(color: s.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: HSpacing.s5),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
