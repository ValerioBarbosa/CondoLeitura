abstract class SyncRepository {
  Future<int> countPending();

  Future<void> synchronizePending();

  Future<void> retryFailed();

  Future<void> synchronizeCondominium(int condominiumId);
}
