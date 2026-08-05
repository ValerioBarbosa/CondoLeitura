import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators/meter_validator.dart';
import '../../models/meter.dart';
import '../../models/unit.dart';
import '../../providers/meter_provider.dart';

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
  late final TextEditingController _label;
  late final TextEditingController _initialReading;
  late final TextEditingController _integerDigits;
  late final TextEditingController _decimalDigits;
  late final TextEditingController _notes;
  late MeterType _type;
  late bool _active;
  DateTime? _installedAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final meter = widget.meter;
    _serial = TextEditingController(text: meter?.serialNumber ?? '');
    _label = TextEditingController(text: meter?.label ?? '');
    _initialReading = TextEditingController(
      text: meter == null ? '0' : meter.initialReading.toString(),
    );
    _integerDigits = TextEditingController(text: '${meter?.integerDigits ?? 5}');
    _decimalDigits = TextEditingController(text: '${meter?.decimalDigits ?? 3}');
    _notes = TextEditingController(text: meter?.notes ?? '');
    _type = meter?.type ?? MeterType.water;
    _active = meter?.active ?? true;
    _installedAt = meter?.installedAt;
  }

  @override
  void dispose() {
    _serial.dispose();
    _label.dispose();
    _initialReading.dispose();
    _integerDigits.dispose();
    _decimalDigits.dispose();
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final unitId = widget.unit.id;
    if (unitId == null) return;
    setState(() => _saving = true);
    final current = widget.meter;
    final now = DateTime.now();
    final meter = Meter(
      id: current?.id,
      unitId: unitId,
      type: _type,
      serialNumber: _serial.text.trim(),
      label: _optional(_label.text),
      initialReading: double.parse(_initialReading.text.trim().replaceAll(',', '.')),
      integerDigits: int.parse(_integerDigits.text.trim()),
      decimalDigits: int.parse(_decimalDigits.text.trim()),
      active: _active,
      installedAt: _installedAt,
      notes: _optional(_notes.text),
      createdAt: current?.createdAt ?? now,
      updatedAt: current == null ? null : now,
    );
    final error = await context.read<MeterProvider>().save(meter);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context, true);
  }

  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.meter == null ? 'Novo medidor' : 'Editar medidor')),
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
                      subtitle: const Text('O medidor será vinculado a esta unidade.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<MeterType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Tipo *', prefixIcon: Icon(Icons.speed_outlined)),
                    items: MeterType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.label))).toList(),
                    onChanged: _saving ? null : (value) => setState(() => _type = value ?? MeterType.water),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _serial,
                    validator: MeterValidator.serialNumber,
                    decoration: const InputDecoration(labelText: 'Número de série *', prefixIcon: Icon(Icons.numbers)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _label,
                    validator: MeterValidator.label,
                    decoration: const InputDecoration(labelText: 'Identificação', hintText: 'Ex.: Cozinha ou medidor principal', prefixIcon: Icon(Icons.label_outline)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _initialReading,
                    validator: MeterValidator.initialReading,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Leitura inicial *', prefixIcon: Icon(Icons.pin_outlined)),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _integerDigits, validator: MeterValidator.integerDigits, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dígitos inteiros'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _decimalDigits, validator: MeterValidator.decimalDigits, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dígitos decimais'))),
                  ]),
                  const SizedBox(height: 14),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Data de instalação'),
                      subtitle: Text(_installedAt == null ? 'Não informada' : '${_installedAt!.day.toString().padLeft(2, '0')}/${_installedAt!.month.toString().padLeft(2, '0')}/${_installedAt!.year}'),
                      trailing: Wrap(children: [
                        if (_installedAt != null) IconButton(onPressed: () => setState(() => _installedAt = null), icon: const Icon(Icons.clear)),
                        IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_month_outlined)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notes,
                    validator: MeterValidator.notes,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Observações', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Medidor ativo'),
                    subtitle: const Text('Medidores inativos permanecem no histórico.'),
                    value: _active,
                    onChanged: _saving ? null : (value) => setState(() => _active = value),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Salvando...' : 'Salvar medidor'),
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
