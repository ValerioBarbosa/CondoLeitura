import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tower.dart';
import '../models/unit.dart';
import '../repositories/unit_repository.dart';

class UnitProvider extends ChangeNotifier {
  UnitProvider({required UnitRepository repository}) : _repository = repository;

  final UnitRepository _repository;
  final List<Unit> _units = [];

  bool _loading = false;
  String? _error;
  String _search = '';
  bool? _activeFilter;
  Tower? _tower;

  List<Unit> get units => List.unmodifiable(_units);
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;
  bool? get activeFilter => _activeFilter;
  Tower? get tower => _tower;
  int get activeCount => _units.where((item) => item.active).length;

  Future<void> initialize(Tower tower) async {
    _tower = tower;
    await _repository.ensureTower(tower);
    await load();
  }

  Future<void> load() async {
    final tower = _tower;
    if (tower == null) return;
    _setLoading(true);
    try {
      final result = await _repository.findByTower(
        tower.id,
        search: _search,
        active: _activeFilter,
      );
      _units
        ..clear()
        ..addAll(result);
      _error = null;
    } catch (error) {
      _error = 'Não foi possível carregar as unidades: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setSearch(String value) async {
    _search = value;
    await load();
  }

  Future<void> setActiveFilter(bool? value) async {
    _activeFilter = value;
    await load();
  }

  Future<String?> save(Unit unit) async {
    final tower = _tower;
    if (tower == null) return 'Torre não definida.';
    try {
      final duplicated = await _repository.numberExists(
        towerId: tower.id,
        number: unit.number,
        excludingId: unit.id,
      );
      if (duplicated) {
        return 'Já existe uma unidade com esse número nesta torre.';
      }

      if (unit.id == null) {
        await _repository.insert(unit);
      } else {
        await _repository.update(unit);
      }
      await load();
      return null;
    } on DatabaseException catch (error) {
      return 'Não foi possível salvar a unidade: ${error.toString()}';
    } catch (error) {
      return 'Não foi possível salvar a unidade: $error';
    }
  }

  Future<String?> delete(Unit unit) async {
    final id = unit.id;
    if (id == null) return 'Unidade inválida.';
    try {
      await _repository.delete(id);
      await load();
      return null;
    } catch (error) {
      return 'Não foi possível excluir a unidade: $error';
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
