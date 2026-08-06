class OcrResult {
  const OcrResult({
    required this.rawText,
    required this.value,
    required this.confidence,
    required this.requiresReview,
  });

  final String rawText;
  final double? value;
  final double confidence;
  final bool requiresReview;
}
