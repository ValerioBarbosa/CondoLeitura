import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/meter.dart';
import '../../models/unit.dart';
import '../../providers/meter_provider.dart';
import '../../repositories/local/local_meter_repository.dart';
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
  late final MeterProvider _provider;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _provider = MeterProvider(repository: LocalMeterRepository());
    _provider.initialize(widget.unit);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _openForm([Meter? meter]) async {
    await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
      value: _provider,
      child: MeterFormScreen(unit: widget.unit, meter: meter),
    )));
  }

  Future<void> _openDetails(Meter meter) async {
    await Navigator.push<void>(context, MaterialPageRoute(builder: (_) => MeterDetailsScreen(
      unit: widget.unit,
      meter: meter,
      onEdit: () { Navigator.pop(context); _openForm(meter); },
    )));
  }

  Future<void> _delete(Meter meter) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Excluir medidor'),
      content: Text('Deseja excluir o medidor “${meter.serialNumber}”?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Excluir')),
      ],
    ));
    if (confirmed != true) return;
    final error = await _provider.delete(meter);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Medidor excluído com sucesso.')));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Medidores'),
          Text('Unidade ${widget.unit.number}', style: Theme.of(context).textTheme.labelMedium),
        ])),
        floatingActionButton: FloatingActionButton.extended(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: const Text('Novo medidor')),
        body: Consumer<MeterProvider>(builder: (context, provider, _) => RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar por série ou identificação'),
                onChanged: (value) { _debounce?.cancel(); _debounce = Timer(const Duration(milliseconds: 350), () => provider.setSearch(value)); },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MeterType?>(
                initialValue: provider.typeFilter,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem<MeterType?>(value: null, child: Text('Todos')),
                  DropdownMenuItem<MeterType?>(value: MeterType.water, child: Text('Água')),
                  DropdownMenuItem<MeterType?>(value: MeterType.gas, child: Text('Gás')),
                ],
                onChanged: provider.setTypeFilter,
              ),
              const SizedBox(height: 12),
              SegmentedButton<bool?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('Todos')),
                  ButtonSegment(value: true, label: Text('Ativos')),
                  ButtonSegment(value: false, label: Text('Inativos')),
                ],
                selected: {provider.activeFilter},
                onSelectionChanged: (value) => provider.setActiveFilter(value.first),
              ),
              const SizedBox(height: 16),
              if (provider.loading && provider.meters.isEmpty)
                const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
              else if (provider.error != null)
                Card(child: Padding(padding: const EdgeInsets.all(24), child: Text(provider.error!, textAlign: TextAlign.center)))
              else if (provider.meters.isEmpty)
                const Card(child: Padding(padding: EdgeInsets.all(32), child: Column(children: [
                  Icon(Icons.speed_outlined, size: 52), SizedBox(height: 12), Text('Nenhum medidor cadastrado'), SizedBox(height: 6), Text('Cadastre o primeiro medidor de água ou gás desta unidade.'),
                ])))
              else
                ...provider.meters.map((meter) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MeterCard(meter: meter, onTap: () => _openDetails(meter), onEdit: () => _openForm(meter), onDelete: () => _delete(meter)),
                )),
              const SizedBox(height: 90),
            ],
          ),
        )),
      ),
    );
  }
}
