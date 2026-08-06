import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../models/unit.dart';

class MeterFormScreen extends StatefulWidget {
  const MeterFormScreen({super.key, required this.unit, this.meter});

  final Unit unit;
  final Meter? meter;

  @override
  State<MeterFormScreen> createState() => _MeterFormScreenState();
}

class _MeterFormScreenState extends State<MeterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serial;
  late final TextEditingController _manufacturer;
  late final TextEditingController _model;
  late final TextEditingController _label;
  late final TextEditingController _initialReading;
  late final TextEditingController _notes;
  late MeterType _type;
  late bool _active;
  DateTime? _installedAt;

  @override
  void initState() {
    super.initState();
    final meter = widget.meter;
    _serial = TextEditingController(text: meter?.serialNumber ?? '');
    _manufacturer = TextEditingController(text: meter?.manufacturer ?? '');
    _model = TextEditingController(text: meter?.model ?? '');
    _label = TextEditingController(text: meter?.label ?? '');
    _initialReading = TextEditingController(
      text: meter == null ? '0' : meter.initialReading.toString(),
    );
    _notes = TextEditingController(text: meter?.notes ?? '');
    _type = meter?.type ?? MeterType.water;
    _active = meter?.active ?? true;
    _installedAt = meter?.installedAt;
  }

  @override
  void dispose() {
    _serial.dispose();
    _manufacturer.dispose();
    _model.dispose();
    _label.dispose();
    _initialReading.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _installedAt ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (value != null) setState(() => _installedAt = value);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final unitId = widget.unit.id;
    if (unitId == null) return;

    final data = context.read<AppData>();
    final current = widget.meter;
    if (data.meterSerialExists(
      _serial.text,
      excludingId: current?.id,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Já existe um medidor com esse número de série.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final meter = Meter(
      id: current?.id,
      unitId: unitId,
      type: _type,
      serialNumber: _serial.text.trim(),
      manufacturer: _optional(_manufacturer.text),
      model: _optional(_model.text),
      label: _optional(_label.text),
      initialReading:
          double.tryParse(_initialReading.text.trim().replaceAll(',', '.')) ?? 0,
      active: _active,
      installedAt: _installedAt,
      notes: _optional(_notes.text),
      createdAt: current?.createdAt ?? now,
      updatedAt: current == null ? null : now,
    );

    if (current == null) {
      data.addMeter(meter);
    } else {
      data.updateMeter(meter);
    }
    Navigator.pop(context, true);
  }

  String? _optional(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _installedAt == null
        ? 'Não informada'
        : '${_installedAt!.day.toString().padLeft(2, '0')}/'
            '${_installedAt!.month.toString().padLeft(2, '0')}/'
            '${_installedAt!.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meter == null ? 'Novo medidor' : 'Editar medidor'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.apartment_outlined),
                      title: Text('Unidade ${widget.unit.number}'),
                      subtitle:
                          const Text('O medidor será vinculado a esta unidade.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MeterType>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Tipo *'),
                    items: MeterType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _type = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _serial,
                    decoration:
                        const InputDecoration(labelText: 'Número de série *'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o número de série.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _manufacturer,
                    decoration:
                        const InputDecoration(labelText: 'Fabricante'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _model,
                    decoration: const InputDecoration(labelText: 'Modelo'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _label,
                    decoration: const InputDecoration(
                      labelText: 'Identificação interna',
                      hintText: 'Ex.: Água cozinha',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _initialReading,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Leitura inicial'),
                    validator: (value) {
                      final parsed = double.tryParse(
                        (value ?? '').trim().replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed < 0) {
                        return 'Informe uma leitura inicial válida.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: const Text('Data de instalação'),
                      subtitle: Text(dateLabel),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          if (_installedAt != null)
                            IconButton(
                              tooltip: 'Limpar data',
                              onPressed: () => setState(() => _installedAt = null),
                              icon: const Icon(Icons.clear),
                            ),
                          IconButton(
                            tooltip: 'Selecionar data',
                            onPressed: _pickDate,
                            icon: const Icon(Icons.edit_calendar_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Observações'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
                    title: const Text('Medidor ativo'),
                    subtitle: const Text(
                      'Medidores inativos permanecem no histórico, mas não entram na rota.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar medidor'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
