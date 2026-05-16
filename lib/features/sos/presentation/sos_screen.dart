import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/emergency_contact_repository.dart';
import '../data/last_location_provider.dart';
import '../domain/emergency_contact.dart';

/// SOS screen — sengaja tenang, bukan panik.
///
/// Reference: DESIGN.md §11.3 + PRD §4.10.
/// Disclaimer eksplisit Hike.id tidak mengirim rescue otomatis.
class SosScreen extends ConsumerWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<LastKnownLocation?> location = ref.watch(lastKnownLocationProvider);
    final AsyncValue<List<EmergencyContact>> contacts =
        ref.watch(emergencyContactsProvider);

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
            location.when(
              loading: () => const _SkeletonCard(),
              error: (Object _, StackTrace __) => _NoLocationCard(message: l.sosNoLocationYet),
              data: (LastKnownLocation? loc) => loc == null
                  ? _NoLocationCard(message: l.sosNoLocationYet)
                  : _LocationCard(loc: loc, l: l),
            ),
            const SizedBox(height: HSpacing.s5),
            AppButton(
              label: l.sosCopyCoords,
              variant: AppButtonVariant.secondary,
              icon: Icons.copy_outlined,
              onPressed: location.value == null ? null : () => _copy(context, l, location.value!),
            ),
            const SizedBox(height: HSpacing.s3),
            AppButton(
              label: l.sosShareLocation,
              variant: AppButtonVariant.primary,
              icon: Icons.share_outlined,
              onPressed: location.value == null ? null : () => _share(context, location.value!),
            ),
            const SizedBox(height: HSpacing.sectionGap),
            SectionHeader(label: l.sosEmergencyContacts),
            const SizedBox(height: HSpacing.s3),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  ...contacts.when(
                    loading: () => <Widget>[const SizedBox.shrink()],
                    error: (Object _, StackTrace __) => <Widget>[const SizedBox.shrink()],
                    data: (List<EmergencyContact> list) => <Widget>[
                      for (int i = 0; i < list.length; i++) ...<Widget>[
                        if (i != 0) Divider(height: 1, color: s.divider),
                        _ContactRow(
                          name: list[i].name,
                          phone: list[i].phone,
                          subtitle: list[i].relation,
                          onCall: () => _call(list[i].phone),
                        ),
                      ],
                      if (list.isNotEmpty) Divider(height: 1, color: s.divider),
                    ],
                  ),
                  // Basarnas selalu tampil di paling bawah, dihardcode agar
                  // selalu tersedia walau user belum simpan kontak.
                  _ContactRow(
                    name: l.sosBasarnasNational,
                    phone: '115',
                    onCall: () => _call('115'),
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

  Future<void> _copy(
    BuildContext context,
    AppLocalizations l,
    LastKnownLocation loc,
  ) async {
    final String text = Format.latLng(loc.latitude, loc.longitude);
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.sosCoordinatesCopied)),
    );
  }

  Future<void> _share(BuildContext context, LastKnownLocation loc) async {
    final String mapsUrl =
        'https://maps.google.com/?q=${loc.latitude},${loc.longitude}';
    final String body =
        'Saya butuh bantuan. Lokasi terakhir saya:\n'
        '${Format.latLng(loc.latitude, loc.longitude)}\n'
        '$mapsUrl';
    await Share.share(body, subject: 'Bantuan — Hike.id');
  }

  Future<void> _call(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.loc, required this.l});
  final LastKnownLocation loc;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final int minutesAgo = loc.age.inMinutes;
    return AppCard(
      padding: const EdgeInsets.all(HSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            loc.latitude.toStringAsFixed(6),
            style: HTypography.monoXl.copyWith(color: s.textPrimary),
          ),
          Text(
            loc.longitude.toStringAsFixed(6),
            style: HTypography.monoXl.copyWith(color: s.textPrimary),
          ),
          const SizedBox(height: HSpacing.s3),
          Wrap(
            spacing: HSpacing.s5,
            runSpacing: HSpacing.s2,
            children: <Widget>[
              _MetaPair(
                label: l.sosAccuracy,
                value: loc.accuracy != null ? '±${loc.accuracy!.toStringAsFixed(0)}m' : '-',
              ),
              _MetaPair(
                label: l.sosElevation,
                value: loc.elevation != null ? '${loc.elevation!.toStringAsFixed(0)} m' : '-',
              ),
            ],
          ),
          const SizedBox(height: HSpacing.s2),
          Text(
            l.sosUpdatedAgo(minutesAgo),
            style: HTypography.monoSm.copyWith(color: s.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _NoLocationCard extends StatelessWidget {
  const _NoLocationCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return AppCard(
      padding: const EdgeInsets.all(HSpacing.s5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: HSpacing.s4),
        child: Text(
          message,
          style: HTypography.bodyMd.copyWith(color: s.textSecondary),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(HSpacing.s5),
      child: SizedBox(
        height: 80,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
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

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.name,
    required this.phone,
    this.subtitle,
    required this.onCall,
  });

  final String name;
  final String phone;
  final String? subtitle;
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
              backgroundColor: HColors.alpenglow400.withValues(alpha: 0.16),
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
                  Text(
                    name,
                    style: HTypography.headingMd.copyWith(color: s.textPrimary),
                  ),
                  Text(
                    subtitle == null ? phone : '$phone · $subtitle',
                    style: HTypography.monoSm.copyWith(color: s.textSecondary),
                  ),
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
