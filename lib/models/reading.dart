class Reading {
  const Reading({
    required this.id,
    required this.meterId,
    required this.previousValue,
    required this.currentValue,
    required this.createdAt,
    this.photoBase64,
  });

  final String id;
  final String meterId;
  final double previousValue;
  final double currentValue;
  final DateTime createdAt;

  /// Foto do medidor no momento da leitura, codificada em base64.
  /// Guardada como bytes (em vez de um caminho de arquivo) porque no Web
  /// não existe um caminho de arquivo persistente entre sessões.
  final String? photoBase64;

  double get consumption => currentValue - previousValue;

  Reading copyWith({
    String? id,
    String? meterId,
    double? previousValue,
    double? currentValue,
    DateTime? createdAt,
    String? photoBase64,
  }) {
    return Reading(
      id: id ?? this.id,
      meterId: meterId ?? this.meterId,
      previousValue: previousValue ?? this.previousValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meterId': meterId,
        'previousValue': previousValue,
        'currentValue': currentValue,
        'createdAt': createdAt.toIso8601String(),
        'photoBase64': photoBase64,
      };

  factory Reading.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return Reading(
      id: json['id'] as String,
      meterId: json['meterId'] as String,
      previousValue: (json['previousValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      photoBase64: json['photoBase64'] as String?,
    );
  }
}
