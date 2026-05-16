import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tracking/application/tracking_controller.dart';
import '../../tracking/application/tracking_state.dart';
import '../../tracking/data/gps_service.dart';

/// Hasil resolved lokasi terakhir untuk SOS screen.
///
/// Mengikuti aturan PRD §4.10: SOS screen harus tersedia walau offline.
/// Sumber dicoba berurutan:
///   1. Active tracking session (paling fresh)
///   2. Last known position dari GPS service (cache OS)
///   3. null (UI tampilkan sosNoLocationYet)
class LastKnownLocation {
  const LastKnownLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.elevation,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? elevation;
  final DateTime timestamp;

  Duration get age => DateTime.now().difference(timestamp);
}

final FutureProvider<LastKnownLocation?> lastKnownLocationProvider =
    FutureProvider<LastKnownLocation?>((Ref ref) async {
  // 1. Tracking aktif → pakai fix terbaru.
  final TrackingSession session = ref.watch(trackingControllerProvider);
  final TrackingFix? activeFix = session.lastFix;
  if (activeFix != null) {
    return LastKnownLocation(
      latitude: activeFix.latitude,
      longitude: activeFix.longitude,
      accuracy: activeFix.accuracy,
      elevation: activeFix.elevation,
      timestamp: activeFix.timestamp,
    );
  }
  // 2. Last known dari OS cache.
  final GpsFix? cached = await ref.watch(gpsServiceProvider).lastKnown();
  if (cached != null) {
    return LastKnownLocation(
      latitude: cached.latitude,
      longitude: cached.longitude,
      accuracy: cached.accuracy,
      elevation: cached.altitude,
      timestamp: cached.timestamp,
    );
  }
  return null;
});
