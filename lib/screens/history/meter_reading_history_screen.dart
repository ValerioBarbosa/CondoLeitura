import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../models/meter_reading.dart';
import '../../models/unit.dart';

class MeterReadingHistoryScreen extends StatelessWidget {
  const MeterReadingHistoryScreen({
    super.key,
    required this.unit,
    required this.meter,
  });

  final Unit unit;
  final Meter meter;

  Future<void> _delete(
    BuildContext context,
    MeterReading reading,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir leitura'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AppData>().removeMeterReading(reading.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meterId = meter.id;
    final readings = meterId == null
        ? const <MeterReading>[]
        : context.watch<AppData>().readingsForMeter(meterId);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de leituras')),
      body: readings.isEmpty
          ? const Center(child: Text('Nenhuma leitura registrada.'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: readings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final reading = readings[index];
                final date = reading.readingDate;
                final dateLabel =
                    '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}/${date.year} '
                    '${date.hour.toString().padLeft(2, '0')}:'
                    '${date.minute.toString().padLeft(2, '0')}';
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.speed_outlined)),
                    title: Text(
                      reading.value.toStringAsFixed(meter.decimalDigits),
                    ),
                    subtitle: Text(
                      '$dateLabel\nConsumo: ${reading.consumption.toStringAsFixed(meter.decimalDigits)}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Excluir leitura',
                      onPressed: () => _delete(context, reading),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
