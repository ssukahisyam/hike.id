import 'package:flutter/material.dart';

import '../theme/color_tokens.dart';
import '../theme/typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: HTypography.labelMd.copyWith(color: s.textTertiary),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
