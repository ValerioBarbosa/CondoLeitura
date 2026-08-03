class Tower {
  const Tower({
    required this.id,
    required this.condominiumId,
    required this.name,
    this.code = '',
    this.notes = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String condominiumId;
  final String name;
  final String code;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tower copyWith({
    String? id,
    String? condominiumId,
    String? name,
    String? code,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tower(
      id: id ?? this.id,
      condominiumId: condominiumId ?? this.condominiumId,
      name: name ?? this.name,
      code: code ?? this.code,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'condominiumId': condominiumId,
        'name': name,
        'code': code,
        'notes': notes,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Tower.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Tower(
      id: json['id'] as String,
      condominiumId: json['condominiumId'] as String,
      name: json['name'] as String,
      code: json['code'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
    );
  }
}
