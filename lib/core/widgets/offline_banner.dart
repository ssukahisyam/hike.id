import 'package:flutter/material.dart';

import '../theme/color_tokens.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Banner offline — DESIGN.md §6.7.
///
/// Tipis, hangat, persistent — tidak panic-inducing. Saat MVP belum
/// dipasang ke connectivity_plus stream — caller bisa `show: !online`.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: HColors.volcanic700,
      padding: const EdgeInsets.symmetric(
        horizontal: HSpacing.s4,
        vertical: HSpacing.s2,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: <Widget>[
            const Icon(Icons.signal_wifi_off_rounded, size: 16, color: HColors.mist50),
            const SizedBox(width: HSpacing.s2),
            Text(
              'Mode Offline',
              style: HTypography.labelMd.copyWith(color: HColors.mist50),
            ),
          ],
        ),
      ),
    );
  }
}
