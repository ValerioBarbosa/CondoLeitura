class Unit {
  const Unit({
    required this.id,
    required this.towerId,
    required this.number,
    this.floor = '',
    this.code = '',
    this.notes = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String towerId;
  final String number;
  final String floor;
  final String code;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Unit copyWith({
    String? id,
    String? towerId,
    String? number,
    String? floor,
    String? code,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      towerId: towerId ?? this.towerId,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      code: code ?? this.code,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
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
        'notes': notes,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Unit.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Unit(
      id: json['id'] as String,
      towerId: json['towerId'] as String,
      number: json['number'] as String,
      floor: json['floor'] as String? ?? '',
      code: json['code'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
    );
  }
}
