import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_data.dart';
import '../models/no_reading_reason.dart';

Future<void> showNoReadingDialog(BuildContext context, String meterId) {
  return showDialog<void>(
    context: context,
    builder: (_) => NoReadingDialog(meterId: meterId),
  );
}

class NoReadingDialog extends StatefulWidget {
  const NoReadingDialog({super.key, required this.meterId});

  final String meterId;

  @override
  State<NoReadingDialog> createState() => _NoReadingDialogState();
}

class _NoReadingDialogState extends State<NoReadingDialog> {
  String _reason = noReadingReasons.first;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar sem leitura'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: const InputDecoration(labelText: 'Motivo'),
              items: noReadingReasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (value) => setState(() => _reason = value ?? _reason),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Observações (opcional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            context.read<AppData>().addNoReadingRecord(
                  meterId: widget.meterId,
                  reason: _reason,
                  notes: _notes.text.trim(),
                );
            Navigator.pop(context);
          },
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
