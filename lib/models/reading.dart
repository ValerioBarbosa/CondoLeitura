class Reading {
  const Reading({
    required this.id,
    required this.meterId,
    required this.previousValue,
    required this.currentValue,
    required this.createdAt,
  });

  final String id;
  final String meterId;
  final double previousValue;
  final double currentValue;
  final DateTime createdAt;

  double get consumption => currentValue - previousValue;

  Reading copyWith({
    String? id,
    String? meterId,
    double? previousValue,
    double? currentValue,
    DateTime? createdAt,
  }) {
    return Reading(
      id: id ?? this.id,
      meterId: meterId ?? this.meterId,
      previousValue: previousValue ?? this.previousValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meterId': meterId,
        'previousValue': previousValue,
        'currentValue': currentValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reading.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Reading(
      id: json['id'] as String,
      meterId: json['meterId'] as String,
      previousValue: (json['previousValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
    );
  }
}
