import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../models/unit.dart';

class MetersScreen extends StatefulWidget {
  const MetersScreen({super.key, required this.unit});

  final Unit unit;

  @override
  State<MetersScreen> createState() => _MetersScreenState();
}

class _MetersScreenState extends State<MetersScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final meters = data.metersFor(widget.unit.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hidrômetros'),
            Text(
              'Unidade ${widget.unit.number}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'meters-fab',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => MeterDialog(unitId: widget.unit.id),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo medidor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (meters.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.water_drop_outlined,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum medidor cadastrado',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cadastre o hidrômetro de água ou o medidor de gás desta unidade.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...meters.map(
              (meter) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      child: Icon(
                        meter.type == meterTypeGas
                            ? Icons.local_fire_department_outlined
                            : Icons.water_drop_outlined,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            meter.type,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          label: Text(meter.isActive ? 'Ativo' : 'Inativo'),
                          avatar: Icon(
                            meter.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        meter.serialNumber.isEmpty
                            ? 'Sem número de série'
                            : 'Série ${meter.serialNumber}',
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await showDialog<void>(
                            context: context,
                            builder: (_) => MeterDialog(
                              unitId: widget.unit.id,
                              meter: meter,
                            ),
                          );
                        }
                        if (value == 'delete' && context.mounted) {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Excluir medidor'),
                              content: Text('Deseja excluir o medidor de ${meter.type.toLowerCase()}?'),
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
                            context.read<AppData>().removeMeter(meter.id);
                          }
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Editar'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Excluir'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => MeterDialog(
                        unitId: widget.unit.id,
                        meter: meter,
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

class MeterDialog extends StatefulWidget {
  const MeterDialog({
    super.key,
    required this.unitId,
    this.meter,
  });

  final String unitId;
  final Meter? meter;

  @override
  State<MeterDialog> createState() => _MeterDialogState();
}

class _MeterDialogState extends State<MeterDialog> {
  late final TextEditingController _serialNumber;
  late final TextEditingController _notes;
  late String _type;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final meter = widget.meter;
    _serialNumber = TextEditingController(text: meter?.serialNumber ?? '');
    _notes = TextEditingController(text: meter?.notes ?? '');
    _type = meter?.type ?? meterTypeWater;
    _isActive = meter?.isActive ?? true;
  }

  @override
  void dispose() {
    _serialNumber.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.meter != null;
    return AlertDialog(
      title: Text(editing ? 'Editar medidor' : 'Novo medidor'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: meterTypeWater,
                    icon: Icon(Icons.water_drop_outlined),
                    label: Text('Água'),
                  ),
                  ButtonSegment(
                    value: meterTypeGas,
                    icon: Icon(Icons.local_fire_department_outlined),
                    label: Text('Gás'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) => setState(() => _type = value.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serialNumber,
                decoration: const InputDecoration(labelText: 'Número de série'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observações'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Medidor ativo'),
                subtitle: const Text('Medidores inativos não entram na rota de leitura.'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
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
        FilledButton.icon(
          onPressed: () {
            final data = context.read<AppData>();
            final meter = widget.meter;
            if (meter == null) {
              data.addMeter(
                unitId: widget.unitId,
                type: _type,
                serialNumber: _serialNumber.text.trim(),
                notes: _notes.text.trim(),
                isActive: _isActive,
              );
            } else {
              data.updateMeter(
                meter.copyWith(
                  type: _type,
                  serialNumber: _serialNumber.text.trim(),
                  notes: _notes.text.trim(),
                  isActive: _isActive,
                  updatedAt: DateTime.now(),
                ),
              );
            }
            Navigator.pop(context);
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Salvar'),
        ),
      ],
    );
  }
}
