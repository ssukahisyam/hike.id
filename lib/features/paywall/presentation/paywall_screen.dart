import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/generated/app_localizations.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _yearly = true;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    final List<String> features = <String>[
      l.paywallFeatureUnlimitedTiles,
      l.paywallFeatureUnlimitedCheckpoint,
      l.paywallFeaturePhotoVoice,
      l.paywallFeatureStats,
      l.paywallFeatureExport,
      l.paywallFeatureGroup,
    ];

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: HSpacing.screenPaddingH,
            vertical: HSpacing.s4,
          ),
          children: <Widget>[
            Text(l.paywallTitle, style: HTypography.displayLg.copyWith(color: s.textPrimary)),
            const SizedBox(height: HSpacing.s2),
            Text(
              l.paywallSubtitle,
              style: HTypography.bodyLg.copyWith(color: s.textSecondary),
            ),
            const SizedBox(height: HSpacing.s6),
            for (final String f in features) ...<Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: HSpacing.s2),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_rounded, color: s.actionPrimary, size: 20),
                    const SizedBox(width: HSpacing.s2),
                    Expanded(
                      child: Text(f, style: HTypography.bodyLg.copyWith(color: s.textPrimary)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: HSpacing.s6),
            _BillingToggle(
              yearly: _yearly,
              onChanged: (bool v) => setState(() => _yearly = v),
            ),
            const SizedBox(height: HSpacing.s5),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    _yearly ? 'Rp 199.000 / tahun' : 'Rp 29.000 / bulan',
                    style: HTypography.monoXl.copyWith(color: s.textPrimary),
                  ),
                  if (_yearly) ...<Widget>[
                    const SizedBox(height: HSpacing.s1),
                    Text(
                      l.paywallSavePerYear,
                      style: HTypography.bodySm.copyWith(color: s.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: HSpacing.s6),
            AppButton(
              label: l.paywallStartTrial,
              variant: AppButtonVariant.accent,
              size: AppButtonSize.hero,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.commonComingSoon)),
                );
              },
            ),
            const SizedBox(height: HSpacing.s3),
            Text(
              l.paywallCancellable,
              textAlign: TextAlign.center,
              style: HTypography.bodySm.copyWith(color: s.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({required this.yearly, required this.onChanged});
  final bool yearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: s.surfaceMuted,
        borderRadius: BorderRadius.circular(HRadius.full),
        border: Border.all(color: s.borderSubtle),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _Pill(label: 'Bulanan', selected: !yearly, onTap: () => onChanged(false))),
          Expanded(child: _Pill(label: 'Tahunan', selected: yearly, onTap: () => onChanged(true))),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Material(
      color: selected ? s.actionPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(HRadius.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(HRadius.full),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: HSpacing.s3),
          child: Center(
            child: Text(
              label,
              style: HTypography.labelLg.copyWith(
                color: selected ? s.actionPrimaryFg : s.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
