import 'package:equatable/equatable.dart';

enum NoteType { text, photo, voice }

class Note extends Equatable {
  const Note({
    required this.id,
    this.tripId,
    this.checkpointId,
    required this.type,
    this.content,
    this.filePath,
    this.durationMs,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  final String id;
  final String? tripId;
  final String? checkpointId;
  final NoteType type;
  final String? content;
  final String? filePath;
  final int? durationMs;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        tripId,
        checkpointId,
        type,
        content,
        filePath,
        durationMs,
        latitude,
        longitude,
        createdAt,
      ];
}
