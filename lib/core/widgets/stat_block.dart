import 'package:flutter/material.dart';

import '../theme/color_tokens.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Stat block — DESIGN.md §6.4.
///
/// Pola: label di atas, angka mono di tengah, unit kecil di bawah.
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.size = StatBlockSize.regular,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final String? unit;
  final StatBlockSize size;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final TextStyle valueStyle = switch (size) {
      StatBlockSize.hero => HTypography.monoXl,
      StatBlockSize.regular => HTypography.monoLg,
      StatBlockSize.small => HTypography.monoMd,
    }
        .copyWith(color: s.textPrimary);

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: HTypography.labelMd.copyWith(color: s.textTertiary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: HSpacing.s1),
        Text(
          value,
          style: valueStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (unit != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            unit!,
            style: HTypography.monoSm.copyWith(color: s.textTertiary),
          ),
        ],
      ],
    );
  }
}

enum StatBlockSize { hero, regular, small }
