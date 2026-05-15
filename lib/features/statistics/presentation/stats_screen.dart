import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(title: Text(l.navStats)),
      body: EmptyState(
        icon: Icons.bar_chart_outlined,
        headline: l.commonComingSoon,
        body: l.commonComingSoonBody,
      ),
    );
  }
}
