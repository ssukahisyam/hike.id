import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/distance.dart' as geo;
import '../../../core/utils/off_route.dart';
import '../../../core/widgets/gps_accuracy_indicator.dart';
import '../data/gps_service.dart';
import '../data/track_point_repository.dart';
import '../data/trip_repository.dart';
import '../domain/track_point.dart';
import '../domain/trip.dart';
import 'tracking_state.dart';

const Uuid _uuid = Uuid();

/// Default name kalau user tidak isi nama saat start.
String _defaultTripName(DateTime ts) {
  final String d = '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}';
  final String t =
      '${ts.hour.toString().padLeft(2, '0')}.${ts.minute.toString().padLeft(2, '0')}';
  return 'Hike $d $t';
}

/// Controller utama untuk session tracking aktif.
///
/// Tanggung jawab:
/// - Lifecycle: start / pause / resume / stop / discard
/// - Subscribe stream GPS service & buang outlier (PRD §9.1)
/// - Update statistik live (jarak, durasi, elevasi gain/loss)
/// - Persist track point + auto-save trip ke Drift (PRD §4.3)
/// - Recovery setelah crash (US-TRK-05) — handled di startup `recoverActiveTrip`
class TrackingController extends StateNotifier<TrackingSession> {
  TrackingController({
    required GpsService gpsService,
    required TripRepository tripRepository,
    required TrackPointRepository trackPointRepository,
  })  : _gps = gpsService,
        _tripRepo = tripRepository,
        _trackRepo = trackPointRepository,
        super(const TrackingSession());

  final GpsService _gps;
  final TripRepository _tripRepo;
  final TrackPointRepository _trackRepo;

  StreamSubscription<GpsFix>? _gpsSub;
  Timer? _ticker;
  Timer? _autoSaveTimer;
  DateTime? _lastTickAt;
  final List<TrackPoint> _pendingPoints = <TrackPoint>[];

  /// Polyline yang sedang difollow (dari imported GPX). Null = free-roam,
  /// off-route detector tidak aktif.
  List<geo.LatLng>? _followedRoute;
  final OffRouteDetector _offRoute = OffRouteDetector();

  /// Pasang rute yang sedang difollow — biasanya dipanggil setelah
  /// user pilih GPX dari history "Follow this route".
  void setFollowedRoute(List<geo.LatLng>? route) {
    _followedRoute = route;
  }

  /// Cek apakah ada session aktif yang belum ditutup. Dipanggil saat app
  /// startup (US-TRK-05). Kalau ada, otomatis resume agar data tidak hilang.
  Future<void> recoverActiveTrip() async {
    final Trip? existing = await _tripRepo.findActiveOrPaused();
    if (existing == null) return;
    state = state.copyWith(
      phase: existing.status == TripStatus.paused
          ? TrackingPhase.paused
          : TrackingPhase.running,
      activeTrip: existing,
      distanceMeters: existing.totalDistance,
      activeDuration: existing.totalDuration,
      elevationGain: existing.elevationGain,
      elevationLoss: existing.elevationLoss,
      maxElevation: existing.maxElevation,
      minElevation: existing.minElevation,
      maxSpeed: existing.maxSpeed,
      mode: existing.trackingMode,
    );
    if (existing.status == TripStatus.active) {
      await _startGpsStream();
      _startTicker();
      _startAutoSave();
    }
  }

  Future<void> start({
    String? name,
    String? mountainName,
    TrackingMode mode = TrackingMode.balanced,
  }) async {
    if (state.isActive) return;
    try {
      await _gps.ensureReady();
    } on GpsUnavailable catch (e) {
      state = state.copyWith(phase: TrackingPhase.error, errorMessage: e.message);
      return;
    }

    final DateTime now = DateTime.now();
    final Trip trip = Trip(
      id: _uuid.v4(),
      name: name?.trim().isNotEmpty == true ? name!.trim() : _defaultTripName(now),
      mountainName: mountainName,
      startedAt: now,
      status: TripStatus.active,
      trackingMode: mode,
      source: TripSource.recorded,
      createdAt: now,
      updatedAt: now,
    );
    await _tripRepo.insert(trip);

    state = const TrackingSession().copyWith(
      phase: TrackingPhase.running,
      activeTrip: trip,
      mode: mode,
      clearError: true,
    );
    _lastTickAt = now;
    _pendingPoints.clear();
    await _startGpsStream();
    _startTicker();
    _startAutoSave();
  }

