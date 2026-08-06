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
  late final TextEditingController _identifier;
  late final TextEditingController _notes;
  late bool _active;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _identifier = TextEditingController(text: widget.unit?.number ?? '');
    _notes = TextEditingController(text: widget.unit?.notes ?? '');
    _active = widget.unit?.active ?? true;
  }

  @override
  void dispose() {
    _identifier.dispose();
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
      number: _identifier.text.trim(),
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
                      subtitle: const Text('A unidade ficará vinculada a esta torre.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _identifier,
                    autofocus: !editing,
                    validator: UnitValidator.number,
                    decoration: const InputDecoration(
                      labelText: 'Identificador da unidade *',
                      hintText: 'Ex.: 101, A-203, Cobertura 01 ou Loja 02',
                      prefixIcon: Icon(Icons.apartment_outlined),
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
                    subtitle: const Text('Unidades inativas permanecem no histórico.'),
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
