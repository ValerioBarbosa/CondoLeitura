import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';
import 'meter.dart';
import 'no_reading_reason.dart';
import 'reading.dart';
import 'tower.dart';
import 'unit.dart';

class CondoItem {
  CondoItem({required this.id, required this.name, required this.city, required this.towers, required this.units});
  final String id;
  final String name;
  final String city;
  final int towers;
  final int units;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'city': city, 'towers': towers, 'units': units};
  factory CondoItem.fromJson(Map<String, dynamic> json) => CondoItem(
        id: json['id'] as String,
        name: json['name'] as String,
        city: json['city'] as String,
        towers: json['towers'] as int,
        units: json['units'] as int,
      );
}

class AppData extends ChangeNotifier {
  static const _condosKey = 'mvp_condominiums';
  static const _readingsKey = 'mvp_readings';
  static const _towersKey = 'mvp_towers';
  static const _unitsKey = 'mvp_units';
  static const _metersKey = 'mvp_meters';
  static const _settingsKey = 'mvp_settings';
  static const _noReadingKey = 'mvp_no_reading';
  final List<CondoItem> _condominiums = [];
  final List<Reading> _readings = [];
  final List<Tower> _towers = [];
  final List<Unit> _units = [];
  final List<Meter> _meters = [];
  final List<NoReadingRecord> _noReadingRecords = [];
  AppSettings _settings = const AppSettings();

  List<CondoItem> get condominiums => List.unmodifiable(_condominiums);
  List<Reading> get readings => List.unmodifiable(_readings.reversed);
  List<Tower> get towers => List.unmodifiable(_towers);
  List<Unit> get units => List.unmodifiable(_units);
  List<Meter> get meters => List.unmodifiable(_meters);
  List<NoReadingRecord> get noReadingRecords => List.unmodifiable(_noReadingRecords.reversed);
  AppSettings get settings => _settings;

  List<Tower> towersFor(String condominiumId) {
    final result = _towers.where((item) => item.condominiumId == condominiumId).toList();
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(result);
  }

  int towerCountFor(String condominiumId) =>
      _towers.where((item) => item.condominiumId == condominiumId).length;

  List<Unit> unitsFor(String towerId) {
    final result = _units.where((item) => item.towerId == towerId).toList();
    result.sort((a, b) => a.number.toLowerCase().compareTo(b.number.toLowerCase()));
    return List.unmodifiable(result);
  }

  int unitCountForTower(String towerId) =>
      _units.where((item) => item.towerId == towerId).length;

  int unitCountFor(String condominiumId) {
    final towerIds = _towers
        .where((tower) => tower.condominiumId == condominiumId)
        .map((tower) => tower.id)
        .toSet();
    return _units.where((unit) => towerIds.contains(unit.towerId)).length;
  }

  List<Meter> metersFor(String unitId) {
    final result = _meters.where((item) => item.unitId == unitId).toList();
    result.sort((a, b) => a.type.compareTo(b.type));
    return List.unmodifiable(result);
  }

  int meterCountForUnit(String unitId) =>
      _meters.where((item) => item.unitId == unitId).length;

  int meterCountForCondominium(String condominiumId) {
    final towerIds = _towers
        .where((tower) => tower.condominiumId == condominiumId)
        .map((tower) => tower.id)
        .toSet();
    final unitIds = _units
        .where((unit) => towerIds.contains(unit.towerId))
        .map((unit) => unit.id)
        .toSet();
    return _meters.where((meter) => unitIds.contains(meter.unitId)).length;
  }

  int get totalUnits => _units.length;
  double get totalConsumption => _readings.fold(0, (sum, item) => sum + item.consumption);

  CondoItem? condominiumById(String id) {
    for (final item in _condominiums) {
      if (item.id == id) return item;
    }
    return null;
  }

  Tower? towerById(String id) {
    for (final item in _towers) {
      if (item.id == id) return item;
    }
    return null;
  }

  Unit? unitById(String id) {
    for (final item in _units) {
      if (item.id == id) return item;
    }
    return null;
  }

