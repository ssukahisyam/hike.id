import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_block.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../history/presentation/history_screen.dart';
import '../../tracking/application/location_permission_controller.dart';
import '../../tracking/data/gps_service.dart';
import '../../tracking/domain/trip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _permissionRequested = false;

  @override
  void initState() {
    super.initState();
    // Trigger system permission dialog di first frame setelah home tampil.
    // Tidak block UI; user lihat home dulu, lalu popup muncul.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _permissionRequested) return;
      _permissionRequested = true;
      final LocationPermissionStatus current =
          ref.read(locationPermissionProvider);
      // Hanya request kalau belum granted & belum deniedForever.
      // Kalau deniedForever, user harus buka Settings — request() tidak
      // akan munculkan dialog lagi.
      if (current == LocationPermissionStatus.denied) {
        await ref.read(locationPermissionProvider.notifier).request();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<List<Trip>> tripsAsync = ref.watch(tripsStreamProvider);
    final List<Trip> all = tripsAsync.value ?? const <Trip>[];
    final List<Trip> completed =
        all.where((Trip t) => t.status == TripStatus.completed).toList();
    final List<Trip> recent = completed.take(3).toList();

    final double totalDistance = completed.fold<double>(
      0,
      (double acc, Trip t) => acc + t.totalDistance,
    );
    final double totalElevGain = completed.fold<double>(
      0,
      (double acc, Trip t) => acc + t.elevationGain,
    );

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settingsTitle,
            onPressed: () => context.push(AppRoute.settings),
          ),
          IconButton(
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: l.sosTitle,
            color: HColors.alpenglow500,
            onPressed: () => context.push(AppRoute.sos),
          ),
          const SizedBox(width: HSpacing.s2),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: HSpacing.screenPaddingH,
            vertical: HSpacing.s2,
          ),
          children: <Widget>[
            Text(
              l.homeGreeting,
              style: HTypography.displayLg.copyWith(color: s.textPrimary),
            ),
            const SizedBox(height: HSpacing.s2),
            Text(
              l.homeSubGreeting,
              style: HTypography.bodyLg.copyWith(color: s.textSecondary),
            ),
            const _PermissionBannerCompact(),
            const SizedBox(height: HSpacing.s5),
            AppButton(
              label: l.homeStartHike,
              size: AppButtonSize.hero,
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.push(AppRoute.tracking),
            ),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.homeRecentSection),
            const SizedBox(height: HSpacing.s3),
            if (recent.isEmpty)
              EmptyState(
                icon: Icons.terrain_outlined,
                headline: l.historyEmptyHeadline,
                body: l.historyEmptyBody,
                action: AppButton(
                  label: l.homeStartHike,
                  variant: AppButtonVariant.secondary,
                  fullWidth: false,
                  onPressed: () => context.push(AppRoute.tracking),
                ),
              )
            else
              ...recent.map((Trip t) => Padding(
                    padding: const EdgeInsets.only(bottom: HSpacing.s2),
                    child: _RecentTripCard(trip: t),
                  ),),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.homeQuickStatsSection),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalTrips,
                      value: completed.length.toString(),
                      unit: 'trip',
                    ),
                  ),
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalDistance,
                      value: totalDistance >= 1000
                          ? (totalDistance / 1000).toStringAsFixed(1).replaceAll('.', ',')
                          : totalDistance.round().toString(),
                      unit: totalDistance >= 1000 ? 'km' : 'm',
                    ),
                  ),
                  Expanded(
                    child: StatBlock(
                      label: l.statTotalElevation,
                      value: totalElevGain.round().toString(),
                      unit: 'm',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HSpacing.s8),
          ],
        ),
      ),
    );
  }
}

class _RecentTripCard extends StatelessWidget {
  const _RecentTripCard({required this.trip});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return AppCard(
      onTap: () => context.push('/trip/${trip.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            trip.name,
            style: HTypography.headingMd.copyWith(color: s.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: HSpacing.s2),
          Text(
            '${Format.distance(trip.totalDistance)} · ${Format.duration(trip.totalDuration)}',
            style: HTypography.monoSm.copyWith(color: s.textSecondary),
          ),
        ],
      ),
    );
  }
}


/// Banner kompak yang muncul di home saat permission lokasi belum granted.
/// Menggantikan tracking screen yang fail silently — user lihat status
/// & tombol aksi langsung dari home.
class _PermissionBannerCompact extends ConsumerWidget {
  const _PermissionBannerCompact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final LocationPermissionStatus status =
        ref.watch(locationPermissionProvider);
    if (status == LocationPermissionStatus.granted) {
      return const SizedBox.shrink();
    }

    final String message;
    final String? cta;
    final Future<void> Function() onTap;
    final IconData icon;

    switch (status) {
      case LocationPermissionStatus.granted:
        return const SizedBox.shrink();
      case LocationPermissionStatus.denied:
        message = 'Aktifkan izin lokasi supaya tracking bisa dimulai.';
        cta = 'Beri Izin';
        icon = Icons.location_on_outlined;
        onTap = () async {
          await ref.read(locationPermissionProvider.notifier).request();
        };
      case LocationPermissionStatus.deniedForever:
        message = 'Izin lokasi diblokir. Buka pengaturan untuk aktifkan.';
        cta = 'Buka Pengaturan';
        icon = Icons.settings_outlined;
        onTap = () async {
          await ref.read(locationPermissionProvider.notifier).openSettings();
          // Setelah user kembali, refresh ulang status.
          await Future<void>.delayed(const Duration(milliseconds: 500));
          await ref.read(locationPermissionProvider.notifier).refresh();
        };
      case LocationPermissionStatus.serviceDisabled:
        message = 'GPS device dimatikan. Aktifkan di pengaturan sistem.';
        cta = 'Refresh';
        icon = Icons.gps_off_outlined;
        onTap = () async {
          await ref.read(locationPermissionProvider.notifier).refresh();
        };
    }

    return Padding(
      padding: const EdgeInsets.only(top: HSpacing.s3),
      child: Container(
        padding: const EdgeInsets.all(HSpacing.s3),
        decoration: BoxDecoration(
          color: HColors.warningBg,
          borderRadius: BorderRadius.circular(HRadius.md),
          border: Border.all(color: HColors.warningBorder),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: HColors.alpenglow300),
            const SizedBox(width: HSpacing.s2),
            Expanded(
              child: Text(
                message,
                style: HTypography.bodySm.copyWith(color: HColors.alpenglow300),
              ),
            ),
            const SizedBox(width: HSpacing.s2),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: HColors.alpenglow300,
                padding: const EdgeInsets.symmetric(
                  horizontal: HSpacing.s3,
                  vertical: HSpacing.s2,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onTap,
              child: Text(cta),
            ),
          ],
        ),
      ),
    );
  }
}
