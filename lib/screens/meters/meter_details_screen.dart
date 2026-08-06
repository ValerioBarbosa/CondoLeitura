import 'package:flutter/material.dart';

import '../../models/meter.dart';
import '../../models/app_data.dart';
import 'package:provider/provider.dart';
import '../capture/capture_screen.dart';
import '../history/meter_reading_history_screen.dart';
import '../../models/unit.dart';

class MeterDetailsScreen extends StatelessWidget {
  const MeterDetailsScreen({
    super.key,
    required this.unit,
    required this.meter,
    required this.onEdit,
  });

  final Unit unit;
  final Meter meter;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final installedAt = meter.installedAt;
    final installedLabel = installedAt == null
        ? 'Não informada'
        : '${installedAt.day.toString().padLeft(2, '0')}/'
            '${installedAt.month.toString().padLeft(2, '0')}/'
            '${installedAt.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(meter.label ?? meter.type.label),
        actions: [
          IconButton(
            tooltip: 'Editar medidor',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    child: Icon(
                      meter.type == MeterType.water
                          ? Icons.water_drop_outlined
                          : Icons.local_fire_department_outlined,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    meter.label ?? meter.type.label,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Chip(
                    label: Text(meter.active ? 'Ativo' : 'Inativo'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _DetailTile(
                  icon: Icons.apartment_outlined,
                  label: 'Unidade',
                  value: unit.number,
                ),
                _DetailTile(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Número de série',
                  value: meter.serialNumber,
                ),
                _DetailTile(
                  icon: Icons.factory_outlined,
                  label: 'Fabricante',
                  value: meter.manufacturer ?? 'Não informado',
                ),
                _DetailTile(
                  icon: Icons.precision_manufacturing_outlined,
                  label: 'Modelo',
                  value: meter.model ?? 'Não informado',
                ),
                _DetailTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Instalação',
                  value: installedLabel,
                ),
                _DetailTile(
                  icon: Icons.pin_outlined,
                  label: 'Leitura inicial',
                  value: meter.initialReading.toStringAsFixed(meter.decimalDigits),
                ),
                _DetailTile(
                  icon: Icons.notes_outlined,
                  label: 'Observações',
                  value: meter.notes ?? 'Nenhuma observação',
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: meter.active && meter.id != null && unit.id != null
                ? () async {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CaptureScreen(unit: unit, meter: meter),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Nova leitura'),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Histórico de leituras'),
              subtitle: Text(
                meter.id == null
                    ? 'Salve o medidor antes de registrar leituras.'
                    : '${context.watch<AppData>().readingsForMeter(meter.id!).length} leitura(s) registrada(s)',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: meter.id == null
                  ? null
                  : () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => MeterReadingHistoryScreen(
                            unit: unit,
                            meter: meter,
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(label),
          subtitle: Text(value),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }
}
