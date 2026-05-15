import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';

/// SOS screen — sengaja tenang, bukan panik.
///
/// Reference: DESIGN.md §11.3 dan PRD §4.10.
/// Disclaimer eksplisit bahwa Hike.id tidak mengirim rescue otomatis.
class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);

    // TODO(phase-3): subscribe ke last known GPS coordinate dari tracking service.
    // Untuk MVP shell ini, koordinat ditampilkan placeholder agar layout terverifikasi.
    const double? lat = null;
    const double? lng = null;
    const double? elev = null;
    const double? accuracy = null;
    const int? minutesAgo = null;

    final bool hasLocation = lat != null && lng != null;

    return Scaffold(
      backgroundColor: s.background,
      appBar: AppBar(
        title: Text(l.sosTitle),
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
            SectionHeader(label: l.sosLastLocation),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              padding: const EdgeInsets.all(HSpacing.s5),
              child: hasLocation
                  ? _LocationBlock(
                      lat: lat,
                      lng: lng,
                      accuracy: accuracy,
                      elev: elev,
                      minutesAgo: minutesAgo,
                      l: l,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: HSpacing.s4),
                      child: Text(
                        l.sosNoLocationYet,
                        style: HTypography.bodyMd.copyWith(color: s.textSecondary),
                      ),
                    ),
            ),
            const SizedBox(height: HSpacing.s5),
            AppButton(
              label: l.sosCopyCoords,
              variant: AppButtonVariant.secondary,
              icon: Icons.copy_outlined,
              onPressed: hasLocation
                  ? () async {
                      await Clipboard.setData(ClipboardData(text: Format.latLng(lat, lng)));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.sosCoordinatesCopied)),
                        );
                      }
                    }
                  : null,
            ),
            const SizedBox(height: HSpacing.s3),
            AppButton(
              label: l.sosShareLocation,
              variant: AppButtonVariant.primary,
              icon: Icons.share_outlined,
              onPressed: hasLocation
                  ? () {
                      // TODO(phase-8): integrate share_plus.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.commonComingSoon)),
                      );
                    }
                  : null,
            ),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.sosEmergencyContacts),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  // TODO(phase-8): map dari EmergencyContacts table.
                  _EmergencyContactRow(
                    name: l.sosBasarnasNational,
                    phone: '115',
                    onCall: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.commonComingSoon)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: HSpacing.sectionGap),
            Text(
              l.sosDisclaimer,
              style: HTypography.bodySm.copyWith(color: s.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HSpacing.s8),
          ],
        ),
      ),
    );
  }
}

class _LocationBlock extends StatelessWidget {
  const _LocationBlock({
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.elev,
    required this.minutesAgo,
    required this.l,
  });

  final double lat;
  final double lng;
  final double? accuracy;
  final double? elev;
  final int? minutesAgo;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          lat.toStringAsFixed(6),
          style: HTypography.monoXl.copyWith(color: s.textPrimary),
        ),
        Text(
          lng.toStringAsFixed(6),
          style: HTypography.monoXl.copyWith(color: s.textPrimary),
        ),
        const SizedBox(height: HSpacing.s3),
        Wrap(
          spacing: HSpacing.s5,
          runSpacing: HSpacing.s2,
          children: <Widget>[
            _MetaPair(
              label: l.sosAccuracy,
              value: accuracy != null ? '±${accuracy!.toStringAsFixed(0)}m' : '-',
            ),
            _MetaPair(
              label: l.sosElevation,
              value: elev != null ? '${elev!.toStringAsFixed(0)} m' : '-',
            ),
          ],
        ),
        if (minutesAgo != null) ...<Widget>[
          const SizedBox(height: HSpacing.s2),
          Text(
            l.sosUpdatedAgo(minutesAgo!),
            style: HTypography.monoSm.copyWith(color: s.textTertiary),
          ),
        ],
      ],
    );
  }
}

class _MetaPair extends StatelessWidget {
  const _MetaPair({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: HTypography.labelMd.copyWith(color: s.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(value, style: HTypography.monoMd.copyWith(color: s.textPrimary)),
      ],
    );
  }
}

class _EmergencyContactRow extends StatelessWidget {
  const _EmergencyContactRow({
    required this.name,
    required this.phone,
    required this.onCall,
  });

  final String name;
  final String phone;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return InkWell(
      onTap: onCall,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HSpacing.s4,
          vertical: HSpacing.s4,
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 18,
              backgroundColor: HColors.alpenglow400.withOpacity(0.16),
              child: const Icon(
                Icons.phone_in_talk_outlined,
                color: HColors.alpenglow500,
                size: 18,
              ),
            ),
            const SizedBox(width: HSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: HTypography.headingMd.copyWith(color: s.textPrimary)),
                  Text(phone, style: HTypography.monoMd.copyWith(color: s.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