  Future<void> pause() async {
    if (!state.isRunning) return;
    await _gpsSub?.cancel();
    _gpsSub = null;
    _ticker?.cancel();
    state = state.copyWith(phase: TrackingPhase.paused);
    await _persistTripSnapshot(status: TripStatus.paused);
  }

  Future<void> resume() async {
    if (!state.isPaused) return;
    state = state.copyWith(phase: TrackingPhase.running);
    _lastTickAt = DateTime.now();
    await _startGpsStream();
    _startTicker();
    await _persistTripSnapshot(status: TripStatus.active);
  }

  /// Selesaikan trip dan simpan dengan summary akhir.
  Future<Trip?> stopAndSave({String? finalName, int? difficulty}) async {
    final Trip? trip = state.activeTrip;
    if (trip == null) return null;
    state = state.copyWith(phase: TrackingPhase.saving);
    await _flushPending();
    await _gpsSub?.cancel();
    _gpsSub = null;
    _ticker?.cancel();
    _autoSaveTimer?.cancel();

    final DateTime endedAt = DateTime.now();
    final Trip completed = trip.copyWith(
      name: finalName?.trim().isNotEmpty == true ? finalName!.trim() : trip.name,
      difficulty: difficulty,
      endedAt: endedAt,
      totalDistance: state.distanceMeters,
      totalDuration: state.activeDuration,
      elevationGain: state.elevationGain,
      elevationLoss: state.elevationLoss,
      maxElevation: state.maxElevation,
      minElevation: state.minElevation,
      avgSpeed: state.avgSpeed,
      maxSpeed: state.maxSpeed,
      status: TripStatus.completed,
      updatedAt: endedAt,
    );
    await _tripRepo.update(completed);

    state = const TrackingSession();
    return completed;
  }

  /// Buang trip yang sedang berjalan (tanpa simpan).
  Future<void> discard() async {
    final Trip? trip = state.activeTrip;
    await _gpsSub?.cancel();
    _gpsSub = null;
    _ticker?.cancel();
    _autoSaveTimer?.cancel();
    if (trip != null) {
      await _trackRepo.deleteByTripId(trip.id);
      await _tripRepo.delete(trip.id);
    }
    state = const TrackingSession();
  }

  /// Pindah mode tracking di tengah jalan (PRD US-TRK-04).
  Future<void> switchMode(TrackingMode mode) async {
    if (state.mode == mode) return;
    state = state.copyWith(mode: mode);
    if (state.isRunning) {
      await _gpsSub?.cancel();
      await _startGpsStream();
    }
    await _persistTripSnapshot();
  }

  /// Mute off-route warning untuk session ini (user sengaja off-route).
  void muteOffRouteWarning() {
    _offRoute.mute();
    state = state.copyWith(clearOffRoute: true);
  }

  /// Dismiss the active off-route warning UI but keep detector armed.
  void dismissOffRouteWarning() {
    state = state.copyWith(clearOffRoute: true);
  }

  Future<void> _startGpsStream() async {
    final TrackingMode mode = state.mode;
    _gpsSub = _gps.stream(mode).listen(_onFix, onError: _onGpsError);
  }

