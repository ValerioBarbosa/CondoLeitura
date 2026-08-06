class MeterReading {
  const MeterReading({
    required this.id,
    required this.meterId,
    required this.unitId,
    required this.value,
    required this.previousValue,
    required this.readingDate,
    this.photoPath,
    this.ocrRawText,
    this.ocrConfidence,
    this.confirmedManually = false,
    this.notes,
  });

  final String id;
  final int meterId;
  final int unitId;
  final double value;
  final double previousValue;
  final DateTime readingDate;
  final String? photoPath;
  final String? ocrRawText;
  final double? ocrConfidence;
  final bool confirmedManually;
  final String? notes;

  double get consumption => value - previousValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'meterId': meterId,
        'unitId': unitId,
        'value': value,
        'previousValue': previousValue,
        'readingDate': readingDate.toIso8601String(),
        'photoPath': photoPath,
        'ocrRawText': ocrRawText,
        'ocrConfidence': ocrConfidence,
        'confirmedManually': confirmedManually,
        'notes': notes,
      };

  factory MeterReading.fromJson(Map<String, dynamic> json) => MeterReading(
        id: json['id'] as String,
        meterId: json['meterId'] as int,
        unitId: json['unitId'] as int,
        value: (json['value'] as num).toDouble(),
        previousValue: (json['previousValue'] as num? ?? 0).toDouble(),
        readingDate: DateTime.parse(json['readingDate'] as String),
        photoPath: json['photoPath'] as String?,
        ocrRawText: json['ocrRawText'] as String?,
        ocrConfidence: (json['ocrConfidence'] as num?)?.toDouble(),
        confirmedManually: json['confirmedManually'] as bool? ?? false,
        notes: json['notes'] as String?,
      );
}
