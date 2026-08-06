import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meter.dart';
import 'meter_reading.dart';
import 'tower.dart';
import 'unit.dart';

class CondoItem {
  CondoItem(
      {required this.id,
      required this.name,
      required this.city,
      required this.towers,
      required this.units});
  final String id;
  final String name;
  final String city;
  final int towers;
  final int units;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'city': city, 'towers': towers, 'units': units};
  factory CondoItem.fromJson(Map<String, dynamic> json) => CondoItem(
        id: json['id'] as String,
        name: json['name'] as String,
        city: json['city'] as String,
        towers: json['towers'] as int,
        units: json['units'] as int,
      );
}

class MeterReadingItem {
  MeterReadingItem(
      {required this.id,
      required this.condominium,
      required this.unit,
      required this.meterType,
      required this.previousValue,
      required this.currentValue,
      required this.createdAt});
  final String id;
  final String condominium;
  final String unit;
  final String meterType;
  final double previousValue;
  final double currentValue;
  final DateTime createdAt;
  double get consumption => currentValue - previousValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'condominium': condominium,
        'unit': unit,
        'meterType': meterType,
        'previousValue': previousValue,
        'currentValue': currentValue,
        'createdAt': createdAt.toIso8601String(),
      };
  factory MeterReadingItem.fromJson(Map<String, dynamic> json) =>
      MeterReadingItem(
        id: json['id'] as String,
        condominium: json['condominium'] as String,
        unit: json['unit'] as String,
        meterType: json['meterType'] as String,
        previousValue: (json['previousValue'] as num).toDouble(),
        currentValue: (json['currentValue'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class AppData extends ChangeNotifier {
  static const _condosKey = 'mvp_condominiums';
  static const _readingsKey = 'mvp_readings';
  static const _towersKey = 'mvp_towers';
  static const _unitsKey = 'mvp_units';
  static const _metersKey = 'mvp_meters';
  static const _meterReadingsKey = 'mvp_meter_readings_v2';
  final List<CondoItem> _condominiums = [];
  final List<MeterReadingItem> _readings = [];
  final List<Tower> _towers = [];
  final List<Unit> _units = [];
  final List<Meter> _meters = [];
  final List<MeterReading> _meterReadings = [];

  List<CondoItem> get condominiums => List.unmodifiable(_condominiums);
  List<MeterReadingItem> get readings => List.unmodifiable(_readings.reversed);
  List<Tower> get towers => List.unmodifiable(_towers);
  List<Unit> get units => List.unmodifiable(_units);
  List<Meter> get meters => List.unmodifiable(_meters);
  List<MeterReading> get meterReadings =>
      List.unmodifiable(_meterReadings.reversed);

  List<Tower> towersFor(String condominiumId) {
    final result =
        _towers.where((item) => item.condominiumId == condominiumId).toList();
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(result);
  }

  int towerCountFor(String condominiumId) =>
      _towers.where((item) => item.condominiumId == condominiumId).length;

  int unitCountFor(String condominiumId) {
    final towerIds = _towers
        .where((tower) => tower.condominiumId == condominiumId)
        .map((tower) => tower.id)
        .toSet();
    return _units.where((unit) => towerIds.contains(unit.towerId)).length;
  }

  int unitCountForTower(String towerId) =>
      _units.where((unit) => unit.towerId == towerId).length;

  int get totalUnits => _units.length;

  List<Unit> unitsForTower(
    String towerId, {
    String? search,
    bool? active,
  }) {
    final query = search?.trim().toLowerCase() ?? '';
    final result = _units.where((unit) {
      if (unit.towerId != towerId) return false;
      if (active != null && unit.active != active) return false;
      if (query.isEmpty) return true;
      return unit.number.toLowerCase().contains(query) ||
          (unit.notes?.toLowerCase().contains(query) ?? false);
    }).toList();
    result.sort((a, b) => a.number.toLowerCase().compareTo(b.number.toLowerCase()));
    return List.unmodifiable(result);
  }

  Unit? unitById(int id) {
    for (final unit in _units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  bool unitIdentifierExists({
    required String towerId,
    required String identifier,
    int? excludingId,
  }) {
    final normalized = identifier.trim().toLowerCase();
    return _units.any((unit) =>
        unit.towerId == towerId &&
        unit.id != excludingId &&
        unit.number.trim().toLowerCase() == normalized);
  }

  int addUnit(Unit unit) {
    final id = unit.id ?? DateTime.now().microsecondsSinceEpoch;
    _units.add(unit.copyWith(id: id));
    notifyListeners();
    _save();
    return id;
  }

  void updateUnit(Unit updated) {
    final id = updated.id;
    if (id == null) return;
    final index = _units.indexWhere((unit) => unit.id == id);
    if (index < 0) return;
    _units[index] = updated;
    notifyListeners();
    _save();
  }

  void removeUnit(int id) {
    _units.removeWhere((unit) => unit.id == id);
    final removedMeterIds = _meters
        .where((meter) => meter.unitId == id)
        .map((meter) => meter.id)
        .whereType<int>()
        .toSet();
    _meters.removeWhere((meter) => meter.unitId == id);
    _meterReadings.removeWhere(
      (reading) => removedMeterIds.contains(reading.meterId),
    );
    notifyListeners();
    _save();
  }

  List<Meter> metersForUnit(
    int unitId, {
    String? search,
    MeterType? type,
    bool? active,
  }) {
    final query = search?.trim().toLowerCase() ?? '';
    final result = _meters.where((meter) {
      if (meter.unitId != unitId) return false;
      if (type != null && meter.type != type) return false;
      if (active != null && meter.active != active) return false;
      if (query.isEmpty) return true;
      return meter.serialNumber.toLowerCase().contains(query) ||
          (meter.label?.toLowerCase().contains(query) ?? false) ||
          (meter.manufacturer?.toLowerCase().contains(query) ?? false) ||
          (meter.model?.toLowerCase().contains(query) ?? false);
    }).toList();
    result.sort((a, b) => a.serialNumber.toLowerCase().compareTo(b.serialNumber.toLowerCase()));
    return List.unmodifiable(result);
  }

  int meterCountForUnit(int unitId) =>
      _meters.where((meter) => meter.unitId == unitId).length;

  int meterCountFor(String condominiumId) {
    final towerIds = _towers
        .where((tower) => tower.condominiumId == condominiumId)
        .map((tower) => tower.id)
        .toSet();
    final unitIds = _units
        .where((unit) => towerIds.contains(unit.towerId))
        .map((unit) => unit.id)
        .whereType<int>()
        .toSet();
    return _meters.where((meter) => unitIds.contains(meter.unitId)).length;
  }

  bool meterSerialExists(String serialNumber, {int? excludingId}) {
    final normalized = serialNumber.trim().toLowerCase();
    return _meters.any((meter) =>
        meter.id != excludingId &&
        meter.serialNumber.trim().toLowerCase() == normalized);
  }

  int addMeter(Meter meter) {
    final id = meter.id ?? DateTime.now().microsecondsSinceEpoch;
    _meters.add(meter.copyWith(id: id));
    notifyListeners();
    _save();
    return id;
  }

  void updateMeter(Meter updated) {
    final id = updated.id;
    if (id == null) return;
    final index = _meters.indexWhere((meter) => meter.id == id);
    if (index < 0) return;
    _meters[index] = updated;
    notifyListeners();
    _save();
  }

  void removeMeter(int id) {
    _meters.removeWhere((meter) => meter.id == id);
    _meterReadings.removeWhere((reading) => reading.meterId == id);
    notifyListeners();
    _save();
  }

  List<MeterReading> readingsForMeter(int meterId) {
    final result = _meterReadings
        .where((reading) => reading.meterId == meterId)
        .toList()
      ..sort((a, b) => b.readingDate.compareTo(a.readingDate));
    return List.unmodifiable(result);
  }

  MeterReading? latestReadingForMeter(int meterId) {
    final readings = readingsForMeter(meterId);
    return readings.isEmpty ? null : readings.first;
  }

  double previousValueForMeter(Meter meter) {
    final latest = meter.id == null ? null : latestReadingForMeter(meter.id!);
    return latest?.value ?? meter.initialReading;
  }

  int readingCountFor(String condominiumId) {
    final towerIds = _towers
        .where((tower) => tower.condominiumId == condominiumId)
        .map((tower) => tower.id)
        .toSet();
    final unitIds = _units
        .where((unit) => towerIds.contains(unit.towerId))
        .map((unit) => unit.id)
        .whereType<int>()
        .toSet();
    return _meterReadings
        .where((reading) => unitIds.contains(reading.unitId))
        .length;
  }

  void addMeterReading(MeterReading reading) {
    _meterReadings.add(reading);
    notifyListeners();
    _save();
  }

  void removeMeterReading(String id) {
    _meterReadings.removeWhere((reading) => reading.id == id);
    notifyListeners();
    _save();
  }

  double get totalConsumption =>
      _readings.fold(0, (sum, item) => sum + item.consumption);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final condoRaw = prefs.getString(_condosKey);
      final readingRaw = prefs.getString(_readingsKey);
      final towerRaw = prefs.getString(_towersKey);
      final unitRaw = prefs.getString(_unitsKey);
      final meterRaw = prefs.getString(_metersKey);
      final meterReadingsRaw = prefs.getString(_meterReadingsKey);
      if (condoRaw != null) {
        _condominiums.addAll((jsonDecode(condoRaw) as List).map(
            (e) => CondoItem.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (towerRaw != null) {
        _towers.addAll((jsonDecode(towerRaw) as List)
            .map((e) => Tower.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (unitRaw != null) {
        _units.addAll((jsonDecode(unitRaw) as List)
            .map((e) => Unit.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (meterRaw != null) {
        _meters.addAll((jsonDecode(meterRaw) as List)
            .map((e) => Meter.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (meterReadingsRaw != null) {
        _meterReadings.addAll((jsonDecode(meterReadingsRaw) as List).map(
          (e) => MeterReading.fromJson(Map<String, dynamic>.from(e as Map)),
        ));
      }
      if (readingRaw != null) {
        _readings.addAll((jsonDecode(readingRaw) as List).map((e) =>
            MeterReadingItem.fromJson(Map<String, dynamic>.from(e as Map))));
      }
    } catch (_) {
      _condominiums.clear();
      _readings.clear();
      _towers.clear();
      _units.clear();
      _meters.clear();
      _meterReadings.clear();
    }
    if (_condominiums.isEmpty) {
      _condominiums.add(CondoItem(
          id: '1',
          name: 'Condomínio de Demonstração',
          city: 'Porto Alegre',
          towers: 4,
          units: 96));
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _condosKey, jsonEncode(_condominiums.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _readingsKey, jsonEncode(_readings.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _towersKey, jsonEncode(_towers.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _unitsKey, jsonEncode(_units.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _metersKey, jsonEncode(_meters.map((e) => e.toJson()).toList()));
    await prefs.setString(
      _meterReadingsKey,
      jsonEncode(_meterReadings.map((e) => e.toJson()).toList()),
    );
  }

  void addCondominium(
      {required String name,
      required String city,
      required int towers,
      required int units}) {
    _condominiums.add(CondoItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        city: city,
        towers: towers,
        units: units));
    notifyListeners();
    _save();
  }

  void removeCondominium(String id) {
    _condominiums.removeWhere((item) => item.id == id);
    final removedTowerIds = _towers
        .where((item) => item.condominiumId == id)
        .map((item) => item.id)
        .toSet();
    _towers.removeWhere((item) => item.condominiumId == id);
    final removedUnitIds = _units
        .where((item) => removedTowerIds.contains(item.towerId))
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    _units.removeWhere((item) => removedTowerIds.contains(item.towerId));
    final removedMeterIds = _meters
        .where((item) => removedUnitIds.contains(item.unitId))
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    _meters.removeWhere((item) => removedUnitIds.contains(item.unitId));
    _meterReadings.removeWhere(
      (item) => removedMeterIds.contains(item.meterId),
    );
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
    _towers.removeWhere((item) => item.id == id);
    final removedUnitIds = _units
        .where((item) => item.towerId == id)
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    _units.removeWhere((item) => item.towerId == id);
    final removedMeterIds = _meters
        .where((item) => removedUnitIds.contains(item.unitId))
        .map((item) => item.id)
        .whereType<int>()
        .toSet();
    _meters.removeWhere((item) => removedUnitIds.contains(item.unitId));
    _meterReadings.removeWhere(
      (item) => removedMeterIds.contains(item.meterId),
    );
    notifyListeners();
    _save();
  }

  void addReading(
      {required String condominium,
      required String unit,
      required String meterType,
      required double previousValue,
      required double currentValue}) {
    _readings.add(MeterReadingItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      condominium: condominium,
      unit: unit,
      meterType: meterType,
      previousValue: previousValue,
      currentValue: currentValue,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    _save();
  }

  void removeReading(String id) {
    _readings.removeWhere((item) => item.id == id);
    notifyListeners();
    _save();
  }
}
