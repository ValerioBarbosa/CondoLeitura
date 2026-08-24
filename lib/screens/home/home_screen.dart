import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../models/meter.dart';
import '../../models/reading.dart';
import '../../models/tower.dart';
import '../../models/unit.dart';
import '../../services/export/report_export_service.dart';
import '../../widgets/no_reading_dialog.dart';
import '../../widgets/photo_capture_field.dart';
import '../../widgets/reading_save_helpers.dart';
import '../../widgets/signature_pad.dart';
import '../condominiums/condominium_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = [
    'Visão geral',
    'Condomínios',
    'Leituras',
    'Relatórios',
    'Configurações',
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      DashboardPage(onNewReading: () => setState(() => _index = 2)),
      const CondominiumsPage(),
      const ReadingsPage(),
      const ReportsPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CondoLeitura'),
            Text(
              _titles[_index],
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ajuda',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'CondoLeitura',
              applicationVersion: '1.0.0',
              children: const [
                Text('Leitura e controle de medidores de água e gás.'),
              ],
            ),
            icon: const Icon(Icons.help_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (value) => setState(() => _index = value),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Início'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.apartment_outlined),
                      selectedIcon: Icon(Icons.apartment),
                      label: Text('Condomínios'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.speed_outlined),
                      selectedIcon: Icon(Icons.speed),
                      label: Text('Leituras'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.analytics_outlined),
                      selectedIcon: Icon(Icons.analytics),
                      label: Text('Relatórios'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Ajustes'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _index, children: pages)),
              ],
            )
          : IndexedStack(index: _index, children: pages),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Início'),
                NavigationDestination(icon: Icon(Icons.apartment_outlined), label: 'Condomínios'),
                NavigationDestination(icon: Icon(Icons.speed_outlined), label: 'Leituras'),
                NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Relatórios'),
                NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
              ],
            ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.onNewReading});

  final VoidCallback onNewReading;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Olá, Valério', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Acompanhe a operação de leitura dos seus condomínios.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MetricCard(icon: Icons.apartment, label: 'Condomínios', value: '${data.condominiums.length}'),
            MetricCard(icon: Icons.home_work_outlined, label: 'Unidades', value: '${data.totalUnits}'),
            MetricCard(icon: Icons.fact_check_outlined, label: 'Leituras', value: '${data.readings.length}'),
            MetricCard(icon: Icons.water_drop_outlined, label: 'Consumo total', value: data.totalConsumption.toStringAsFixed(1)),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onNewReading,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Nova leitura'),
          ),
        ),
        const SizedBox(height: 24),
        Text('Leituras recentes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...data.readings.take(4).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReadingTile(item: item),
            )),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: width >= 900 ? 210 : (width - 52) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(height: 14),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class CondominiumsPage extends StatelessWidget {
  const CondominiumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'condominiums-fab',
        onPressed: () => showDialog(context: context, builder: (_) => const CondominiumDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Novo condomínio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar condomínio'),
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          if (data.condominiums.isEmpty)
            const EmptyState(icon: Icons.apartment_outlined, title: 'Nenhum condomínio', subtitle: 'Cadastre o primeiro condomínio para começar.')
          else
            ...data.condominiums.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(child: Icon(Icons.apartment)),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${item.city} • ${data.towerCountFor(item.id)} torres cadastradas • '
                        '${data.unitCountFor(item.id)} unidades',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'towers') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CondominiumDashboardScreen(condominium: item),
                              ),
                            );
                          }
                          if (value == 'delete') {
                            context.read<AppData>().removeCondominium(item.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'towers', child: Text('Abrir dashboard')),
                          PopupMenuItem(value: 'delete', child: Text('Excluir')),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CondominiumDashboardScreen(condominium: item),
                        ),
                      ),
                    ),
                  ),
                )),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class CondominiumDialog extends StatefulWidget {
  const CondominiumDialog({super.key});
  @override
  State<CondominiumDialog> createState() => _CondominiumDialogState();
}

