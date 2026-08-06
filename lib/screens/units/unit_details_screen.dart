import 'package:flutter/material.dart';

import '../../models/tower.dart';
import '../../models/unit.dart';
import '../meters/meter_list_screen.dart';

class UnitDetailsScreen extends StatelessWidget {
  const UnitDetailsScreen({
    super.key,
    required this.tower,
    required this.unit,
    required this.onEdit,
  });

  final Tower tower;
  final Unit unit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unidade ${unit.number}'),
        actions: [
          IconButton(
            tooltip: 'Editar unidade',
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
                    child: Text(
                      unit.number.isEmpty ? '?' : unit.number.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(unit.number, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Chip(
                    avatar: Icon(unit.active
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline),
                    label: Text(unit.active ? 'Ativa' : 'Inativa'),
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
                  icon: Icons.domain_outlined,
                  label: 'Torre ou bloco',
                  value: tower.name,
                ),
                _DetailTile(
                  icon: Icons.notes_outlined,
                  label: 'Observações',
                  value: unit.notes ?? 'Nenhuma observação',
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: const Text('Medidores de água e gás'),
              subtitle: const Text('Cadastrar, consultar e gerenciar medidores.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: unit.id == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MeterListScreen(unit: unit),
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
