import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../checkpoint/domain/checkpoint.dart';

/// Reusable map widget — DESIGN.md §8.
///
/// Centralized supaya tile cache strategy & atribusi konsisten di semua
/// screen yang pakai peta (tracking, trip detail, GPX preview, dll).
class HikeMapView extends StatelessWidget {
  const HikeMapView({
    super.key,
    this.controller,
    this.initialCenter,
    this.initialZoom = 13,
    this.activeTrack = const <LatLng>[],
    this.historyTracks = const <List<LatLng>>[],
    this.importedRoute,
    this.checkpoints = const <Checkpoint>[],
    this.currentPosition,
    this.heading,
    this.followUser = true,
    this.onLongPress,
  });

  final MapController? controller;
  final LatLng? initialCenter;
  final double initialZoom;

  /// Polyline trip yang sedang direkam (forest/500).
  final List<LatLng> activeTrack;

  /// Polyline trip lama (volcanic, opacity rendah).
  final List<List<LatLng>> historyTracks;

  /// Polyline route GPX yang diimport (mist-cyan dashed).
  final List<LatLng>? importedRoute;

  final List<Checkpoint> checkpoints;
  final LatLng? currentPosition;
  final double? heading;
  final bool followUser;

  /// Callback saat long-press di peta (untuk tambah checkpoint —
  /// PRD US-CHK-01).
  final void Function(LatLng position)? onLongPress;

  @override
  Widget build(BuildContext context) {
    // Default ke center Indonesia kalau tidak ada koordinat.
    final LatLng center = initialCenter ?? currentPosition ?? const LatLng(-2.0, 117.5);

    return Stack(
      children: <Widget>[
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: center,
            initialZoom: initialZoom,
            minZoom: 3,
            maxZoom: 18,
            onLongPress: onLongPress == null
                ? null
                : (TapPosition tap, LatLng pos) => onLongPress!.call(pos),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'id.hike.app',
              maxZoom: 19,
            ),
            // History tracks
            if (historyTracks.isNotEmpty)
              PolylineLayer(
                polylines: <Polyline>[
                  for (final List<LatLng> t in historyTracks)
                    if (t.length >= 2)
                      Polyline(
                        points: t,
                        strokeWidth: 4,
                        color: HColors.trackHistory.withOpacity(0.7),
                      ),
                ],
              ),
            // Imported GPX route
            if (importedRoute != null && importedRoute!.length >= 2)
              PolylineLayer(
                polylines: <Polyline>[
                  Polyline(
                    points: importedRoute!,
                    strokeWidth: 4,
                    color: HColors.trackImported,
                  ),
                ],
              ),
            // Active recording track
            if (activeTrack.length >= 2)
              PolylineLayer(
                polylines: <Polyline>[
                  Polyline(
                    points: activeTrack,
                    strokeWidth: 5,
                    color: HColors.trackActive,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),
            // Checkpoints
            if (checkpoints.isNotEmpty)
              MarkerLayer(
                markers: <Marker>[
                  for (final Checkpoint cp in checkpoints)
                    Marker(
                      point: LatLng(cp.latitude, cp.longitude),
                      width: 32,
                      height: 32,
                      child: _CheckpointPin(type: cp.type),
                    ),
                ],
              ),
            // Current position
            if (currentPosition != null)
              MarkerLayer(
                markers: <Marker>[
                  Marker(
                    point: currentPosition!,
                    width: 36,
                    height: 36,
                    child: _CurrentPositionMarker(heading: heading),
                  ),
                ],
              ),
            // Atribusi OSM — wajib visible (DESIGN.md §8.5).
          ],
        ),
        // Atribusi sebagai Positioned widget — portable across flutter_map versions.
        Positioned(
          right: 8,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: HColors.mist0.withOpacity(0.85),
              borderRadius: BorderRadius.circular(HRadius.sm),
            ),
            child: Text(
              '© OpenStreetMap',
              style: HTypography.bodySm.copyWith(color: HColors.mist700),
            ),
          ),
        ),

        // Offline banner (DESIGN.md §6.7) — placeholder. Belum di-wire ke
        // connectivity_plus stream; akan ditambahkan saat tile-cache fitur
        // online (post-MVP).
      ],
    );
  }
}

class _CurrentPositionMarker extends StatelessWidget {
  const _CurrentPositionMarker({this.heading});
  final double? heading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // Pulse ring (decorative)
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HColors.forest500.withOpacity(0.15),
          ),
        ),
        // Solid dot
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HColors.forest500,
            border: Border.all(color: HColors.mist0, width: 3),
          ),
        ),
        // Heading triangle
        if (heading != null)
          Transform.rotate(
            angle: heading! * 3.14159 / 180,
            child: const Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Icon(Icons.arrow_drop_up, color: HColors.forest500, size: 16),
            ),
          ),
      ],
    );
  }
}

class _CheckpointPin extends StatelessWidget {
  const _CheckpointPin({required this.type});
  final CheckpointType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: type.color,
        shape: BoxShape.circle,
        border: Border.all(color: HColors.mist0, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: HColors.mist950.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(type.icon, color: HColors.mist0, size: 18),
    );
  }
}
