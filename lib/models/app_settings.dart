class AppSettings {
  const AppSettings({
    this.confirmReading = true,
    this.registerLocation = false,
    this.autoSync = true,
    this.readerName = '',
  });

  /// Exige uma confirmação extra antes de gravar uma leitura.
  final bool confirmReading;

  /// Tenta capturar o GPS do aparelho junto com a leitura.
  final bool registerLocation;

  /// Reservado para quando houver sincronização com um backend remoto.
  /// Hoje não tem efeito: o app é 100% local.
  final bool autoSync;

  /// Nome do leiturista, usado só para identificar quem registrou cada
  /// leitura no histórico (não é uma conta de usuário nem exige senha).
  final String readerName;

  AppSettings copyWith({
    bool? confirmReading,
    bool? registerLocation,
    bool? autoSync,
    String? readerName,
  }) {
    return AppSettings(
      confirmReading: confirmReading ?? this.confirmReading,
      registerLocation: registerLocation ?? this.registerLocation,
      autoSync: autoSync ?? this.autoSync,
      readerName: readerName ?? this.readerName,
    );
  }

  Map<String, dynamic> toJson() => {
        'confirmReading': confirmReading,
        'registerLocation': registerLocation,
        'autoSync': autoSync,
        'readerName': readerName,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        confirmReading: json['confirmReading'] as bool? ?? true,
        registerLocation: json['registerLocation'] as bool? ?? false,
        autoSync: json['autoSync'] as bool? ?? true,
        readerName: json['readerName'] as String? ?? '',
      );
}
