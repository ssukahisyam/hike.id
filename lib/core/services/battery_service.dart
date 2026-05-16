import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Snapshot data baterai pada satu titik waktu.
///
/// Dipakai untuk:
/// - Menampilkan estimasi daya tahan di start tracking sheet (PRD §4.3 / US-TRK-04)
/// - Memicu peringatan baterai rendah saat tracking aktif (PRD §6.4 / US-SOS-03)
class BatterySnapshot extends Equatable {
  const BatterySnapshot({
    required this.level,
    required this.state,
    required this.timestamp,
  });

  /// 0..100 — persen baterai. Nilai di luar range bisa terjadi pada device
  /// yang error; caller sebaiknya clamp.
  final int level;

  /// Discharging / charging / full / connected_not_charging / unknown.
  final BatteryState state;

  final DateTime timestamp;

  /// True saat baterai tidak sedang di-charge (running on battery).
  bool get isOnBattery =>
      state == BatteryState.discharging || state == BatteryState.unknown;

  /// True saat baterai <= 20% — ambang warning standar (US-SOS-03).
  bool get isLow => level <= 20;

  /// True saat baterai <= 10% — ambang critical (notifikasi lebih kuat).
  bool get isCritical => level <= 10;

  @override
  List<Object?> get props => <Object?>[level, state, timestamp];
}

/// Abstraksi battery service supaya bisa di-mock di test.
abstract class BatteryService {
  /// Snapshot saat ini (single read).
  Future<BatterySnapshot> current();

  /// Stream snapshot — emit saat state berubah (charging/discharging) ATAU
  /// setiap [pollInterval] supaya level juga ter-update.
  ///
  /// Stream ini cold; setiap listener akan trigger polling baru. Untuk
  /// shared usage gunakan provider yang di-cache.
  Stream<BatterySnapshot> snapshots({
    Duration pollInterval = const Duration(seconds: 60),
  });
}

class BatteryPlusService implements BatteryService {
  BatteryPlusService([Battery? battery]) : _battery = battery ?? Battery();

  final Battery _battery;

  @override
  Future<BatterySnapshot> current() async {
    final int level = await _battery.batteryLevel;
    final BatteryState state = await _battery.batteryState;
    return BatterySnapshot(
      level: level.clamp(0, 100),
      state: state,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<BatterySnapshot> snapshots({
    Duration pollInterval = const Duration(seconds: 60),
  }) {
    final StreamController<BatterySnapshot> controller =
        StreamController<BatterySnapshot>.broadcast();

    Timer? timer;
    StreamSubscription<BatteryState>? sub;
    bool closed = false;

    Future<void> emit() async {
      if (closed) return;
      try {
        final BatterySnapshot s = await current();
        if (!closed) controller.add(s);
      } on Object catch (e, st) {
        if (!closed) controller.addError(e, st);
      }
    }

    controller.onListen = () {
      // Emit segera saat ada listener pertama supaya UI tidak kosong.
      emit();
      // Re-emit setiap state change (misal cabut/colok charger).
      sub = _battery.onBatteryStateChanged.listen((_) => emit());
      // Polling untuk update level (state change tidak fire saat level turun).
      timer = Timer.periodic(pollInterval, (_) => emit());
    };

    controller.onCancel = () async {
      closed = true;
      timer?.cancel();
      await sub?.cancel();
      await controller.close();
    };

    return controller.stream;
  }
}

/// Override-able provider untuk testing.
final Provider<BatteryService> batteryServiceProvider = Provider<BatteryService>(
  (Ref ref) => BatteryPlusService(),
);

/// Stream snapshot baterai — auto polling tiap 60s + state change.
///
/// Pakai `ref.watch(batterySnapshotProvider)` di widget yang butuh tahu
/// level baterai. Untuk one-shot gunakan `batteryServiceProvider.current()`.
final StreamProvider<BatterySnapshot> batterySnapshotProvider =
    StreamProvider<BatterySnapshot>((Ref ref) {
  final BatteryService service = ref.watch(batteryServiceProvider);
  return service.snapshots();
});
