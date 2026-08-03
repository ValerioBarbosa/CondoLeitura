import 'reading.dart';

class SyncQueue {
  final int? id;
  final String entityType;
  final String entityLocalId;
  final String operation;
  final String payload;
  final SyncStatus status;
  final int attempts;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SyncQueue({
    this.id,
    required this.entityType,
    required this.entityLocalId,
    required this.operation,
    required this.payload,
    this.status = SyncStatus.pending,
    this.attempts = 0,
    this.lastError,
    required this.createdAt,
    this.updatedAt,
  });
}
