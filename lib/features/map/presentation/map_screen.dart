import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    // Placeholder — flutter_map akan diintegrasikan di Phase 5 (PLANNING §7).
    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(title: Text(l.navMap)),
      body: EmptyState(
        icon: Icons.map_outlined,
        headline: l.commonComingSoon,
        body: l.commonComingSoonBody,
      ),
    );
  }
}
