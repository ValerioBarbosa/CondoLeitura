/// Extrai o número do medidor a partir do texto bruto reconhecido pelo OCR.
///
/// Puro Dart, sem dependência de plataforma: testável em qualquer ambiente.
/// Estratégia simples e honesta sobre suas limitações: hidrômetros mostram o
/// valor como a sequência de dígitos mais longa no visor; quando o OCR
/// reconhece texto adicional (marca, unidade "m³" etc.), a maior sequência de
/// dígitos tende a ser o valor da leitura. Sempre exige revisão manual antes
/// de salvar — nunca é usado para preencher e enviar sozinho.
String? extractMeterDigits(String recognizedText) {
  final matches = RegExp(r'\d+').allMatches(recognizedText).map((m) => m.group(0)!).toList();
  if (matches.isEmpty) return null;
  matches.sort((a, b) => b.length.compareTo(a.length));
  return matches.first;
}