  void _onFix(GpsFix fix) {
    final Trip? trip = state.activeTrip;
    if (trip == null || !state.isRunning) return;

    final TrackingFix? prev = state.lastFix;

    // Filter outlier teleport (PRD §9.1).
    if (prev != null &&
        geo.Geo.isTeleport(
          geo.LatLng(prev.latitude, prev.longitude),
          prev.timestamp.millisecondsSinceEpoch,
          geo.LatLng(fix.latitude, fix.longitude),
          fix.timestamp.millisecondsSinceEpoch,
        )) {
      return;
    }

    double newDistance = state.distanceMeters;
    double gain = state.elevationGain;
    double loss = state.elevationLoss;
    double maxEl = state.maxElevation ?? fix.altitude ?? double.negativeInfinity;
    double minEl = state.minElevation ?? fix.altitude ?? double.infinity;
    double maxSpeed = state.maxSpeed;

    if (prev != null) {
      final double delta = geo.Geo.haversineMeters(
        prev.latitude,
        prev.longitude,
        fix.latitude,
        fix.longitude,
      );
      // Skip noise GPS yang terlalu kecil saat diam.
      if (delta > 1.5) {
        newDistance += delta;
      }
      if (prev.elevation != null && fix.altitude != null) {
        final double dEl = fix.altitude! - prev.elevation!;
        if (dEl > 1.0) {
          gain += dEl;
        } else if (dEl < -1.0) {
          loss += dEl.abs();
        }
      }
    }
    if (fix.altitude != null) {
      if (fix.altitude! > maxEl) maxEl = fix.altitude!;
      if (fix.altitude! < minEl) minEl = fix.altitude!;
    }
    if (fix.speed != null && fix.speed! > maxSpeed) maxSpeed = fix.speed!;

    final TrackingFix newFix = TrackingFix(
      latitude: fix.latitude,
      longitude: fix.longitude,
      elevation: fix.altitude,
      accuracy: fix.accuracy,
      speed: fix.speed,
      heading: fix.heading,
      timestamp: fix.timestamp,
    );

    state = state.copyWith(
      lastFix: newFix,
      distanceMeters: newDistance,
      elevationGain: gain,
      elevationLoss: loss,
      maxElevation: maxEl == double.negativeInfinity ? null : maxEl,
      minElevation: minEl == double.infinity ? null : minEl,
      maxSpeed: maxSpeed,
      gpsAccuracy: GpsAccuracyLevel.fromHdopMeter(fix.accuracy),
    );

    _pendingPoints.add(TrackPoint(
      tripId: trip.id,
      latitude: fix.latitude,
      longitude: fix.longitude,
      elevation: fix.altitude,
      accuracy: fix.accuracy,
      speed: fix.speed,
      heading: fix.heading,
      timestamp: fix.timestamp,
    ));

    // Off-route check (PRD §4.9). Threshold default 100m, cooldown 60s.
    if (_followedRoute != null) {
      final OffRouteResult? warn = _offRoute.evaluate(
        userPosition: geo.LatLng(fix.latitude, fix.longitude),
        route: _followedRoute!,
      );
      if (warn != null) {
        state = state.copyWith(
          offRouteDistanceMeters: warn.distanceMeters,
        );
      }
    }
  }

  void _onGpsError(Object err, StackTrace st) {
    state = state.copyWith(
      phase: TrackingPhase.error,
      errorMessage: err.toString(),
      gpsAccuracy: GpsAccuracyLevel.noSignal,
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _lastTickAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning) return;
      final DateTime now = DateTime.now();
      final Duration delta = now.difference(_lastTickAt ?? now);
      _lastTickAt = now;
      state = state.copyWith(activeDuration: state.activeDuration + delta);
    });
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    // Auto-save setiap 30 detik (PRD §4.3 / PLANNING §7 Phase 3).
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _flushPending();
      await _persistTripSnapshot();
    });
  }

  Future<void> _flushPending() async {
    if (_pendingPoints.isEmpty) return;
    final List<TrackPoint> toFlush = List<TrackPoint>.from(_pendingPoints);
    _pendingPoints.clear();
    await _trackRepo.insertBatch(toFlush);
  }

  Future<void> _persistTripSnapshot({TripStatus? status}) async {
    final Trip? trip = state.activeTrip;
    if (trip == null) return;
    final Trip updated = trip.copyWith(
      totalDistance: state.distanceMeters,
      totalDuration: state.activeDuration,
      elevationGain: state.elevationGain,
      elevationLoss: state.elevationLoss,
      maxElevation: state.maxElevation,
      minElevation: state.minElevation,
      avgSpeed: state.avgSpeed,
      maxSpeed: state.maxSpeed,
      trackingMode: state.mode,
      status: status ?? trip.status,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(activeTrip: updated);
    await _tripRepo.update(updated);
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _ticker?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<TrackingController, TrackingSession> trackingControllerProvider =
    StateNotifierProvider<TrackingController, TrackingSession>((Ref ref) {
  return TrackingController(
    gpsService: ref.watch(gpsServiceProvider),
    tripRepository: ref.watch(tripRepositoryProvider),
    trackPointRepository: ref.watch(trackPointRepositoryProvider),
  );
});
