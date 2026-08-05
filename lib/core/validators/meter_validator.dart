class MeterValidator {
  static String? serialNumber(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return 'Informe o número de série.';
    if (normalized.length > 60) return 'Use no máximo 60 caracteres.';
    return null;
  }

  static String? label(String? value) {
    if ((value?.trim().length ?? 0) > 60) {
      return 'Use no máximo 60 caracteres.';
    }
    return null;
  }

  static String? initialReading(String? value) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    if (normalized.isEmpty) return 'Informe a leitura inicial.';
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 0) {
      return 'Informe um número igual ou maior que zero.';
    }
    return null;
  }

  static String? integerDigits(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 1 || parsed > 10) {
      return 'Informe de 1 a 10 dígitos.';
    }
    return null;
  }

  static String? decimalDigits(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0 || parsed > 5) {
      return 'Informe de 0 a 5 dígitos.';
    }
    return null;
  }

  static String? notes(String? value) {
    if ((value?.trim().length ?? 0) > 500) {
      return 'Use no máximo 500 caracteres.';
    }
    return null;
  }
}
