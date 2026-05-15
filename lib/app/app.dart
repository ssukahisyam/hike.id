import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

class HikeIdApp extends ConsumerWidget {
  const HikeIdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HThemeMode mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Hike.id',
      debugShowCheckedModeBanner: false,
      themeMode: resolveMaterialThemeMode(mode),
      theme: mode == HThemeMode.outdoor ? AppTheme.outdoor() : AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        // Hormati system reduce motion + clamp font size 0.8x..1.3x (DESIGN.md §7.5).
        final MediaQueryData mq = MediaQuery.of(context);
        final double clampedScale = mq.textScaler.scale(1).clamp(0.8, 1.3);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(clampedScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
