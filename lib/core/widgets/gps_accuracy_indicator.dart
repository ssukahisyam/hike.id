import 'package:flutter/material.dart';

import '../theme/color_tokens.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Komponen unik Hike.id — DESIGN.md §6.10.
///
/// Selalu disertai label teks, tidak pernah icon-only.
enum GpsAccuracyLevel {
  noSignal(0, 'Tidak ada sinyal'),
  weak(1, 'Lemah'),
  good(2, 'Bagus'),
  excellent(3, 'Sangat bagus');

  const GpsAccuracyLevel(this.dots, this.label);
  final int dots;
  final String label;

  static GpsAccuracyLevel fromHdopMeter(double? meters) {
    if (meters == null) return GpsAccuracyLevel.noSignal;
    if (meters > 30) return GpsAccuracyLevel.weak;
    if (meters > 10) return GpsAccuracyLevel.good;
    return GpsAccuracyLevel.excellent;
  }
}

class GpsAccuracyIndicator extends StatelessWidget {
  const GpsAccuracyIndicator({
    super.key,
    required this.level,
    this.showLabel = true,
  });

  final GpsAccuracyLevel level;
  final bool showLabel;

  Color _dotColor(int index) {
    if (index >= level.dots) return HColors.gpsNoSignal;
    return switch (level) {
      GpsAccuracyLevel.excellent => HColors.gpsExcellent,
      GpsAccuracyLevel.good => HColors.gpsGood,
      GpsAccuracyLevel.weak => HColors.gpsWeak,
      GpsAccuracyLevel.noSignal => HColors.gpsNoSignal,
    };
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Semantics(
      label: 'Akurasi GPS ${level.label}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < 3; i++) ...<Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _dotColor(i),
                shape: BoxShape.circle,
              ),
            ),
            if (i < 2) const SizedBox(width: 4),
          ],
          if (showLabel) ...<Widget>[
            const SizedBox(width: HSpacing.s2),
            Text(
              level.label,
              style: HTypography.bodySm.copyWith(color: s.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
