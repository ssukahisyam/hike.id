import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/color_tokens.dart';
import '../core/widgets/offline_banner.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// Bottom navigation shell — DESIGN.md §11.1.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const List<String> _branches = <String>[
    AppRoute.home,
    AppRoute.map,
    AppRoute.history,
    AppRoute.stats,
  ];

  int _indexFromLocation(String location) {
    for (int i = _branches.length - 1; i >= 0; i--) {
      if (location == _branches[i] || location.startsWith('${_branches[i]}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final String location = GoRouterState.of(context).uri.path;
    final int index = _indexFromLocation(location);

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Banner offline global — DESIGN.md §6.7. Auto-watch
          // isOnlineProvider; tidak muncul saat user online.
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: s.borderSubtle)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (int i) => context.go(_branches[i]),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: l.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map_rounded),
              label: l.navMap,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history_rounded),
              label: l.navHistory,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart_rounded),
              label: l.navStats,
            ),
          ],
        ),
      ),
    );
  }
}
