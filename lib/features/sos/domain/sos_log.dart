import 'package:equatable/equatable.dart';

/// Aksi yang dilakukan user di SOS screen.
enum SosAction { opened, copied, shared, called }

class SosLog extends Equatable {
  const SosLog({
    required this.id,
    required this.openedAt,
    this.latitude,
    this.longitude,
    this.accuracy,
    required this.action,
    this.shareVia,
    this.tripId,
  });

  final String id;
  final DateTime openedAt;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final SosAction action;
  final String? shareVia;
  final String? tripId;

  @override
  List<Object?> get props => <Object?>[
        id,
        openedAt,
        latitude,
        longitude,
        accuracy,
        action,
        shareVia,
        tripId,
      ];
}
