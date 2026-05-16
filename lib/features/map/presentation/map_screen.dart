import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../sos/data/last_location_provider.dart';
import '../../tracking/application/location_permission_controller.dart';
import '../../tracking/data/gps_service.dart';
import 'hike_map_view.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<LastKnownLocation?> loc =
        ref.watch(lastKnownLocationProvider);
    final LocationPermissionStatus permStatus =
        ref.watch(locationPermissionProvider);

    final LatLng? current = loc.value == null
        ? null
        : LatLng(loc.value!.latitude, loc.value!.longitude);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        title: Text(l.navMap),
        actions: <Widget>[
          if (permStatus != LocationPermissionStatus.granted)
            IconButton(
              icon: const Icon(Icons.location_off_outlined),
              tooltip: 'Izin lokasi belum diberikan',
              color: HColors.alpenglow500,
              onPressed: () => _handlePermissionTap(permStatus),
            ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          HikeMapView(
            controller: _mapController,
            currentPosition: current,
            initialCenter: current,
            initialZoom: current == null ? 5 : 13,
          ),
          // Overlay banner kalau permission belum granted
          if (permStatus != LocationPermissionStatus.granted)
            Positioned(
              top: HSpacing.s4,
              left: HSpacing.s4,
              right: HSpacing.s4,
              child: _PermissionPrompt(
                status: permStatus,
                onTap: () => _handlePermissionTap(permStatus),
              ),
            ),
        ],
      ),
      floatingActionButton: current == null
          ? null
          : FloatingActionButton(
              heroTag: 'map-locate-me',
              tooltip: 'Lokasi saya',
              backgroundColor: s.actionPrimary,
              foregroundColor: s.actionPrimaryFg,
              onPressed: () {
                _mapController.move(current, 15);
              },
              child: const Icon(Icons.my_location_rounded),
            ),
    );
  }

  Future<void> _handlePermissionTap(LocationPermissionStatus status) async {
    final LocationPermissionController ctrl =
        ref.read(locationPermissionProvider.notifier);
    switch (status) {
      case LocationPermissionStatus.granted:
        return;
      case LocationPermissionStatus.denied:
        await ctrl.request();
      case LocationPermissionStatus.deniedForever:
        await ctrl.openSettings();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await ctrl.refresh();
      case LocationPermissionStatus.serviceDisabled:
        await ctrl.refresh();
    }
    // Trigger refresh lastKnownLocationProvider supaya GPS coba ambil
    // posisi setelah permission granted.
    // ignore: unused_result
    ref.refresh(lastKnownLocationProvider);
  }
}

/// Panel overlay informatif saat user belum grant permission lokasi.
/// Lebih mencolok daripada banner di home — di map screen, lokasi adalah
/// fungsi utama jadi user perlu langsung lihat call to action.
class _PermissionPrompt extends StatelessWidget {
  const _PermissionPrompt({
    required this.status,
    required this.onTap,
  });

  final LocationPermissionStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;

    final String headline;
    final String body;
    final String cta;
    final IconData icon;

    switch (status) {
      case LocationPermissionStatus.granted:
        return const SizedBox.shrink();
      case LocationPermissionStatus.denied:
        headline = 'Aktifkan lokasi';
        body =
            'Hike.id butuh izin lokasi untuk menampilkan posisi kamu di peta.';
        cta = 'Beri Izin';
        icon = Icons.location_on_outlined;
      case LocationPermissionStatus.deniedForever:
        headline = 'Izin lokasi diblokir';
        body =
            'Buka pengaturan untuk aktifkan izin lokasi Hike.id secara manual.';
        cta = 'Buka Pengaturan';
        icon = Icons.settings_outlined;
      case LocationPermissionStatus.serviceDisabled:
        headline = 'GPS dimatikan';
        body =
            'Aktifkan layanan lokasi di pengaturan sistem, lalu refresh.';
        cta = 'Refresh';
        icon = Icons.gps_off_outlined;
    }

    return Material(
      color: s.surface,
      borderRadius: BorderRadius.circular(HRadius.lg),
      elevation: 4,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(HSpacing.s4),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 22,
              backgroundColor: HColors.warningBg,
              child: Icon(icon, color: HColors.alpenglow400, size: 22),
            ),
            const SizedBox(width: HSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    headline,
                    style: HTypography.headingMd.copyWith(color: s.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: HTypography.bodySm.copyWith(color: s.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: HSpacing.s2),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: s.actionPrimary,
                foregroundColor: s.actionPrimaryFg,
              ),
              child: Text(cta),
            ),
          ],
        ),
      ),
    );
  }
}
