class UnitValidator {
  static String? number(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return 'Informe o número da unidade.';
    if (normalized.length > 20) return 'Use no máximo 20 caracteres.';
    return null;
  }

  static String? floor(String? value) {
    if ((value?.trim().length ?? 0) > 20) {
      return 'Use no máximo 20 caracteres.';
    }
    return null;
  }

  static String? code(String? value) {
    if ((value?.trim().length ?? 0) > 40) {
      return 'Use no máximo 40 caracteres.';
    }
    return null;
  }

  static String? readingOrder(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return null;
    final parsed = int.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return 'Informe zero ou um número inteiro positivo.';
    }
    return null;
  }
}