class _CondominiumDialogState extends State<CondominiumDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _units = TextEditingController(text: '1');

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _units.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo condomínio'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nome'), validator: requiredValidator),
                const SizedBox(height: 12),
                TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'Cidade'), validator: requiredValidator),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _units,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimativa inicial de unidades',
                    helperText: 'Será atualizada conforme as torres forem cadastradas.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            context.read<AppData>().addCondominium(
                  name: _name.text.trim(),
                  city: _city.text.trim(),
                  towers: 0,
                  units: int.tryParse(_units.text) ?? 1,
                );
            Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class ReadingsPage extends StatelessWidget {
  const ReadingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'readings-fab',
        onPressed: data.meters.isEmpty ? null : () => showDialog(context: context, builder: (_) => const ReadingDialog()),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Registrar leitura'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                const CircleAvatar(child: Icon(Icons.camera_alt_outlined)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Captura inteligente', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('Registre água ou gás. A conferência manual evita erro de leitura.'),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (data.readings.isEmpty)
            const EmptyState(icon: Icons.speed_outlined, title: 'Nenhuma leitura', subtitle: 'Registre a primeira leitura para gerar histórico e relatórios.')
          else
            ...data.readings.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => context.read<AppData>().removeReading(item.id),
                    child: ReadingTile(item: item),
                  ),
                )),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class ReadingDialog extends StatefulWidget {
  const ReadingDialog({super.key});
  @override
  State<ReadingDialog> createState() => _ReadingDialogState();
}

