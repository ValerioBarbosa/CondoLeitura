import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/tower.dart';
import '../../models/unit.dart';
import '../meters/meter_list_screen.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key, required this.tower});

  final Tower tower;

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final units = data
        .unitsFor(widget.tower.id)
        .where((unit) {
          final query = _query.trim().toLowerCase();
          if (query.isEmpty) return true;
          return unit.number.toLowerCase().contains(query) ||
              unit.code.toLowerCase().contains(query) ||
              unit.floor.toLowerCase().contains(query);
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Unidades'),
            Text(
              widget.tower.name,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'units-fab',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => UnitDialog(towerId: widget.tower.id),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova unidade'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar por número, andar ou código',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  _SummaryItem(
                    icon: Icons.home_work_outlined,
                    label: 'Unidades',
                    value: '${data.unitCountForTower(widget.tower.id)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (units.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _query.isEmpty
                          ? 'Nenhuma unidade cadastrada'
                          : 'Nenhuma unidade encontrada',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _query.isEmpty
                          ? 'Cadastre a primeira unidade desta torre.'
                          : 'Altere os termos da pesquisa.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...units.map(
              (unit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(child: Icon(Icons.home_work_outlined)),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Unidade ${unit.number}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          label: Text(unit.isActive ? 'Ativa' : 'Inativa'),
                          avatar: Icon(
                            unit.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        [
                          if (unit.floor.isNotEmpty) 'Andar ${unit.floor}',
                          if (unit.code.isNotEmpty) 'Código ${unit.code}',
                          '${data.meterCountForUnit(unit.id)} hidrômetro(s)',
                        ].join(' • '),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await showDialog<void>(
                            context: context,
                            builder: (_) => UnitDialog(
                              towerId: widget.tower.id,
                              unit: unit,
                            ),
                          );
                        }
                        if (value == 'delete' && context.mounted) {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Excluir unidade'),
                              content: Text('Deseja excluir a unidade “${unit.number}”? Os hidrômetros vinculados também serão excluídos.'),
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
                            context.read<AppData>().removeUnit(unit.id);
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MetersScreen(unit: unit),
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

class UnitDialog extends StatefulWidget {
  const UnitDialog({
    super.key,
    required this.towerId,
    this.unit,
  });

  final String towerId;
  final Unit? unit;

  @override
  State<UnitDialog> createState() => _UnitDialogState();
}

class _UnitDialogState extends State<UnitDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _floor;
  late final TextEditingController _code;
  late final TextEditingController _notes;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;
    _number = TextEditingController(text: unit?.number ?? '');
    _floor = TextEditingController(text: unit?.floor ?? '');
    _code = TextEditingController(text: unit?.code ?? '');
    _notes = TextEditingController(text: unit?.notes ?? '');
    _isActive = unit?.isActive ?? true;
  }

  @override
  void dispose() {
    _number.dispose();
    _floor.dispose();
    _code.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.unit != null;
    return AlertDialog(
      title: Text(editing ? 'Editar unidade' : 'Nova unidade'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _number,
                  autofocus: !editing,
                  decoration: const InputDecoration(
                    labelText: 'Número da unidade *',
                    hintText: 'Ex.: 101',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _floor,
                  decoration: const InputDecoration(labelText: 'Andar'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _code,
                  decoration: const InputDecoration(labelText: 'Código'),
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
                  title: const Text('Unidade ativa'),
                  subtitle: const Text('Unidades inativas permanecem cadastradas.'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
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
        FilledButton.icon(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            final data = context.read<AppData>();
            final unit = widget.unit;
            if (unit == null) {
              data.addUnit(
                towerId: widget.towerId,
                number: _number.text.trim(),
                floor: _floor.text.trim(),
                code: _code.text.trim(),
                notes: _notes.text.trim(),
                isActive: _isActive,
              );
            } else {
              data.updateUnit(
                unit.copyWith(
                  number: _number.text.trim(),
                  floor: _floor.text.trim(),
                  code: _code.text.trim(),
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

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(child: Icon(icon)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label),
          ],
        ),
      ],
    );
  }
}
