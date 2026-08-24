import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/location_service.dart';

/// Mostra uma confirmação extra antes de salvar, quando
/// `settings.confirmReading` está ativo. Devolve `true` quando pode seguir.
Future<bool> confirmReadingIfNeeded(BuildContext context, AppSettings settings) async {
  if (!settings.confirmReading) return true;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirmar leitura'),
      content: const Text('Revise o valor digitado antes de salvar. Deseja confirmar o registro desta leitura?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Voltar e revisar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Captura o GPS quando `settings.registerLocation` está ativo. Nunca
/// impede o salvamento: qualquer falha só faz a leitura seguir sem GPS.
Future<({double? latitude, double? longitude})> captureLocationIfEnabled(AppSettings settings) async {
  if (!settings.registerLocation) return (latitude: null, longitude: null);
  final position = await LocationService.getCurrentPosition();
  return (latitude: position?.latitude, longitude: position?.longitude);
}
