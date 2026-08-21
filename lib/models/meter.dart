const meterTypeWater = 'Água';
const meterTypeGas = 'Gás';
const meterTypes = [meterTypeWater, meterTypeGas];

class Meter {
  const Meter({
    required this.id,
    required this.unitId,
    required this.type,
    this.serialNumber = '',
    this.notes = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String unitId;
  final String type;
  final String serialNumber;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meter copyWith({
    String? id,
    String? unitId,
    String? type,
    String? serialNumber,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meter(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      type: type ?? this.type,
      serialNumber: serialNumber ?? this.serialNumber,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unitId': unitId,
        'type': type,
        'serialNumber': serialNumber,
        'notes': notes,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Meter.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Meter(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      type: json['type'] as String? ?? meterTypeWater,
      serialNumber: json['serialNumber'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
    );
  }
}
