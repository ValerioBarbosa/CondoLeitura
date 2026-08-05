import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators/unit_validator.dart';
import '../../models/tower.dart';
import '../../models/unit.dart';
import '../../providers/unit_provider.dart';

class UnitFormScreen extends StatefulWidget {
  const UnitFormScreen({
    super.key,
    required this.tower,
    this.unit,
  });

  final Tower tower;
  final Unit? unit;

  @override
  State<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends State<UnitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _floor;
  late final TextEditingController _code;
  late final TextEditingController _readingOrder;
  late final TextEditingController _notes;
  late bool _active;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;
    _number = TextEditingController(text: unit?.number ?? '');
    _floor = TextEditingController(text: unit?.floor ?? '');
    _code = TextEditingController(text: unit?.code ?? '');
    _readingOrder = TextEditingController(
      text: unit == null || unit.readingOrder == 0
          ? ''
          : unit.readingOrder.toString(),
    );
    _notes = TextEditingController(text: unit?.notes ?? '');
    _active = unit?.active ?? true;
  }

  @override
  void dispose() {
    _number.dispose();
    _floor.dispose();
    _code.dispose();
    _readingOrder.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final current = widget.unit;
    final now = DateTime.now();
    final unit = Unit(
      id: current?.id,
      towerId: widget.tower.id,
      number: _number.text.trim(),
      floor: _optional(_floor.text),
      code: _optional(_code.text),
      readingOrder: int.tryParse(_readingOrder.text.trim()) ?? 0,
      active: _active,
      notes: _optional(_notes.text),
      createdAt: current?.createdAt ?? now,
      updatedAt: current == null ? null : now,
    );
    final error = await context.read<UnitProvider>().save(unit);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context, true);
  }

  String? _optional(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.unit != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar unidade' : 'Nova unidade')),
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
                      leading: const Icon(Icons.domain_outlined),
                      title: Text(widget.tower.name),
                      subtitle: const Text('A unidade será vinculada a esta torre.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _number,
                    autofocus: !editing,
                    validator: UnitValidator.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Número da unidade *',
                      hintText: 'Ex.: 101, 12A ou Loja 03',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _floor,
                    validator: UnitValidator.floor,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Andar',
                      hintText: 'Ex.: 1º',
                      prefixIcon: Icon(Icons.layers_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _code,
                    validator: UnitValidator.code,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Código interno',
                      hintText: 'Opcional',
                      prefixIcon: Icon(Icons.qr_code_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _readingOrder,
                    validator: UnitValidator.readingOrder,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Ordem de leitura',
                      hintText: 'Ex.: 1, 2, 3...',
                      helperText: 'Define a sequência da rota. Zero deixa por número.',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notes,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      hintText: 'Informações úteis sobre acesso ou localização.',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Unidade ativa'),
                    subtitle: const Text('Unidades inativas continuam no histórico.'),
                    value: _active,
                    onChanged: _saving ? null : (value) => setState(() => _active = value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Salvando...' : 'Salvar unidade'),
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
