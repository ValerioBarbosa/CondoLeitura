enum MeterType {
  water,
  gas;

  String get label => switch (this) {
        MeterType.water => 'Água',
        MeterType.gas => 'Gás',
      };

  String get databaseValue => name;

  static MeterType fromDatabase(String value) {
    return MeterType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => MeterType.water,
    );
  }
}

class Meter {
  const Meter({
    this.id,
    required this.unitId,
    required this.type,
    required this.serialNumber,
    this.label,
    this.initialReading = 0,
    this.integerDigits = 5,
    this.decimalDigits = 3,
    this.active = true,
    this.installedAt,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int unitId;
  final MeterType type;
  final String serialNumber;
  final String? label;
  final double initialReading;
  final int integerDigits;
  final int decimalDigits;
  final bool active;
  final DateTime? installedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  int get totalDigits => integerDigits + decimalDigits;

  Meter copyWith({
    int? id,
    int? unitId,
    MeterType? type,
    String? serialNumber,
    String? label,
    double? initialReading,
    int? integerDigits,
    int? decimalDigits,
    bool? active,
    DateTime? installedAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meter(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      type: type ?? this.type,
      serialNumber: serialNumber ?? this.serialNumber,
      label: label ?? this.label,
      initialReading: initialReading ?? this.initialReading,
      integerDigits: integerDigits ?? this.integerDigits,
      decimalDigits: decimalDigits ?? this.decimalDigits,
      active: active ?? this.active,
      installedAt: installedAt ?? this.installedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'unit_id': unitId,
        'type': type.databaseValue,
        'serial_number': serialNumber.trim(),
        'label': _nullIfEmpty(label),
        'initial_reading': initialReading,
        'integer_digits': integerDigits,
        'decimal_digits': decimalDigits,
        'active': active ? 1 : 0,
        'installed_at': installedAt?.toIso8601String(),
        'notes': _nullIfEmpty(notes),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory Meter.fromMap(Map<String, Object?> map) => Meter(
        id: map['id'] as int?,
        unitId: map['unit_id'] as int,
        type: MeterType.fromDatabase(map['type'] as String? ?? 'water'),
        serialNumber: map['serial_number'] as String,
        label: map['label'] as String?,
        initialReading: (map['initial_reading'] as num? ?? 0).toDouble(),
        integerDigits: map['integer_digits'] as int? ?? 5,
        decimalDigits: map['decimal_digits'] as int? ?? 3,
        active: (map['active'] as int? ?? 1) == 1,
        installedAt: map['installed_at'] == null
            ? null
            : DateTime.tryParse(map['installed_at'] as String),
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] == null
            ? null
            : DateTime.tryParse(map['updated_at'] as String),
      );

  static String? _nullIfEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
