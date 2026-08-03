import 'package:flutter/foundation.dart';

import '../models/condominium.dart';
import '../repositories/condominium_repository.dart';

class CondominiumProvider extends ChangeNotifier {
  final CondominiumRepository repository;

  CondominiumProvider(this.repository);

  List<Condominium> _items = [];
  bool _loading = false;
  String? _error;

  List<Condominium> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({
    String? search,
    CondominiumStatus? status,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await repository.findAll(search: search, status: status);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> save(Condominium condominium) async {
    if (condominium.id == null) {
      await repository.create(condominium);
    } else {
      await repository.update(condominium);
    }
    await load();
  }

  Future<void> archive(int id) async {
    await repository.archive(id);
    await load();
  }

  Future<void> restore(int id) async {
    await repository.restore(id);
    await load();
  }

  Future<void> deletePermanently(int id) async {
    await repository.deletePermanently(id);
    await load();
  }

  Future<void> duplicate(int id, String newName) async {
    await repository.duplicate(id, newName);
    await load();
  }

  Future<void> synchronize(int id) async {
    await repository.synchronize(id);
    await load();
  }
}
