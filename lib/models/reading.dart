class Reading {
  const Reading({
    required this.id,
    required this.meterId,
    required this.previousValue,
    required this.currentValue,
    required this.createdAt,
    this.photoBase64,
    this.latitude,
    this.longitude,
    this.readerName,
    this.signatureBase64,
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

  /// GPS do aparelho no momento da leitura, se o usuário permitiu.
  final double? latitude;
  final double? longitude;

  /// Nome de quem registrou a leitura, para auditoria (não é uma conta
  /// de usuário autenticada, só uma identificação informada localmente).
  final String? readerName;

  /// Assinatura de confirmação (ex.: do morador ou síndico), em base64,
  /// pelo mesmo motivo de guardar a foto como bytes em vez de caminho.
  final String? signatureBase64;

  double get consumption => currentValue - previousValue;
  bool get hasLocation => latitude != null && longitude != null;

  Reading copyWith({
    String? id,
    String? meterId,
    double? previousValue,
    double? currentValue,
    DateTime? createdAt,
    String? photoBase64,
    double? latitude,
    double? longitude,
    String? readerName,
    String? signatureBase64,
  }) {
    return Reading(
      id: id ?? this.id,
      meterId: meterId ?? this.meterId,
      previousValue: previousValue ?? this.previousValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      photoBase64: photoBase64 ?? this.photoBase64,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      readerName: readerName ?? this.readerName,
      signatureBase64: signatureBase64 ?? this.signatureBase64,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'meterId': meterId,
        'previousValue': previousValue,
        'currentValue': currentValue,
        'createdAt': createdAt.toIso8601String(),
        'photoBase64': photoBase64,
        'latitude': latitude,
        'longitude': longitude,
        'readerName': readerName,
        'signatureBase64': signatureBase64,
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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      readerName: json['readerName'] as String?,
      signatureBase64: json['signatureBase64'] as String?,
    );
  }
}
