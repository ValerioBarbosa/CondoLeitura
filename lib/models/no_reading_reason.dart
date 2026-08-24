const noReadingReasons = [
  'Morador ausente',
  'Medidor inacessível',
  'Medidor danificado',
  'Recusa do morador',
  'Outro',
];

class NoReadingRecord {
  const NoReadingRecord({
    required this.id,
    required this.meterId,
    required this.reason,
    this.notes = '',
    required this.createdAt,
  });

  final String id;
  final String meterId;
  final String reason;
  final String notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'meterId': meterId,
        'reason': reason,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NoReadingRecord.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return NoReadingRecord(
      id: json['id'] as String,
      meterId: json['meterId'] as String,
      reason: json['reason'] as String,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
    );
  }
}
