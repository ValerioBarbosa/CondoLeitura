import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../models/no_reading_reason.dart';
import '../../models/reading.dart';
import '../../widgets/no_reading_dialog.dart';
import '../../widgets/photo_capture_field.dart';
import '../../widgets/reading_save_helpers.dart';
import '../../widgets/signature_pad.dart';

DateTime _timelineDate(Object item) =>
    item is Reading ? item.createdAt : (item as NoReadingRecord).createdAt;

class MeterHistoryScreen extends StatelessWidget {
  const MeterHistoryScreen({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final history = data.readingsForMeter(meter.id);
    final noReadingRecords = data.noReadingRecordsForMeter(meter.id);
    final timeline = <Object>[...history, ...noReadingRecords]
      ..sort((a, b) => _timelineDate(b).compareTo(_timelineDate(a)));
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
        actions: [
          IconButton(
            tooltip: 'Registrar sem leitura',
            onPressed: () => showNoReadingDialog(context, meter.id),
            icon: const Icon(Icons.event_busy_outlined),
          ),
        ],
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
          if (timeline.isEmpty)
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
            ...timeline.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: item is Reading
                    ? _ReadingHistoryTile(reading: item, water: water)
                    : _NoReadingHistoryTile(record: item as NoReadingRecord),
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
  String? _signatureBase64;
  bool _saving = false;

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
          child: SingleChildScrollView(
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
                const SizedBox(height: 12),
                SignaturePad(onChanged: (value) => _signatureBase64 = value),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final current = double.parse(_current.text.replaceAll(',', '.'));
                  if (current < previousValue) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('A leitura atual não pode ser menor que a anterior.')),
                    );
                    return;
                  }
                  final data = context.read<AppData>();
                  if (!await confirmReadingIfNeeded(context, data.settings)) return;
                  if (!context.mounted) return;

                  setState(() => _saving = true);
                  final location = await captureLocationIfEnabled(data.settings);
                  data.addReading(
                    meterId: widget.meter.id,
                    currentValue: current,
                    photoBase64: _photoBase64,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    signatureBase64: _signatureBase64,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

class _ReadingHistoryTile extends StatelessWidget {
  const _ReadingHistoryTile({required this.reading, required this.water});

  final Reading reading;
  final bool water;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Anterior ${reading.previousValue.toStringAsFixed(1)} • Atual ${reading.currentValue.toStringAsFixed(1)}'),
              if (reading.hasLocation || reading.readerName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 12,
                    children: [
                      if (reading.hasLocation)
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined, size: 14),
                            SizedBox(width: 2),
                            Text('GPS registrado', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      if (reading.readerName != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline, size: 14),
                            const SizedBox(width: 2),
                            Text(reading.readerName!, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: Text(
            '+${reading.consumption.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _NoReadingHistoryTile extends StatelessWidget {
  const _NoReadingHistoryTile({required this.record});

  final NoReadingRecord record;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Excluir registro'),
          content: const Text('Deseja excluir este registro de "sem leitura"?'),
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
      onDismissed: (_) => context.read<AppData>().removeNoReadingRecord(record.id),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: const CircleAvatar(child: Icon(Icons.event_busy_outlined)),
          title: Text(
            DateFormat('dd/MM/yyyy HH:mm').format(record.createdAt),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            record.notes.isEmpty ? 'Sem leitura • ${record.reason}' : 'Sem leitura • ${record.reason} • ${record.notes}',
          ),
        ),
      ),
    );
  }
}
