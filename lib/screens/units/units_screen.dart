import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tower.dart';
import '../../models/unit.dart';
import '../../providers/unit_provider.dart';
import '../../models/app_data.dart';
import '../../repositories/local/app_data_unit_repository.dart';
import '../../widgets/unit_card.dart';
import 'unit_details_screen.dart';
import 'unit_form_screen.dart';

class UnitsScreen extends StatefulWidget {
  const UnitsScreen({super.key, required this.tower});

  final Tower tower;

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  UnitProvider? _provider;
  Timer? _searchDebounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_provider != null) return;
    final provider = UnitProvider(
      repository: AppDataUnitRepository(context.read<AppData>()),
    );
    _provider = provider;
    provider.initialize(widget.tower);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _provider?.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _provider?.setSearch(value),
    );
  }

  Future<void> _openForm([Unit? unit]) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _provider!,
          child: UnitFormScreen(tower: widget.tower, unit: unit),
        ),
      ),
    );
  }

  Future<void> _openDetails(Unit unit) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => UnitDetailsScreen(
          tower: widget.tower,
          unit: unit,
          onEdit: () {
            Navigator.pop(context);
            _openForm(unit);
          },
        ),
      ),
    );
  }

  Future<void> _delete(Unit unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir unidade'),
        content: Text(
          'Deseja excluir a unidade “${unit.number}”? Esta ação não poderá ser desfeita.',
        ),
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
    if (confirmed != true) return;
    final error = await _provider!.delete(unit);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Unidade excluída com sucesso.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider!,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Unidades e apartamentos'),
              Text(
                widget.tower.name,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Nova unidade'),
        ),
        body: Consumer<UnitProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Pesquisar por identificador ou observação',
                    ),
                    onChanged: _onSearch,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool?>(
                    segments: const [
                      ButtonSegment<bool?>(
                        value: null,
                        label: Text('Todas'),
                        icon: Icon(Icons.list_alt_outlined),
                      ),
                      ButtonSegment<bool?>(
                        value: true,
                        label: Text('Ativas'),
                        icon: Icon(Icons.check_circle_outline),
                      ),
                      ButtonSegment<bool?>(
                        value: false,
                        label: Text('Inativas'),
                        icon: Icon(Icons.pause_circle_outline),
                      ),
                    ],
                    selected: {provider.activeFilter},
                    onSelectionChanged: (selection) {
                      provider.setActiveFilter(selection.first);
                    },
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
                            icon: Icons.apartment_outlined,
                            label: 'Exibidas',
                            value: '${provider.units.length}',
                          ),
                          _SummaryItem(
                            icon: Icons.check_circle_outline,
                            label: 'Ativas',
                            value: '${provider.activeCount}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.loading && provider.units.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.error != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 10),
                            Text(provider.error!, textAlign: TextAlign.center),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: provider.load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (provider.units.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.apartment_outlined,
                              size: 52,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              provider.search.isEmpty
                                  ? 'Nenhuma unidade cadastrada'
                                  : 'Nenhuma unidade encontrada',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              provider.search.isEmpty
                                  ? 'Cadastre a primeira unidade desta torre.'
                                  : 'Altere os filtros ou o termo pesquisado.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...provider.units.map(
                      (unit) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: UnitCard(
                          unit: unit,
                          onTap: () => _openDetails(unit),
                          onEdit: () => _openForm(unit),
                          onDelete: () => _delete(unit),
                        ),
                      ),
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            );
          },
        ),
      ),
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
