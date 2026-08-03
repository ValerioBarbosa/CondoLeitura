class Unit {
  final int? id;
  final int towerId;
  final String number;
  final String? floor;
  final String? code;
  final bool active;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Unit({
    this.id,
    required this.towerId,
    required this.number,
    this.floor,
    this.code,
    this.active = true,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tower_id': towerId,
        'number': number,
        'floor': floor,
        'code': code,
        'active': active ? 1 : 0,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory Unit.fromMap(Map<String, dynamic> map) => Unit(
        id: map['id'] as int?,
        towerId: map['tower_id'] as int,
        number: map['number'] as String,
        floor: map['floor'] as String?,
        code: map['code'] as String?,
        active: (map['active'] as int? ?? 1) == 1,
        notes: map['notes'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );
}
