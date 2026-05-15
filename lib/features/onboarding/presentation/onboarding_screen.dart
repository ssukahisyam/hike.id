import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    final List<_OnboardingPage> pages = <_OnboardingPage>[
      _OnboardingPage(icon: Icons.signal_wifi_off_rounded, title: l.onboarding1Title, body: l.onboarding1Body),
      _OnboardingPage(icon: Icons.map_outlined, title: l.onboarding2Title, body: l.onboarding2Body),
      _OnboardingPage(icon: Icons.health_and_safety_outlined, title: l.onboarding3Title, body: l.onboarding3Body),
      _OnboardingPage(icon: Icons.lock_outline_rounded, title: l.onboarding4Title, body: l.onboarding4Body),
    ];
    final bool isLast = _index == pages.length - 1;

    return Scaffold(
      backgroundColor: s.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(HSpacing.s4),
                child: TextButton(
                  onPressed: () => context.go(AppRoute.home),
                  child: Text(
                    l.onboardingSkip,
                    style: HTypography.labelLg.copyWith(color: s.textSecondary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (int i) => setState(() => _index = i),
                itemCount: pages.length,
                itemBuilder: (BuildContext c, int i) => _OnboardingPageWidget(page: pages[i]),
              ),
            ),
            const SizedBox(height: HSpacing.s4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _index == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _index == i ? s.actionPrimary : s.borderDefault,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: HSpacing.s5),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HSpacing.screenPaddingH,
                0,
                HSpacing.screenPaddingH,
                HSpacing.s5,
              ),
              child: AppButton(
                label: isLast ? l.onboardingFinish : l.onboardingNext,
                size: AppButtonSize.hero,
                onPressed: () {
                  if (isLast) {
                    context.go(AppRoute.home);
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
}

class _OnboardingPageWidget extends StatelessWidget {
  const _OnboardingPageWidget({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HSpacing.s8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: s.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: s.borderSubtle),
            ),
            child: Icon(page.icon, size: 40, color: HColors.forest500),
          ),
          const SizedBox(height: HSpacing.s8),
          Text(
            page.title,
            style: HTypography.displayLg.copyWith(color: s.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: HSpacing.s3),
          Text(
            page.body,
            style: HTypography.bodyLg.copyWith(color: s.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
