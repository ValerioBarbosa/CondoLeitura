class Unit {
  const Unit({
    this.id,
    required this.towerId,
    required this.number,
    this.floor,
    this.code,
    this.readingOrder = 0,
    this.active = true,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String towerId;
  final String number;
  final String? floor;
  final String? code;
  final int readingOrder;
  final bool active;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Unit copyWith({
    int? id,
    String? towerId,
    String? number,
    String? floor,
    String? code,
    int? readingOrder,
    bool? active,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      towerId: towerId ?? this.towerId,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      code: code ?? this.code,
      readingOrder: readingOrder ?? this.readingOrder,
      active: active ?? this.active,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  Map<String, dynamic> toJson() => {
        'id': id,
        'towerId': towerId,
        'number': number,
        'floor': floor,
        'code': code,
        'readingOrder': readingOrder,
        'active': active,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Unit.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Unit(
      id: (json['id'] as num?)?.toInt(),
      towerId: json['towerId'] as String,
      number: json['number'] as String,
      floor: json['floor'] as String?,
      code: json['code'] as String?,
      readingOrder: (json['readingOrder'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tower_id': towerId,
        'number': number,
        'floor': _nullIfEmpty(floor),
        'code': _nullIfEmpty(code),
        'reading_order': readingOrder,
        'active': active ? 1 : 0,
        'notes': _nullIfEmpty(notes),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory Unit.fromMap(Map<String, dynamic> map) => Unit(
        id: map['id'] as int?,
        towerId: map['tower_id'].toString(),
        number: map['number'] as String,
        floor: map['floor'] as String?,
        code: map['code'] as String?,
        readingOrder: map['reading_order'] as int? ?? 0,
        active: (map['active'] as int? ?? 1) == 1,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'] as String)
            : null,
      );

  static String? _nullIfEmpty(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
