import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../data/emergency_contact_repository.dart';
import '../domain/emergency_contact.dart';

/// Bottom sheet untuk tambah kontak darurat — PRD §4.10.
///
/// Form sederhana:
/// - Nama (required)
/// - Nomor telepon (required, format Indonesia +62 atau 0xx)
/// - Relasi (optional, mis. 'Suami', 'Ibu')
///
/// Validasi: nama tidak kosong, nomor minimal 8 digit.
Future<void> showAddEmergencyContactSheet(BuildContext context) {
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
      child: const _AddEmergencyContactSheet(),
    ),
  );
}

class _AddEmergencyContactSheet extends ConsumerStatefulWidget {
  const _AddEmergencyContactSheet();

  @override
  ConsumerState<_AddEmergencyContactSheet> createState() =>
      _AddEmergencyContactSheetState();
}

class _AddEmergencyContactSheetState
    extends ConsumerState<_AddEmergencyContactSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _relationCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final String name = _nameCtrl.text.trim();
    final String phone = _phoneCtrl.text.trim();
    if (name.isEmpty) return 'Nama tidak boleh kosong';
    if (phone.isEmpty) return 'Nomor telepon tidak boleh kosong';
    final String digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 8) return 'Nomor telepon minimal 8 digit';
    return null;
  }

  Future<void> _submit() async {
    final String? err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final EmergencyContact contact = EmergencyContact(
        id: const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        relation: _relationCtrl.text.trim().isEmpty
            ? null
            : _relationCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await ref.read(emergencyContactRepositoryProvider).insert(contact);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Gagal simpan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(HSpacing.s5, 0, HSpacing.s5, HSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Tambah kontak darurat',
            style: HTypography.headingLg.copyWith(color: s.textPrimary),
          ),
          const SizedBox(height: HSpacing.s2),
          Text(
            'Kontak ini akan tampil di SOS screen untuk dipanggil cepat saat keadaan darurat.',
            style: HTypography.bodyMd.copyWith(color: s.textSecondary),
          ),
          const SizedBox(height: HSpacing.s4),
          TextField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nama',
              hintText: 'mis. Ibu, Bapak, Suami',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: HSpacing.s3),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nomor telepon',
              hintText: 'mis. 081234567890 atau +6281234567890',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: HSpacing.s3),
          TextField(
            controller: _relationCtrl,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Relasi (opsional)',
              hintText: 'mis. Pasangan, Saudara, Teman dekat',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: HSpacing.s3),
            Text(
              _error!,
              style: HTypography.bodySm.copyWith(color: HColors.danger),
            ),
          ],
          const SizedBox(height: HSpacing.s5),
          AppButton(
            label: 'Simpan',
            icon: Icons.save_outlined,
            isLoading: _busy,
            onPressed: _busy ? null : _submit,
          ),
          const SizedBox(height: HSpacing.s2),
          AppButton(
            label: 'Batal',
            variant: AppButtonVariant.ghost,
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
