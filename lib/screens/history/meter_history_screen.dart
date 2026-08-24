import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../widgets/photo_capture_field.dart';

class MeterHistoryScreen extends StatelessWidget {
  const MeterHistoryScreen({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final history = data.readingsForMeter(meter.id);
    final water = meter.type != meterTypeGas;
    final unit = data.unitById(meter.unitId);
    final tower = unit == null ? null : data.towerById(unit.towerId);
    // Deliberately shorter than AppData.meterLabel (which also includes the
    // condominium name): the user already drilled down through Torres ->
    // Unidades to get here, and the full breadcrumb was truncating
    // unreadably in the AppBar's single-line title on narrow screens.
    final subtitle = [
      if (tower != null) tower.name,
      if (unit != null) 'Unidade ${unit.number}',
      meter.type,
    ].join(' • ');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Histórico de leituras'),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'meter-history-fab',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => _NewReadingDialog(meter: meter),
        ),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Nova leitura'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Icon(water ? Icons.water_drop_outlined : Icons.local_fire_department_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${history.length} leitura(s) registrada(s)'),
                        Text(
                          history.isEmpty
                              ? 'Nenhuma leitura ainda'
                              : 'Última: ${history.first.currentValue.toStringAsFixed(1)} em ${DateFormat('dd/MM/yyyy').format(history.first.createdAt)}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nenhuma leitura registrada',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Registre a primeira leitura deste medidor.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...history.map(
              (reading) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(reading.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Excluir leitura'),
                      content: const Text('Deseja excluir este registro de leitura?'),
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
                  ).then((confirmed) => confirmed ?? false),
                  onDismissed: (_) => context.read<AppData>().removeReading(reading.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.delete_outline),
                  ),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: reading.photoBase64 == null
                          ? CircleAvatar(
                              child: Icon(water ? Icons.water_drop_outlined : Icons.local_fire_department_outlined),
                            )
                          : GestureDetector(
                              onTap: () => showDialog<void>(
                                context: context,
                                builder: (_) => Dialog(
                                  child: Image.memory(base64Decode(reading.photoBase64!)),
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: MemoryImage(base64Decode(reading.photoBase64!)),
                              ),
                            ),
                      title: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(reading.createdAt),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Anterior ${reading.previousValue.toStringAsFixed(1)} • Atual ${reading.currentValue.toStringAsFixed(1)}'),
                      trailing: Text(
                        '+${reading.consumption.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _NewReadingDialog extends StatefulWidget {
  const _NewReadingDialog({required this.meter});

  final Meter meter;

  @override
  State<_NewReadingDialog> createState() => _NewReadingDialogState();
}

class _NewReadingDialogState extends State<_NewReadingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  String? _photoBase64;

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '.')) == null ? 'Número inválido' : null;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final previousValue = data.lastReadingFor(widget.meter.id)?.currentValue ?? 0;

    return AlertDialog(
      title: const Text('Nova leitura'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Leitura anterior'),
                child: Text(previousValue.toStringAsFixed(1)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _current,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Leitura atual *'),
                validator: _numberValidator,
              ),
              const SizedBox(height: 12),
              PhotoCaptureField(
                onChanged: (value) => setState(() => _photoBase64 = value),
                onTextRecognized: (digits) => _current.text = digits,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            final current = double.parse(_current.text.replaceAll(',', '.'));
            if (current < previousValue) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('A leitura atual não pode ser menor que a anterior.')),
              );
              return;
            }
            context.read<AppData>().addReading(
                  meterId: widget.meter.id,
                  currentValue: current,
                  photoBase64: _photoBase64,
                );
            Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
