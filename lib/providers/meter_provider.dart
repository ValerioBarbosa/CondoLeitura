import 'package:flutter/foundation.dart';

import '../models/meter.dart';
import '../models/unit.dart';
import '../repositories/meter_repository.dart';

class MeterProvider extends ChangeNotifier {
  MeterProvider({required MeterRepository repository}) : _repository = repository;

  final MeterRepository _repository;
  final List<Meter> _meters = [];
  Unit? _unit;
  bool _loading = false;
  String? _error;
  String _search = '';
  MeterType? _typeFilter;
  bool? _activeFilter;

  List<Meter> get meters => List.unmodifiable(_meters);
  Unit? get unit => _unit;
  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;
  MeterType? get typeFilter => _typeFilter;
  bool? get activeFilter => _activeFilter;
  int get activeCount => _meters.where((item) => item.active).length;

  Future<void> initialize(Unit unit) async {
    _unit = unit;
    await load();
  }

  Future<void> load() async {
    final unitId = _unit?.id;
    if (unitId == null) {
      _error = 'Salve a unidade antes de cadastrar medidores.';
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      final result = await _repository.findByUnit(
        unitId,
        search: _search,
        type: _typeFilter,
        active: _activeFilter,
      );
      _meters
        ..clear()
        ..addAll(result);
      _error = null;
    } catch (error) {
      _error = 'Não foi possível carregar os medidores: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setSearch(String value) async {
    _search = value;
    await load();
  }

  Future<void> setTypeFilter(MeterType? value) async {
    _typeFilter = value;
    await load();
  }

  Future<void> setActiveFilter(bool? value) async {
    _activeFilter = value;
    await load();
  }

  Future<String?> save(Meter meter) async {
    try {
      final duplicated = await _repository.serialNumberExists(
        serialNumber: meter.serialNumber,
        excludingId: meter.id,
      );
      if (duplicated) return 'Já existe um medidor com esse número de série.';
      if (meter.id == null) {
        await _repository.insert(meter);
      } else {
        await _repository.update(meter);
      }
      await load();
      return null;
    } catch (error) {
      return 'Não foi possível salvar o medidor: $error';
    }
  }

  Future<String?> delete(Meter meter) async {
    final id = meter.id;
    if (id == null) return 'Medidor inválido.';
    try {
      await _repository.delete(id);
      await load();
      return null;
    } catch (error) {
      return 'Não foi possível excluir o medidor: $error';
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
