import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../gpx/data/gpx_service.dart';
import '../../gpx/domain/imported_route.dart';
import '../../gpx/presentation/gpx_import_preview_screen.dart';

/// Tombol icon untuk import GPX dari file picker — PRD US-GPX-01.
class GpxImportButton extends ConsumerWidget {
  const GpxImportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Import GPX',
      icon: const Icon(Icons.file_upload_outlined),
      onPressed: () => _pickAndPreview(context, ref),
    );
  }

  Future<void> _pickAndPreview(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l = AppLocalizations.of(context);
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: <String>['gpx'],
      );
      if (result == null || result.files.isEmpty) return;

      final PlatformFile picked = result.files.single;
      final String path = picked.path ?? '';
      if (path.isEmpty) return;

      final String content = await File(path).readAsString();
      final ImportedRoute route = GpxService.parse(content, sourceFile: picked.name);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => GpxImportPreviewScreen(route: route),
          fullscreenDialog: true,
        ),
      );
    } on GpxImportException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on Object catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.commonComingSoon}: $e')),
      );
    }
  }
}
