import 'package:condoleitura/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppSettings defaults match the documented behavior', () {
    const settings = AppSettings();

    expect(settings.confirmReading, isTrue);
    expect(settings.registerLocation, isFalse);
    expect(settings.autoSync, isTrue);
    expect(settings.readerName, isEmpty);
  });

  test('AppSettings round-trips through JSON preserving all fields', () {
    const settings = AppSettings(
      confirmReading: false,
      registerLocation: true,
      autoSync: false,
      readerName: 'Valério',
    );

    final decoded = AppSettings.fromJson(settings.toJson());

    expect(decoded.confirmReading, settings.confirmReading);
    expect(decoded.registerLocation, settings.registerLocation);
    expect(decoded.autoSync, settings.autoSync);
    expect(decoded.readerName, settings.readerName);
  });

  test('AppSettings.fromJson falls back to defaults for missing fields', () {
    final decoded = AppSettings.fromJson(const {});

    expect(decoded.confirmReading, isTrue);
    expect(decoded.registerLocation, isFalse);
    expect(decoded.autoSync, isTrue);
    expect(decoded.readerName, isEmpty);
  });

  test('copyWith changes only the given fields', () {
    const settings = AppSettings();

    final updated = settings.copyWith(registerLocation: true);

    expect(updated.registerLocation, isTrue);
    expect(updated.confirmReading, settings.confirmReading);
    expect(updated.autoSync, settings.autoSync);
    expect(updated.readerName, settings.readerName);
  });
}
