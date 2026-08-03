import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/tower.dart';

class TowersScreen extends StatefulWidget {
  const TowersScreen({super.key, required this.condominium});

  final CondoItem condominium;

  @override
  State<TowersScreen> createState() => _TowersScreenState();
}

class _TowersScreenState extends State<TowersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final towers = data
        .towersFor(widget.condominium.id)
        .where((tower) {
          final query = _query.trim().toLowerCase();
          if (query.isEmpty) return true;
          return tower.name.toLowerCase().contains(query) ||
              tower.code.toLowerCase().contains(query);
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Torres e blocos'),
            Text(
              widget.condominium.name,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => TowerDialog(condominiumId: widget.condominium.id),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova torre'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar por nome ou código',
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
                    icon: Icons.domain_outlined,
                    label: 'Torres',
                    value: '${data.towerCountFor(widget.condominium.id)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (towers.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.domain_add_outlined,
                      size: 52,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _query.isEmpty
                          ? 'Nenhuma torre cadastrada'
                          : 'Nenhuma torre encontrada',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _query.isEmpty
                          ? 'Cadastre a primeira torre ou bloco deste condomínio.'
                          : 'Altere os termos da pesquisa.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...towers.map(
              (tower) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      child: Text(
                        tower.code.trim().isEmpty
                            ? tower.name.substring(0, 1).toUpperCase()
                            : tower.code.substring(0, 1).toUpperCase(),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tower.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          label: Text(tower.isActive ? 'Ativa' : 'Inativa'),
                          avatar: Icon(
                            tower.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        tower.code.isEmpty
                            ? 'Sem código'
                            : 'Código ${tower.code}',
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await showDialog<void>(
                            context: context,
                            builder: (_) => TowerDialog(
                              condominiumId: widget.condominium.id,
                              tower: tower,
                            ),
                          );
                        }
                        if (value == 'delete' && context.mounted) {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Excluir torre'),
                              content: Text('Deseja excluir “${tower.name}”?'),
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
                            context.read<AppData>().removeTower(tower.id);
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
                      builder: (_) => TowerDialog(
                        condominiumId: widget.condominium.id,
                        tower: tower,
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

class TowerDialog extends StatefulWidget {
  const TowerDialog({
    super.key,
    required this.condominiumId,
    this.tower,
  });

  final String condominiumId;
  final Tower? tower;

  @override
  State<TowerDialog> createState() => _TowerDialogState();
}

class _TowerDialogState extends State<TowerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _notes;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final tower = widget.tower;
    _name = TextEditingController(text: tower?.name ?? '');
    _code = TextEditingController(text: tower?.code ?? '');
    _notes = TextEditingController(text: tower?.notes ?? '');
    _isActive = tower?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
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
    final editing = widget.tower != null;
    return AlertDialog(
      title: Text(editing ? 'Editar torre' : 'Nova torre'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: !editing,
                  decoration: const InputDecoration(
                    labelText: 'Nome da torre ou bloco *',
                    hintText: 'Ex.: Torre A ou Bloco 1',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    hintText: 'Ex.: A, B1 ou T01',
                  ),
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
                  title: const Text('Torre ativa'),
                  subtitle: const Text('Torres inativas permanecem cadastradas.'),
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
            final tower = widget.tower;
            if (tower == null) {
              data.addTower(
                condominiumId: widget.condominiumId,
                name: _name.text.trim(),
                code: _code.text.trim(),
                notes: _notes.text.trim(),
                isActive: _isActive,
              );
            } else {
              data.updateTower(
                tower.copyWith(
                  name: _name.text.trim(),
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
