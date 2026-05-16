import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/connectivity_service.dart';
import '../theme/color_tokens.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Banner offline — DESIGN.md §6.7.
///
/// Tipis, hangat, persistent — tidak panic-inducing.
///
/// Dua bentuk pemakaian:
///
/// 1. **Reactive (recommended):** `const OfflineBanner()` — auto-watch
///    `isOnlineProvider` dan munculkan banner saat user offline.
/// 2. **Manual:** `OfflineBanner(show: !online)` — caller kontrol kapan
///    banner muncul. Berguna saat connectivity provider belum tersedia
///    atau untuk testing.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, this.show});

  /// Bila null, widget akan auto-watch `isOnlineProvider`.
  /// Bila non-null, dipakai apa adanya (manual mode).
  final bool? show;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool shouldShow;
    if (show != null) {
      shouldShow = show!;
    } else {
      // Default ke online (banner hidden) selama provider belum emit pertama
      // — hindari flash banner saat app baru dibuka.
      final bool online = ref.watch(isOnlineProvider).valueOrNull ?? true;
      shouldShow = !online;
    }
    if (!shouldShow) return const SizedBox.shrink();
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
