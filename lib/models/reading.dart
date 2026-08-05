enum SyncStatus { pending, syncing, synced, failed }

class Reading {
  const Reading({
    this.id,
    required this.localId,
    required this.unitId,
    required this.meterId,
    required this.value,
    required this.readingDate,
    required this.photoPath,
    this.ocrRawText,
    this.ocrConfidence,
    this.requiresReview = false,
    this.confirmedManually = false,
    this.notes,
    required this.createdAt,
  });

  final int? id;
  final String localId;
  final int unitId;
  final int meterId;
  final double value;
  final DateTime readingDate;
  final String photoPath;
  final String? ocrRawText;
  final double? ocrConfidence;
  final bool requiresReview;
  final bool confirmedManually;
  final String? notes;
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
    'id': id, 'local_id': localId, 'unit_id': unitId, 'meter_id': meterId,
    'value': value, 'reading_date': readingDate.toIso8601String(),
    'photo_path': photoPath, 'ocr_raw_text': ocrRawText,
    'ocr_confidence': ocrConfidence, 'requires_review': requiresReview ? 1 : 0,
    'confirmed_manually': confirmedManually ? 1 : 0, 'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory Reading.fromMap(Map<String, Object?> map) => Reading(
    id: map['id'] as int?, localId: map['local_id'] as String,
    unitId: map['unit_id'] as int, meterId: map['meter_id'] as int,
    value: (map['value'] as num).toDouble(),
    readingDate: DateTime.parse(map['reading_date'] as String),
    photoPath: map['photo_path'] as String,
    ocrRawText: map['ocr_raw_text'] as String?,
    ocrConfidence: (map['ocr_confidence'] as num?)?.toDouble(),
    requiresReview: (map['requires_review'] as int? ?? 0) == 1,
    confirmedManually: (map['confirmed_manually'] as int? ?? 0) == 1,
    notes: map['notes'] as String?, createdAt: DateTime.parse(map['created_at'] as String),
  );
}