  Meter? meterById(String id) {
    for (final item in _meters) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Descreve um medidor pela hierarquia completa, ex.: "Condomínio X • Torre A • 101 • Água".
  String meterLabel(String meterId) {
    final meter = meterById(meterId);
    if (meter == null) return 'Medidor removido';
    final unit = unitById(meter.unitId);
    final tower = unit == null ? null : towerById(unit.towerId);
    final condominium = tower == null ? null : condominiumById(tower.condominiumId);
    final parts = [
      if (condominium != null) condominium.name,
      if (tower != null) tower.name,
      if (unit != null) 'Unidade ${unit.number}',
      meter.type,
    ];
    return parts.join(' • ');
  }

  List<Reading> readingsForMeter(String meterId) {
    final result = _readings.where((item) => item.meterId == meterId).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  Reading? lastReadingFor(String meterId) {
    final history = readingsForMeter(meterId);
    return history.isEmpty ? null : history.first;
  }

  List<NoReadingRecord> noReadingRecordsForMeter(String meterId) {
    final result = _noReadingRecords.where((item) => item.meterId == meterId).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final condoRaw = prefs.getString(_condosKey);
      final readingRaw = prefs.getString(_readingsKey);
      final towerRaw = prefs.getString(_towersKey);
      final unitRaw = prefs.getString(_unitsKey);
      final meterRaw = prefs.getString(_metersKey);
      final settingsRaw = prefs.getString(_settingsKey);
      final noReadingRaw = prefs.getString(_noReadingKey);
      if (settingsRaw != null) {
        _settings = AppSettings.fromJson(Map<String, dynamic>.from(jsonDecode(settingsRaw) as Map));
      }
      if (condoRaw != null) {
        _condominiums.addAll((jsonDecode(condoRaw) as List).map((e) => CondoItem.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (towerRaw != null) {
        _towers.addAll((jsonDecode(towerRaw) as List).map((e) => Tower.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (unitRaw != null) {
        _units.addAll((jsonDecode(unitRaw) as List).map((e) => Unit.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (meterRaw != null) {
        _meters.addAll((jsonDecode(meterRaw) as List).map((e) => Meter.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (readingRaw != null) {
        _readings.addAll((jsonDecode(readingRaw) as List).map((e) => Reading.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (noReadingRaw != null) {
        _noReadingRecords.addAll((jsonDecode(noReadingRaw) as List).map((e) => NoReadingRecord.fromJson(Map<String, dynamic>.from(e as Map))));
      }
    } catch (_) {
      _condominiums.clear();
      _readings.clear();
      _towers.clear();
      _units.clear();
      _meters.clear();
      _noReadingRecords.clear();
      _settings = const AppSettings();
    }
    if (_condominiums.isEmpty) {
      _condominiums.add(CondoItem(id: '1', name: 'Condomínio de Demonstração', city: 'Porto Alegre', towers: 4, units: 96));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_condosKey, jsonEncode(_condominiums.map((e) => e.toJson()).toList()));
    await prefs.setString(_readingsKey, jsonEncode(_readings.map((e) => e.toJson()).toList()));
    await prefs.setString(_towersKey, jsonEncode(_towers.map((e) => e.toJson()).toList()));
    await prefs.setString(_unitsKey, jsonEncode(_units.map((e) => e.toJson()).toList()));
    await prefs.setString(_metersKey, jsonEncode(_meters.map((e) => e.toJson()).toList()));
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    await prefs.setString(_noReadingKey, jsonEncode(_noReadingRecords.map((e) => e.toJson()).toList()));
  }

  void updateSettings(AppSettings updated) {
    _settings = updated;
    notifyListeners();
    _save();
  }

  void addCondominium({required String name, required String city, required int towers, required int units}) {
    _condominiums.add(CondoItem(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name, city: city, towers: towers, units: units));
    notifyListeners();
    _save();
  }

  void removeCondominium(String id) {
    final towerIds = _towers.where((tower) => tower.condominiumId == id).map((tower) => tower.id).toSet();
    final unitIds = _units.where((unit) => towerIds.contains(unit.towerId)).map((unit) => unit.id).toSet();
    final meterIds = _meters.where((meter) => unitIds.contains(meter.unitId)).map((meter) => meter.id).toSet();
    _condominiums.removeWhere((item) => item.id == id);
    _towers.removeWhere((item) => item.condominiumId == id);
    _units.removeWhere((item) => towerIds.contains(item.towerId));
    _meters.removeWhere((item) => unitIds.contains(item.unitId));
    _readings.removeWhere((item) => meterIds.contains(item.meterId));
    _noReadingRecords.removeWhere((item) => meterIds.contains(item.meterId));
    notifyListeners();
    _save();
  }


  void addTower({
    required String condominiumId,
    required String name,
    required String code,
    String notes = '',
    bool isActive = true,
  }) {
    _towers.add(Tower(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      condominiumId: condominiumId,
      name: name,
      code: code,
      notes: notes,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    notifyListeners();
    _save();
  }

  void updateTower(Tower updated) {
    final index = _towers.indexWhere((item) => item.id == updated.id);
    if (index < 0) return;
    _towers[index] = updated;
    notifyListeners();
    _save();
  }

  void removeTower(String id) {
    final unitIds = _units.where((unit) => unit.towerId == id).map((unit) => unit.id).toSet();
    final meterIds = _meters.where((meter) => unitIds.contains(meter.unitId)).map((meter) => meter.id).toSet();
    _towers.removeWhere((item) => item.id == id);
    _units.removeWhere((item) => item.towerId == id);
    _meters.removeWhere((item) => unitIds.contains(item.unitId));
    _readings.removeWhere((item) => meterIds.contains(item.meterId));
    _noReadingRecords.removeWhere((item) => meterIds.contains(item.meterId));
    notifyListeners();
    _save();
  }

  void addUnit({
    required String towerId,
    required String number,
    String floor = '',
    String code = '',
    String notes = '',
    bool isActive = true,
  }) {
    _units.add(Unit(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      towerId: towerId,
      number: number,
      floor: floor,
      code: code,
      notes: notes,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    notifyListeners();
    _save();
  }

  void updateUnit(Unit updated) {
    final index = _units.indexWhere((item) => item.id == updated.id);
    if (index < 0) return;
    _units[index] = updated;
    notifyListeners();
    _save();
  }

  void removeUnit(String id) {
    final meterIds = _meters.where((meter) => meter.unitId == id).map((meter) => meter.id).toSet();
    _units.removeWhere((item) => item.id == id);
    _meters.removeWhere((item) => item.unitId == id);
    _readings.removeWhere((item) => meterIds.contains(item.meterId));
    _noReadingRecords.removeWhere((item) => meterIds.contains(item.meterId));
    notifyListeners();
    _save();
  }

  void addMeter({
    required String unitId,
    required String type,
    String serialNumber = '',
    String notes = '',
    bool isActive = true,
  }) {
    _meters.add(Meter(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      unitId: unitId,
      type: type,
      serialNumber: serialNumber,
      notes: notes,
      isActive: isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    notifyListeners();
    _save();
  }

  void updateMeter(Meter updated) {
    final index = _meters.indexWhere((item) => item.id == updated.id);
    if (index < 0) return;
    _meters[index] = updated;
    notifyListeners();
    _save();
  }

  void removeMeter(String id) {
    _meters.removeWhere((item) => item.id == id);
    _readings.removeWhere((item) => item.meterId == id);
    _noReadingRecords.removeWhere((item) => item.meterId == id);
    notifyListeners();
    _save();
  }

  /// Registra uma leitura para [meterId]. A leitura anterior é sempre a última
  /// leitura conhecida do próprio medidor (ou zero, se for a primeira).
  /// [readerName] cai para `settings.readerName` quando não informado.
  Reading addReading({
    required String meterId,
    required double currentValue,
    String? photoBase64,
    double? latitude,
    double? longitude,
    String? readerName,
    String? signatureBase64,
  }) {
    final previousValue = lastReadingFor(meterId)?.currentValue ?? 0;
    final resolvedReader = readerName ?? _settings.readerName;
    final reading = Reading(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      meterId: meterId,
      previousValue: previousValue,
      currentValue: currentValue,
      createdAt: DateTime.now(),
      photoBase64: photoBase64,
      latitude: latitude,
      longitude: longitude,
      readerName: resolvedReader.isEmpty ? null : resolvedReader,
      signatureBase64: signatureBase64,
    );
    _readings.add(reading);
    notifyListeners();
    _save();
    return reading;
  }

  void removeReading(String id) {
    _readings.removeWhere((item) => item.id == id);
    notifyListeners();
    _save();
  }

  NoReadingRecord addNoReadingRecord({
    required String meterId,
    required String reason,
    String notes = '',
  }) {
    final record = NoReadingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      meterId: meterId,
      reason: reason,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _noReadingRecords.add(record);
    notifyListeners();
    _save();
    return record;
  }

  void removeNoReadingRecord(String id) {
    _noReadingRecords.removeWhere((item) => item.id == id);
    notifyListeners();
    _save();
  }
}
