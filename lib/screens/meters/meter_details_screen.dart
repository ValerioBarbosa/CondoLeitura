import 'package:flutter/material.dart';

import '../../models/meter.dart';
import '../../models/unit.dart';
import '../capture/capture_reading_screen.dart';

class MeterDetailsScreen extends StatelessWidget {
  const MeterDetailsScreen({super.key, required this.unit, required this.meter, required this.onEdit});

  final Unit unit;
  final Meter meter;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meter.label ?? meter.type.label),
        actions: [IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(child: ListTile(
            leading: CircleAvatar(child: Icon(meter.type == MeterType.water ? Icons.water_drop_outlined : Icons.local_fire_department_outlined)),
            title: Text(meter.type.label),
            subtitle: Text(meter.active ? 'Ativo' : 'Inativo'),
          )),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: meter.active ? () async { final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => CaptureReadingScreen(unit: unit, meter: meter))); if (saved == true && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leitura salva com sucesso.'))); } : null,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Capturar nova leitura'),
          ),
          const SizedBox(height: 16),
          Card(child: Column(children: [
            _Detail(label: 'Unidade', value: unit.number),
            _Detail(label: 'Número de série', value: meter.serialNumber),
            _Detail(label: 'Leitura inicial', value: meter.initialReading.toStringAsFixed(meter.decimalDigits)),
            _Detail(label: 'Configuração do visor', value: '${meter.integerDigits} inteiros + ${meter.decimalDigits} decimais'),
            _Detail(label: 'Data de instalação', value: meter.installedAt == null ? 'Não informada' : '${meter.installedAt!.day.toString().padLeft(2, '0')}/${meter.installedAt!.month.toString().padLeft(2, '0')}/${meter.installedAt!.year}'),
            _Detail(label: 'Observações', value: meter.notes ?? 'Nenhuma observação', last: true),
          ])),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value, this.last = false});
  final String label;
  final String value;
  final bool last;
  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(title: Text(label), subtitle: Text(value)),
    if (!last) const Divider(height: 1),
  ]);
}
