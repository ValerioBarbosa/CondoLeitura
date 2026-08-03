import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tower.dart';

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
  final List<CondoItem> _condominiums = [];
  final List<MeterReadingItem> _readings = [];
  final List<Tower> _towers = [];

  List<CondoItem> get condominiums => List.unmodifiable(_condominiums);
  List<MeterReadingItem> get readings => List.unmodifiable(_readings.reversed);
  List<Tower> get towers => List.unmodifiable(_towers);

  List<Tower> towersFor(String condominiumId) {
    final result =
        _towers.where((item) => item.condominiumId == condominiumId).toList();
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(result);
  }

  int towerCountFor(String condominiumId) =>
      _towers.where((item) => item.condominiumId == condominiumId).length;

  int unitCountFor(String condominiumId) {
    for (final condominium in _condominiums) {
      if (condominium.id == condominiumId) return condominium.units;
    }
    return 0;
  }

  int get totalUnits => _condominiums.fold(0, (sum, item) => sum + item.units);
  double get totalConsumption =>
      _readings.fold(0, (sum, item) => sum + item.consumption);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final condoRaw = prefs.getString(_condosKey);
      final readingRaw = prefs.getString(_readingsKey);
      final towerRaw = prefs.getString(_towersKey);
      if (condoRaw != null) {
        _condominiums.addAll((jsonDecode(condoRaw) as List).map(
            (e) => CondoItem.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (towerRaw != null) {
        _towers.addAll((jsonDecode(towerRaw) as List)
            .map((e) => Tower.fromJson(Map<String, dynamic>.from(e as Map))));
      }
      if (readingRaw != null) {
        _readings.addAll((jsonDecode(readingRaw) as List).map((e) =>
            MeterReadingItem.fromJson(Map<String, dynamic>.from(e as Map))));
      }
    } catch (_) {
      _condominiums.clear();
      _readings.clear();
      _towers.clear();
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
    _towers.removeWhere((item) => item.condominiumId == id);
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
