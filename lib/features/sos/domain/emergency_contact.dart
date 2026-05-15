import 'package:equatable/equatable.dart';

/// Maksimum 3 emergency contact per user — PRD §4.10.
class EmergencyContact extends Equatable {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relation,
    this.priority = 1,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? relation;
  final int priority;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[id, name, phone, relation, priority, createdAt];
}
