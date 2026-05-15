import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../sos/data/last_location_provider.dart';
import 'hike_map_view.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<LastKnownLocation?> loc = ref.watch(lastKnownLocationProvider);
    final LatLng? current =
        loc.value == null ? null : LatLng(loc.value!.latitude, loc.value!.longitude);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(title: Text(l.navMap)),
      body: HikeMapView(
        currentPosition: current,
        initialCenter: current,
        initialZoom: current == null ? 5 : 13,
      ),
    );
  }
}
