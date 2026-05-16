import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstraksi connectivity supaya bisa di-mock di test.
abstract class ConnectivityService {
  /// Snapshot online status saat ini.
  Future<bool> isOnline();

  /// Stream online status — emit saat berubah.
  Stream<bool> onlineStream();
}

class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _isOnlineFromList(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    // Anggap online kalau ada minimal satu transport selain 'none'.
    return results.any((ConnectivityResult r) => r != ConnectivityResult.none);
  }

  @override
  Future<bool> isOnline() async {
    final List<ConnectivityResult> r = await _connectivity.checkConnectivity();
    return _isOnlineFromList(r);
  }

  @override
  Stream<bool> onlineStream() async* {
    // Emit current snapshot dulu supaya consumer langsung tahu state awal.
    yield await isOnline();
    yield* _connectivity.onConnectivityChanged.map(_isOnlineFromList);
  }
}

/// Override-able provider untuk testing.
final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>((Ref ref) => ConnectivityPlusService());

/// Stream online status — true kalau ada koneksi internet (transport apapun
/// selain 'none'). Catatan: connectivity_plus tidak menjamin ada akses
/// internet asli — hanya transport. Untuk reachability gunakan ping ke endpoint
/// (di luar scope MVP).
///
/// Pakai dengan `ref.watch(isOnlineProvider).valueOrNull ?? true` di widget —
/// fallback `true` supaya banner tidak flash sebelum stream emit.
final StreamProvider<bool> isOnlineProvider = StreamProvider<bool>((Ref ref) {
  return ref.watch(connectivityServiceProvider).onlineStream();
});
