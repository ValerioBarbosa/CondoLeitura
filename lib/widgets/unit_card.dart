import 'package:flutter/material.dart';

import '../models/unit.dart';

class UnitCard extends StatelessWidget {
  const UnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Unit unit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Text(
            unit.number.isEmpty ? '?' : unit.number.substring(0, 1).toUpperCase(),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                unit.number,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Chip(
              visualDensity: VisualDensity.compact,
              avatar: Icon(
                unit.active ? Icons.check_circle_outline : Icons.pause_circle_outline,
                size: 17,
              ),
              label: Text(unit.active ? 'Ativa' : 'Inativa'),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(unit.notes?.trim().isNotEmpty == true
              ? unit.notes!
              : 'Sem observações'),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined),
                title: Text('Editar'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline),
                title: Text('Excluir'),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
