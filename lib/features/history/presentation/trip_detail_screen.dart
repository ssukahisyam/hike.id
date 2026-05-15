import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(title: Text('Trip $tripId')),
      body: EmptyState(
        icon: Icons.timeline_outlined,
        headline: l.commonComingSoon,
        body: l.commonComingSoonBody,
      ),
    );
  }
}
