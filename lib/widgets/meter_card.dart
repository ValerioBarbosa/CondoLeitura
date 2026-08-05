import 'package:flutter/material.dart';

import '../models/meter.dart';

class MeterCard extends StatelessWidget {
  const MeterCard({
    super.key,
    required this.meter,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Meter meter;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isWater = meter.type == MeterType.water;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(isWater ? Icons.water_drop_outlined : Icons.local_fire_department_outlined),
        ),
        title: Text(meter.label?.isNotEmpty == true ? meter.label! : meter.type.label),
        subtitle: Text(
          'Série: ${meter.serialNumber}\nLeitura inicial: ${meter.initialReading.toStringAsFixed(meter.decimalDigits)}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }
}
