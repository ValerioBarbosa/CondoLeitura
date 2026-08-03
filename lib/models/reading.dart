enum SyncStatus { pending, syncing, synced, failed }

class Reading {
  final int? id;
  final String localId;
  final int meterId;
  final double value;
  final DateTime readingDate;
  final double? ocrConfidence;
  final bool requiresReview;
  final SyncStatus syncStatus;
  final DateTime? syncedAt;
  final String? syncError;

  const Reading({
    this.id,
    required this.localId,
    required this.meterId,
    required this.value,
    required this.readingDate,
    this.ocrConfidence,
    this.requiresReview = false,
    this.syncStatus = SyncStatus.pending,
    this.syncedAt,
    this.syncError,
  });
}
