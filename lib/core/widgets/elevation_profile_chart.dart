import 'package:flutter/material.dart';

import '../theme/color_tokens.dart';
import '../theme/typography.dart';

/// Profil elevasi sepanjang trip — DESIGN.md §11.4 trip detail stats.
///
/// Implementasi pakai CustomPainter, bukan fl_chart, supaya:
/// - Tidak menambah dependency yang bisa konflik
/// - Render < 16ms walau track panjang (auto-decimation)
/// - Visual halus selaras dengan token forest/alpenglow
class ElevationProfileChart extends StatelessWidget {
  const ElevationProfileChart({
    super.key,
    required this.elevations,
    this.height = 120,
    this.distancesMeters,
  });

  /// Sequence elevasi dalam meter, urut sesuai track point (paused dibuang
  /// caller). Boleh ada null saat sensor missing.
  final List<double?> elevations;

  /// Sequence kumulatif jarak (meter) sepanjang sequence elevations.
  /// Optional — kalau null, sumbu X assumed equal spacing.
  final List<double>? distancesMeters;

  final double height;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final List<double> nonNull = <double>[
      for (final double? e in elevations)
        if (e != null) e,
    ];
    if (nonNull.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Data elevasi belum cukup',
            style: HTypography.bodySm.copyWith(color: s.textTertiary),
          ),
        ),
      );
    }

    final double minEl = nonNull.reduce((double a, double b) => a < b ? a : b);
    final double maxEl = nonNull.reduce((double a, double b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${maxEl.round()} m',
                  style: HTypography.monoSm.copyWith(color: s.textTertiary),
                ),
                Text(
                  '${minEl.round()} m',
                  style: HTypography.monoSm.copyWith(color: s.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: CustomPaint(
                painter: _ElevationPainter(
                  elevations: elevations,
                  distancesMeters: distancesMeters,
                  fillColor: HColors.forest500.withValues(alpha: 0.15),
                  strokeColor: HColors.forest500,
                  axisColor: s.borderSubtle,
                ),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElevationPainter extends CustomPainter {
  _ElevationPainter({
    required this.elevations,
    required this.fillColor,
    required this.strokeColor,
    required this.axisColor,
    this.distancesMeters,
  });

  final List<double?> elevations;
  final List<double>? distancesMeters;
  final Color fillColor;
  final Color strokeColor;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Decimate kalau > 200 titik supaya tetap smooth.
    final List<_Point> sampled = _decimate(elevations, distancesMeters, 200);
    if (sampled.length < 2) return;

    final double minEl = sampled
        .map<double>((_Point p) => p.elevation)
        .reduce((double a, double b) => a < b ? a : b);
    final double maxEl = sampled
        .map<double>((_Point p) => p.elevation)
        .reduce((double a, double b) => a > b ? a : b);
    final double range = (maxEl - minEl).abs() < 0.001 ? 1 : (maxEl - minEl);

    final double minX = sampled.first.x;
    final double maxX = sampled.last.x;
    final double xRange = (maxX - minX).abs() < 0.001 ? 1 : (maxX - minX);

    final Path stroke = Path();
    final Path fill = Path()..moveTo(0, size.height);

    for (int i = 0; i < sampled.length; i++) {
      final _Point p = sampled[i];
      final double dx = ((p.x - minX) / xRange) * size.width;
      final double dy = size.height - ((p.elevation - minEl) / range) * size.height;
      if (i == 0) {
        stroke.moveTo(dx, dy);
        fill.lineTo(dx, dy);
      } else {
        stroke.lineTo(dx, dy);
        fill.lineTo(dx, dy);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    // Axis baseline
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = axisColor
        ..strokeWidth = 1,
    );

    canvas.drawPath(fill, Paint()..color = fillColor);
    canvas.drawPath(
      stroke,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  List<_Point> _decimate(
    List<double?> src,
    List<double>? distances,
    int maxPoints,
  ) {
    final List<_Point> nonNull = <_Point>[];
    for (int i = 0; i < src.length; i++) {
      final double? el = src[i];
      if (el == null) continue;
      final double x =
          distances != null && i < distances.length ? distances[i] : i.toDouble();
      nonNull.add(_Point(x, el));
    }
    if (nonNull.length <= maxPoints) return nonNull;
    final List<_Point> out = <_Point>[];
    final double step = nonNull.length / maxPoints;
    for (double i = 0; i < nonNull.length; i += step) {
      out.add(nonNull[i.floor()]);
    }
    if (out.last != nonNull.last) out.add(nonNull.last);
    return out;
  }

  @override
  bool shouldRepaint(_ElevationPainter old) {
    return !identical(old.elevations, elevations) ||
        !identical(old.distancesMeters, distancesMeters);
  }
}

class _Point {
  const _Point(this.x, this.elevation);
  final double x;
  final double elevation;
}
