import 'package:geolocator/geolocator.dart';

/// Captura a localização atual do aparelho, se o usuário permitir.
///
/// Nunca lança: qualquer falha (serviço desligado, permissão negada, timeout)
/// só faz a leitura seguir sem GPS, nunca impede o registro — GPS é sempre
/// um extra, nunca uma condição para concluir uma leitura.
class LocationService {
  const LocationService._();

  static Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
