import '../core/network/connectivity_service.dart';
import '../repositories/sync_repository.dart';

class SyncService {
  SyncService({
    required ConnectivityService connectivityService,
    required SyncRepository syncRepository,
  })  : _connectivityService = connectivityService,
        _syncRepository = syncRepository;

  final ConnectivityService _connectivityService;
  final SyncRepository _syncRepository;

  Future<void> synchronizePendingData() async {
    final connected = await _connectivityService.isConnected;

    if (!connected) {
      return;
    }

    await _syncRepository.synchronizePending();
  }
}
