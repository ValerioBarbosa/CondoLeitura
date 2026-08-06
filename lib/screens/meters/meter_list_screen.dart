import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../models/unit.dart';
import '../../widgets/meter_card.dart';
import 'meter_details_screen.dart';
import 'meter_form_screen.dart';

class MeterListScreen extends StatefulWidget {
  const MeterListScreen({super.key, required this.unit});
  final Unit unit;

  @override
  State<MeterListScreen> createState() => _MeterListScreenState();
}

class _MeterListScreenState extends State<MeterListScreen> {
  String _search = '';
  MeterType? _type;
  bool? _active;

  Future<void> _openForm([Meter? meter]) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MeterFormScreen(unit: widget.unit, meter: meter),
      ),
    );
  }

  Future<void> _openDetails(Meter meter) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MeterDetailsScreen(
          unit: widget.unit,
          meter: meter,
          onEdit: () {
            Navigator.pop(context);
            _openForm(meter);
          },
        ),
      ),
    );
  }

  Future<void> _delete(Meter meter) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir medidor'),
        content: Text(
          'Deseja excluir o medidor “${meter.serialNumber}”? Esta ação também removerá as leituras vinculadas no futuro.',
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
    if (confirmed != true || meter.id == null || !mounted) return;
    context.read<AppData>().removeMeter(meter.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medidor excluído com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final unitId = widget.unit.id;
    final meters = unitId == null
        ? const <Meter>[]
        : data.metersForUnit(
            unitId,
            search: _search,
            type: _type,
            active: _active,
          );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medidores'),
            Text(
              'Unidade ${widget.unit.number}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: unitId == null ? null : () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo medidor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar por série, fabricante ou modelo',
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MeterType?>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: const [
              DropdownMenuItem<MeterType?>(value: null, child: Text('Todos')),
              DropdownMenuItem<MeterType?>(
                value: MeterType.water,
                child: Text('Água'),
              ),
              DropdownMenuItem<MeterType?>(
                value: MeterType.gas,
                child: Text('Gás'),
              ),
            ],
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool?>(
            segments: const [
              ButtonSegment<bool?>(value: null, label: Text('Todos')),
              ButtonSegment<bool?>(value: true, label: Text('Ativos')),
              ButtonSegment<bool?>(value: false, label: Text('Inativos')),
            ],
            selected: {_active},
            onSelectionChanged: (value) {
              setState(() => _active = value.first);
            },
          ),
          const SizedBox(height: 16),
          if (meters.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.speed_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      _search.isEmpty && _type == null && _active == null
                          ? 'Nenhum medidor cadastrado'
                          : 'Nenhum medidor encontrado',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _search.isEmpty && _type == null && _active == null
                          ? 'Cadastre o primeiro medidor de água ou gás desta unidade.'
                          : 'Altere os filtros ou o termo pesquisado.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...meters.map(
              (meter) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MeterCard(
                  meter: meter,
                  onTap: () => _openDetails(meter),
                  onEdit: () => _openForm(meter),
                  onDelete: () => _delete(meter),
                ),
              ),
            ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
