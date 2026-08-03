import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';

class SyncProvider extends ChangeNotifier {
  SyncProvider(this._syncService);

  final SyncService _syncService;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<void> synchronize() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _syncService.synchronizePendingData();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
