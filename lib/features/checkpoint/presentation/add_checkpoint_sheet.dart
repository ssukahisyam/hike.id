import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/section_header.dart';
import '../data/checkpoint_repository.dart';
import '../domain/checkpoint.dart';

const Uuid _uuid = Uuid();

/// Bottom sheet untuk tambah checkpoint — DESIGN.md §6.6.
///
/// Workflow: user tap FAB saat tracking, atau long-press peta.
/// Aksi tambah harus < 5 detik / 3 tap (PRD US-CHK-01).
Future<Checkpoint?> showAddCheckpointSheet(
  BuildContext context, {
  required double latitude,
  required double longitude,
  double? elevation,
  String? tripId,
}) {
  return showModalBottomSheet<Checkpoint>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<HSurface>()!.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(HRadius.xl)),
    ),
    builder: (BuildContext c) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
      child: _AddCheckpointForm(
        latitude: latitude,
        longitude: longitude,
        elevation: elevation,
        tripId: tripId,
      ),
    ),
  );
}

class _AddCheckpointForm extends ConsumerStatefulWidget {
  const _AddCheckpointForm({
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.tripId,
  });

  final double latitude;
  final double longitude;
  final double? elevation;
  final String? tripId;

  @override
  ConsumerState<_AddCheckpointForm> createState() => _AddCheckpointFormState();
}

class _AddCheckpointFormState extends ConsumerState<_AddCheckpointForm> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  CheckpointType _type = CheckpointType.pos;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        HSpacing.s5,
        0,
        HSpacing.s5,
        HSpacing.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Tambah checkpoint',
            style: HTypography.headingLg.copyWith(color: s.textPrimary),
          ),
          const SizedBox(height: HSpacing.s4),
          const SectionHeader(label: 'Tipe'),
          const SizedBox(height: HSpacing.s2),
          Wrap(
            spacing: HSpacing.s2,
            runSpacing: HSpacing.s2,
            children: <Widget>[
              for (final CheckpointType t in CheckpointType.values)
                _TypePill(
                  type: t,
                  selected: _type == t,
                  onTap: () => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: HSpacing.s4),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama',
              hintText: 'Contoh: Pos 2 Sumber Air',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: HSpacing.s3),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: HSpacing.s4),
          Container(
            padding: const EdgeInsets.all(HSpacing.s3),
            decoration: BoxDecoration(
              color: s.surfaceMuted,
              borderRadius: BorderRadius.circular(HRadius.md),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.location_on_outlined, size: 18, color: s.textTertiary),
                const SizedBox(width: HSpacing.s2),
                Expanded(
                  child: Text(
                    '${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
                    style: HTypography.monoSm.copyWith(color: s.textSecondary),
                  ),
                ),
                if (widget.elevation != null)
                  Text(
                    '${widget.elevation!.toStringAsFixed(0)} m',
                    style: HTypography.monoSm.copyWith(color: s.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: HSpacing.s5),
          AppButton(
            label: 'Simpan',
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final String name = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : _type.label;
    setState(() => _saving = true);
    try {
      final Checkpoint cp = Checkpoint(
        id: _uuid.v4(),
        tripId: widget.tripId,
        type: _type,
        name: name,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        latitude: widget.latitude,
        longitude: widget.longitude,
        elevation: widget.elevation,
        createdAt: DateTime.now(),
      );
      await ref.read(checkpointRepositoryProvider).insert(cp);
      if (!mounted) return;
      Navigator.of(context).pop(cp);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final CheckpointType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final HSurface s = Theme.of(context).extension<HSurface>()!;
    final Color bg = selected ? type.color : s.surfaceMuted;
    final Color fg = selected ? HColors.mist0 : s.textPrimary;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(HRadius.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(HRadius.full),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HSpacing.s3,
            vertical: HSpacing.s2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(type.icon, size: 16, color: fg),
              const SizedBox(width: HSpacing.s1),
              Text(type.label, style: HTypography.labelLg.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
