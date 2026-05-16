import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';

/// Bottom sheet sederhana untuk lapor bug — Phase 10a.
///
/// Tujuan: tester bisa lapor bug dengan device info & app version
/// terisi otomatis, tanpa perlu app punya server backend.
///
/// Behavior:
/// 1. User isi judul & langkah reproduce.
/// 2. App generate body lengkap (judul + langkah + device info + app version).
/// 3. User pilih channel:
///    - **GitHub Issue** → buka URL pre-filled.
///    - **Email** → buka mail client pre-filled.
///    - **Salin** → text di-copy ke clipboard, user paste sendiri.
///
/// Kita TIDAK kirim apapun ke server — sesuai komitmen privacy.
Future<void> showBugReportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<HSurface>()!.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(HRadius.xl)),
    ),
    builder: (BuildContext c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
      child: const _BugReportSheet(),
    ),
  );
}

const String _kIssueUrlBase = 'https://github.com/ssukahisyam/hike.id/issues/new';
const String _kFeedbackEmail = 'feedback@hike.id'; // placeholder; ganti saat domain live
const String _kAppVersion = '0.1.1+2'; // sync manual dengan pubspec.yaml

class _BugReportSheet extends StatefulWidget {
  const _BugReportSheet();

  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _stepsCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  String _deviceInfo() {
    final StringBuffer b = StringBuffer();
    b.writeln('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    b.writeln('Locale: ${Platform.localeName}');
    b.writeln('App version: $_kAppVersion');
    return b.toString();
  }

  String _composeBody() {
    final StringBuffer b = StringBuffer();
    final String title = _titleCtrl.text.trim();
    final String steps = _stepsCtrl.text.trim();
    if (steps.isNotEmpty) {
      b.writeln('## Langkah reproduce');
      b.writeln(steps);
      b.writeln();
    }
    b.writeln('## Device info (auto-fill)');
    b.writeln(_deviceInfo());
    b.writeln('---');
    b.writeln('Dilaporkan dari in-app bug reporter. Title: $title');
    return b.toString();
  }

  Uri _githubIssueUri() {
    final String title = _titleCtrl.text.trim();
    final String body = _composeBody();
    return Uri.parse(_kIssueUrlBase).replace(
      queryParameters: <String, String>{
        'title': title.isEmpty ? '[bug] ' : title,
        'body': body,
        'labels': 'bug,private-testing',
      },
    );
  }

  Uri _emailUri() {
    final String title = _titleCtrl.text.trim();
    final String body = _composeBody();
    return Uri(
      scheme: 'mailto',
      path: _kFeedbackEmail,
      query: _encodeQueryParameters(<String, String>{
        'subject': title.isEmpty ? '[Hike.id bug]' : '[Hike.id] $title',
        'body': body,
      }),
    );
  }

  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
  }

  Future<void> _open(Uri uri) async {
    final bool ok = await canLaunchUrl(uri);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa buka aplikasi target')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _copy() async {
    final String fullText = '${_titleCtrl.text.trim()}\n\n${_composeBody()}';
    await Clipboard.setData(ClipboardData(text: fullText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Laporan disalin ke clipboard')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(HSpacing.s5, 0, HSpacing.s5, HSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Lapor bug',
            style: HTypography.headingLg.copyWith(color: s.textPrimary),
          ),
          const SizedBox(height: HSpacing.s2),
          Text(
            'Bantu kita perbaiki dengan deskripsi singkat. Device info terisi otomatis.',
            style: HTypography.bodyMd.copyWith(color: s.textSecondary),
          ),
          const SizedBox(height: HSpacing.s4),
          TextField(
            controller: _titleCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Judul singkat',
              hintText: 'mis. Tracking berhenti saat layar mati',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: HSpacing.s3),
          TextField(
            controller: _stepsCtrl,
            minLines: 4,
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: 'Langkah reproduce',
              hintText:
                  '1. Mulai tracking\n2. Lock screen\n3. Tunggu 30 menit\n4. Buka app, polyline ada gap',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: HSpacing.s4),
          Container(
            padding: const EdgeInsets.all(HSpacing.s3),
            decoration: BoxDecoration(
              color: s.surfaceMuted,
              borderRadius: BorderRadius.circular(HRadius.md),
              border: Border.all(color: s.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Device info (auto)',
                  style: HTypography.labelMd.copyWith(color: s.textTertiary),
                ),
                const SizedBox(height: 4),
                Text(
                  _deviceInfo().trim(),
                  style: HTypography.monoSm.copyWith(color: s.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: HSpacing.s4),
          AppButton(
            label: 'Buka GitHub Issue',
            icon: Icons.bug_report_rounded,
            onPressed: () => _open(_githubIssueUri()),
          ),
          const SizedBox(height: HSpacing.s2),
          AppButton(
            label: 'Kirim via Email',
            icon: Icons.email_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => _open(_emailUri()),
          ),
          const SizedBox(height: HSpacing.s2),
          AppButton(
            label: 'Salin ke Clipboard',
            icon: Icons.content_copy_rounded,
            variant: AppButtonVariant.ghost,
            onPressed: _copy,
          ),
        ],
      ),
    );
  }
}
