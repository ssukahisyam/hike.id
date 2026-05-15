import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';

/// Tipe checkpoint — PRD §4.6.
enum CheckpointType {
  pos('Pos', Icons.flag_outlined, HColors.forest500),
  air('Air', Icons.water_drop_outlined, HColors.info),
  kemah('Kemah', Icons.cottage_outlined, HColors.volcanic500),
  puncak('Puncak', Icons.terrain_outlined, HColors.alpenglow400),
  bahaya('Bahaya', Icons.warning_amber_outlined, HColors.danger),
  custom('Lainnya', Icons.location_on_outlined, HColors.mist600);

  const CheckpointType(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;

  static CheckpointType fromName(String? n) => CheckpointType.values
      .firstWhere((CheckpointType e) => e.name == n, orElse: () => CheckpointType.custom);
}

class Checkpoint extends Equatable {
  const Checkpoint({
    required this.id,
    this.tripId,
    required this.type,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.createdAt,
  });

  final String id;
  final String? tripId;
  final CheckpointType type;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double? elevation;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        tripId,
        type,
        name,
        description,
        latitude,
        longitude,
        elevation,
        createdAt,
      ];
}
