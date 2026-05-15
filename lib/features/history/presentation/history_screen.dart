import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(title: Text(l.historyTitle)),
      body: SafeArea(
        child: EmptyState(
          icon: Icons.terrain_outlined,
          headline: l.historyEmptyHeadline,
          body: l.historyEmptyBody,
          action: AppButton(
            label: l.homeStartHike,
            variant: AppButtonVariant.primary,
            fullWidth: false,
            onPressed: () => context.push(AppRoute.tracking),
          ),
        ),
      ),
    );
  }
}