class _ReadingDialogState extends State<ReadingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  String? _condominiumId;
  String? _towerId;
  String? _unitId;
  String? _meterId;
  String? _photoBase64;
  String? _signatureBase64;
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final condos = data.condominiums;
    _condominiumId ??= condos.isEmpty ? null : condos.first.id;

    final towers = _condominiumId == null ? const <Tower>[] : data.towersFor(_condominiumId!);
    if (_towerId == null || !towers.any((t) => t.id == _towerId)) {
      _towerId = towers.isEmpty ? null : towers.first.id;
    }

    final units = _towerId == null ? const <Unit>[] : data.unitsFor(_towerId!);
    if (_unitId == null || !units.any((u) => u.id == _unitId)) {
      _unitId = units.isEmpty ? null : units.first.id;
    }

    final meters = _unitId == null ? const <Meter>[] : data.metersFor(_unitId!);
    if (_meterId == null || !meters.any((m) => m.id == _meterId)) {
      _meterId = meters.isEmpty ? null : meters.first.id;
    }

    final previousValue = _meterId == null ? null : data.lastReadingFor(_meterId!)?.currentValue ?? 0;

    return AlertDialog(
      title: const Text('Registrar leitura'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: _condominiumId,
                decoration: const InputDecoration(labelText: 'Condomínio'),
                items: condos.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                onChanged: (value) => setState(() {
                  _condominiumId = value;
                  _towerId = null;
                  _unitId = null;
                  _meterId = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _towerId,
                decoration: const InputDecoration(labelText: 'Torre ou bloco'),
                items: towers.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                onChanged: towers.isEmpty
                    ? null
                    : (value) => setState(() {
                          _towerId = value;
                          _unitId = null;
                          _meterId = null;
                        }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _unitId,
                decoration: const InputDecoration(labelText: 'Unidade'),
                items: units.map((e) => DropdownMenuItem(value: e.id, child: Text('Unidade ${e.number}'))).toList(),
                onChanged: units.isEmpty
                    ? null
                    : (value) => setState(() {
                          _unitId = value;
                          _meterId = null;
                        }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _meterId,
                decoration: const InputDecoration(labelText: 'Medidor'),
                items: meters
                    .map((e) => DropdownMenuItem(value: e.id, child: Text('${e.type}${e.serialNumber.isEmpty ? '' : ' • ${e.serialNumber}'}')))
                    .toList(),
                onChanged: meters.isEmpty ? null : (value) => setState(() => _meterId = value),
              ),
              if (meters.isEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Cadastre um medidor para essa unidade antes de registrar uma leitura.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Leitura anterior'),
                    child: Text((previousValue ?? 0).toStringAsFixed(1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _current,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Leitura atual'),
                    validator: numberValidator,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              PhotoCaptureField(
                onChanged: (value) => setState(() => _photoBase64 = value),
                onTextRecognized: (digits) => _current.text = digits,
              ),
              const SizedBox(height: 12),
              SignaturePad(onChanged: (value) => _signatureBase64 = value),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: _meterId == null ? null : () => showNoReadingDialog(context, _meterId!),
          child: const Text('Sem leitura'),
        ),
        FilledButton(
          onPressed: meters.isEmpty || _saving
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final current = parseNumber(_current.text);
                  if (current < (previousValue ?? 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A leitura atual não pode ser menor que a anterior.')));
                    return;
                  }
                  final data = context.read<AppData>();
                  if (!await confirmReadingIfNeeded(context, data.settings)) return;
                  if (!context.mounted) return;

                  setState(() => _saving = true);
                  final location = await captureLocationIfEnabled(data.settings);
                  data.addReading(
                    meterId: _meterId!,
                    currentValue: current,
                    photoBase64: _photoBase64,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    signatureBase64: _signatureBase64,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar leitura'),
        ),
      ],
    );
  }
}

class ReadingTile extends StatelessWidget {
  const ReadingTile({super.key, required this.item});
  final Reading item;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final meter = data.meterById(item.meterId);
    final water = meter?.type != meterTypeGas;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: item.photoBase64 == null
            ? CircleAvatar(child: Icon(water ? Icons.water_drop_outlined : Icons.local_fire_department_outlined))
            : CircleAvatar(backgroundImage: MemoryImage(base64Decode(item.photoBase64!))),
        title: Text(data.meterLabel(item.meterId), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(item.currentValue.toStringAsFixed(1), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text('+${item.consumption.toStringAsFixed(1)}'),
        ]),
      ),
    );
  }
}

enum _ReportPeriod { all, last7, last30, last90 }

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? _condominiumId;
  _ReportPeriod _period = _ReportPeriod.all;
  bool _exporting = false;

  List<Reading> _filteredReadings(AppData data) {
    final cutoff = switch (_period) {
      _ReportPeriod.all => null,
      _ReportPeriod.last7 => DateTime.now().subtract(const Duration(days: 7)),
      _ReportPeriod.last30 => DateTime.now().subtract(const Duration(days: 30)),
      _ReportPeriod.last90 => DateTime.now().subtract(const Duration(days: 90)),
    };
    return data.readings.where((reading) {
      if (cutoff != null && reading.createdAt.isBefore(cutoff)) return false;
      if (_condominiumId == null) return true;
      final meter = data.meterById(reading.meterId);
      final unit = meter == null ? null : data.unitById(meter.unitId);
      final tower = unit == null ? null : data.towerById(unit.towerId);
      return tower?.condominiumId == _condominiumId;
    }).toList();
  }

  Future<void> _export(Future<void> Function() run) async {
    setState(() => _exporting = true);
    try {
      await run();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relatório gerado com sucesso.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível gerar o relatório.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final filtered = _filteredReadings(data);
    final water = filtered.where((e) => data.meterById(e.meterId)?.type != meterTypeGas).fold<double>(0, (sum, e) => sum + e.consumption);
    final gas = filtered.where((e) => data.meterById(e.meterId)?.type == meterTypeGas).fold<double>(0, (sum, e) => sum + e.consumption);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Resumo operacional', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _condominiumId,
                  decoration: const InputDecoration(labelText: 'Condomínio'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos os condomínios')),
                    ...data.condominiums.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))),
                  ],
                  onChanged: (value) => setState(() => _condominiumId = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<_ReportPeriod>(
                  initialValue: _period,
                  decoration: const InputDecoration(labelText: 'Período'),
                  items: const [
                    DropdownMenuItem(value: _ReportPeriod.all, child: Text('Todo o período')),
                    DropdownMenuItem(value: _ReportPeriod.last7, child: Text('Últimos 7 dias')),
                    DropdownMenuItem(value: _ReportPeriod.last30, child: Text('Últimos 30 dias')),
                    DropdownMenuItem(value: _ReportPeriod.last90, child: Text('Últimos 90 dias')),
                  ],
                  onChanged: (value) => setState(() => _period = value ?? _period),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              ReportRow(icon: Icons.water_drop_outlined, label: 'Consumo de água', value: water.toStringAsFixed(1)),
              const Divider(height: 28),
              ReportRow(icon: Icons.local_fire_department_outlined, label: 'Consumo de gás', value: gas.toStringAsFixed(1)),
              const Divider(height: 28),
              ReportRow(icon: Icons.fact_check_outlined, label: 'Leituras no período', value: '${filtered.length}'),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Exportação', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Gera um relatório com as leituras filtradas acima. Na Web, o arquivo é baixado direto pelo navegador.'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: filtered.isEmpty || _exporting
                        ? null
                        : () => _export(() => ReportExportService.exportCsv(data, filtered)),
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('Exportar CSV'),
                  ),
                  OutlinedButton.icon(
                    onPressed: filtered.isEmpty || _exporting
                        ? null
                        : () => _export(() => ReportExportService.exportExcel(data, filtered)),
                    icon: const Icon(Icons.grid_on_outlined),
                    label: const Text('Exportar Excel'),
                  ),
                  OutlinedButton.icon(
                    onPressed: filtered.isEmpty || _exporting
                        ? null
                        : () => _export(() => ReportExportService.exportPdf(data, filtered)),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Exportar PDF'),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class ReportRow extends StatelessWidget {
  const ReportRow({super.key, required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(child: Icon(icon)),
      const SizedBox(width: 14),
      Expanded(child: Text(label)),
      Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _readerName = TextEditingController();
  String? _syncedReaderName;

  @override
  void dispose() {
    _readerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final settings = data.settings;

    // AppData loads its persisted settings asynchronously after this page's
    // first build, so the controller can't just be seeded once in initState:
    // it has to pick up the loaded readerName whenever it actually changes,
    // without clobbering text the user is actively typing.
    if (_syncedReaderName != settings.readerName) {
      _syncedReaderName = settings.readerName;
      if (_readerName.text != settings.readerName) {
        _readerName.text = settings.readerName;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _readerName,
              decoration: const InputDecoration(
                labelText: 'Nome do leiturista',
                helperText: 'Aparece no histórico das leituras registradas por você.',
              ),
              onChanged: (value) => data.updateSettings(settings.copyWith(readerName: value)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(children: [
            SwitchListTile(
              value: settings.confirmReading,
              onChanged: (v) => data.updateSettings(settings.copyWith(confirmReading: v)),
              title: const Text('Confirmar leitura'),
              subtitle: const Text('Exigir revisão antes de salvar.'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: settings.registerLocation,
              onChanged: (v) => data.updateSettings(settings.copyWith(registerLocation: v)),
              title: const Text('Registrar localização'),
              subtitle: const Text('Salvar GPS junto da leitura, quando o navegador ou aparelho permitir.'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: settings.autoSync,
              onChanged: (v) => data.updateSettings(settings.copyWith(autoSync: v)),
              title: const Text('Sincronização automática'),
              subtitle: const Text('Ainda sem efeito: o app não tem servidor configurado, então os dados ficam só neste aparelho.'),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Column(children: [
            ListTile(leading: Icon(Icons.storage_outlined), title: Text('Banco local'), subtitle: Text('Dados disponíveis offline')),
            Divider(height: 1),
            ListTile(leading: Icon(Icons.info_outline), title: Text('Versão'), trailing: Text('1.0.0')),
          ]),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(children: [
        Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center),
      ]),
    );
  }
}

String? requiredValidator(String? value) => value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;
String? numberValidator(String? value) => double.tryParse((value ?? '').replaceAll(',', '.')) == null ? 'Número inválido' : null;
double parseNumber(String value) => double.parse(value.replaceAll(',', '.'));
