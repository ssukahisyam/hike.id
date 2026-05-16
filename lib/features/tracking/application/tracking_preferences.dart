import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/theme_mode_controller.dart';
import '../domain/trip.dart';

/// Persistent preferences seputar tracking session.
///
/// MVP scope (PRD US-TRK-04):
/// - `defaultMode` — mode tracking yang dipakai saat user tap "Mulai Hike"
///   tanpa membuka start sheet. Bisa di-override sekali jalan dari sheet,
///   atau disimpan permanen via "Simpan sebagai default".
class TrackingPreferences {
  const TrackingPreferences({
    this.defaultMode = TrackingMode.balanced,
  });

  final TrackingMode defaultMode;

  TrackingPreferences copyWith({TrackingMode? defaultMode}) {
    return TrackingPreferences(defaultMode: defaultMode ?? this.defaultMode);
  }
}

class TrackingPreferencesController extends StateNotifier<TrackingPreferences> {
  TrackingPreferencesController(this._prefs) : super(const TrackingPreferences()) {
    _load();
  }

  final SharedPreferences _prefs;

  static const String _kDefaultMode = 'tracking.defaultMode';

  void _load() {
    final String? raw = _prefs.getString(_kDefaultMode);
    if (raw == null) return;
    state = TrackingPreferences(defaultMode: TrackingMode.fromName(raw));
  }

  Future<void> setDefaultMode(TrackingMode mode) async {
    if (state.defaultMode == mode) return;
    state = state.copyWith(defaultMode: mode);
    await _prefs.setString(_kDefaultMode, mode.name);
  }
}

final StateNotifierProvider<TrackingPreferencesController, TrackingPreferences>
    trackingPreferencesProvider =
    StateNotifierProvider<TrackingPreferencesController, TrackingPreferences>(
  (Ref ref) => TrackingPreferencesController(ref.watch(sharedPreferencesProvider)),
);

// ─────────────────────────────────────────────────────────────────────────────
// Helper labels — dipakai di start sheet, settings, history.
//
// Kita tetap hard-code Indonesian dulu untuk Phase 4 supaya tidak block.
// Strings akan dipindah ke ARB di follow-up bila diperlukan (kebanyakan teks
// ini sudah Indonesian-only di copy product).
// ─────────────────────────────────────────────────────────────────────────────

/// Label singkat mode tracking (misal untuk segmented control).
String trackingModeLabel(TrackingMode mode) {
  switch (mode) {
    case TrackingMode.highAccuracy:
      return 'Akurat';
    case TrackingMode.balanced:
      return 'Seimbang';
    case TrackingMode.batterySaver:
      return 'Hemat';
  }
}

/// Deskripsi 1 baris untuk start sheet — penjelasan trade-off mode.
String trackingModeDescription(TrackingMode mode) {
  switch (mode) {
    case TrackingMode.highAccuracy:
      return 'Sample tiap 3–5 detik. Untuk summit attempt atau rute presisi.';
    case TrackingMode.balanced:
      return 'Sample tiap 10–15 detik. Cocok untuk pendakian normal.';
    case TrackingMode.batterySaver:
      return 'Sample tiap 30–60 detik. Hiking panjang, baterai limited.';
  }
}

/// Estimasi konsumsi baterai per jam — angka kasar dari PRD §4.3.
/// Dipakai sebagai sub-label di start sheet ("~12% / jam").
String batteryEstimateLabel(TrackingMode mode) {
  switch (mode) {
    case TrackingMode.highAccuracy:
      return '~15% / jam';
    case TrackingMode.balanced:
      return '~8% / jam';
    case TrackingMode.batterySaver:
      return '~4% / jam';
  }
}
