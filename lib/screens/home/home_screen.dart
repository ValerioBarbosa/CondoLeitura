import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
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
                  onDestinationSelected: (value) =>
                      setState(() => _index = value),
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
                NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined), label: 'Início'),
                NavigationDestination(
                    icon: Icon(Icons.apartment_outlined), label: 'Condomínios'),
                NavigationDestination(
                    icon: Icon(Icons.speed_outlined), label: 'Leituras'),
                NavigationDestination(
                    icon: Icon(Icons.analytics_outlined), label: 'Relatórios'),
                NavigationDestination(
                    icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
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
        Text('Olá, Valério',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Acompanhe a operação de leitura dos seus condomínios.',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MetricCard(
                icon: Icons.apartment,
                label: 'Condomínios',
                value: '${data.condominiums.length}'),
            MetricCard(
                icon: Icons.home_work_outlined,
                label: 'Unidades',
                value: '${data.totalUnits}'),
            MetricCard(
                icon: Icons.fact_check_outlined,
                label: 'Leituras',
                value: '${data.readings.length}'),
            MetricCard(
                icon: Icons.water_drop_outlined,
                label: 'Consumo total',
                value: data.totalConsumption.toStringAsFixed(1)),
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
        Text('Leituras recentes',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
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
  const MetricCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});
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
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
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
        onPressed: () => showDialog(
            context: context, builder: (_) => const CondominiumDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Novo condomínio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Pesquisar condomínio'),
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          if (data.condominiums.isEmpty)
            const EmptyState(
                icon: Icons.apartment_outlined,
                title: 'Nenhum condomínio',
                subtitle: 'Cadastre o primeiro condomínio para começar.')
          else
            ...data.condominiums.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(child: Icon(Icons.apartment)),
                      title: Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                builder: (_) => CondominiumDashboardScreen(
                                    condominium: item),
                              ),
                            );
                          }
                          if (value == 'delete') {
                            context.read<AppData>().removeCondominium(item.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'towers', child: Text('Abrir dashboard')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Excluir')),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CondominiumDashboardScreen(condominium: item),
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
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: requiredValidator),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'Cidade'),
                    validator: requiredValidator),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _units,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimativa inicial de unidades',
                    helperText:
                        'Será atualizada conforme as torres forem cadastradas.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
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
        onPressed: data.condominiums.isEmpty
            ? null
            : () => showDialog(
                context: context, builder: (_) => const ReadingDialog()),
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
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Captura inteligente',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Text(
                          'Registre água ou gás. A conferência manual evita erro de leitura.'),
                    ])),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (data.readings.isEmpty)
            const EmptyState(
                icon: Icons.speed_outlined,
                title: 'Nenhuma leitura',
                subtitle:
                    'Registre a primeira leitura para gerar histórico e relatórios.')
          else
            ...data.readings.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) =>
                        context.read<AppData>().removeReading(item.id),
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
  final _unit = TextEditingController();
  final _previous = TextEditingController();
  final _current = TextEditingController();
  String? _condominium;
  String _type = 'Água';

  @override
  void dispose() {
    _unit.dispose();
    _previous.dispose();
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final condos = context.read<AppData>().condominiums;
    _condominium ??= condos.first.name;
    return AlertDialog(
      title: const Text('Registrar leitura'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: _condominium,
                decoration: const InputDecoration(labelText: 'Condomínio'),
                items: condos
                    .map((e) =>
                        DropdownMenuItem(value: e.name, child: Text(e.name)))
                    .toList(),
                onChanged: (value) => setState(() => _condominium = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _unit,
                  decoration: const InputDecoration(
                      labelText: 'Unidade', hintText: 'Ex.: Torre A • 101'),
                  validator: requiredValidator),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'Água',
                      icon: Icon(Icons.water_drop_outlined),
                      label: Text('Água')),
                  ButtonSegment(
                      value: 'Gás',
                      icon: Icon(Icons.local_fire_department_outlined),
                      label: Text('Gás')),
                ],
                selected: {_type},
                onSelectionChanged: (value) =>
                    setState(() => _type = value.first),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _previous,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Leitura anterior'),
                        validator: numberValidator)),
                const SizedBox(width: 12),
                Expanded(
                    child: TextFormField(
                        controller: _current,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Leitura atual'),
                        validator: numberValidator)),
              ]),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            final previous = parseNumber(_previous.text);
            final current = parseNumber(_current.text);
            if (current < previous) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'A leitura atual não pode ser menor que a anterior.')));
              return;
            }
            context.read<AppData>().addReading(
                  condominium: _condominium!,
                  unit: _unit.text.trim(),
                  meterType: _type,
                  previousValue: previous,
                  currentValue: current,
                );
            Navigator.pop(context);
          },
          child: const Text('Salvar leitura'),
        ),
      ],
    );
  }
}

class ReadingTile extends StatelessWidget {
  const ReadingTile({super.key, required this.item});
  final MeterReadingItem item;

  @override
  Widget build(BuildContext context) {
    final water = item.meterType == 'Água';
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
            child: Icon(water
                ? Icons.water_drop_outlined
                : Icons.local_fire_department_outlined)),
        title: Text('${item.unit} • ${item.meterType}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            '${item.condominium}\n${DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt)}'),
        isThreeLine: true,
        trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.currentValue.toStringAsFixed(1),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text('+${item.consumption.toStringAsFixed(1)}'),
            ]),
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final water = data.readings
        .where((e) => e.meterType == 'Água')
        .fold<double>(0, (sum, e) => sum + e.consumption);
    final gas = data.readings
        .where((e) => e.meterType == 'Gás')
        .fold<double>(0, (sum, e) => sum + e.consumption);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Resumo operacional',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              ReportRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Consumo de água',
                  value: water.toStringAsFixed(1)),
              const Divider(height: 28),
              ReportRow(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Consumo de gás',
                  value: gas.toStringAsFixed(1)),
              const Divider(height: 28),
              ReportRow(
                  icon: Icons.fact_check_outlined,
                  label: 'Leituras registradas',
                  value: '${data.readings.length}'),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Exportação',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Os serviços de PDF, Excel e compartilhamento já estão preparados no projeto.'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: data.readings.isEmpty
                        ? null
                        : () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Relatório preparado. Integração de arquivo disponível na versão móvel.'))),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Gerar relatório'),
                  ),
                ]),
          ),
        ),
      ],
    );
  }
}

class ReportRow extends StatelessWidget {
  const ReportRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(child: Icon(icon)),
      const SizedBox(width: 14),
      Expanded(child: Text(label)),
      Text(value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
    ]);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _confirmReading = true;
  bool _location = false;
  bool _sync = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Column(children: [
            SwitchListTile(
                value: _confirmReading,
                onChanged: (v) => setState(() => _confirmReading = v),
                title: const Text('Confirmar leitura'),
                subtitle: const Text('Exigir revisão antes de salvar.')),
            const Divider(height: 1),
            SwitchListTile(
                value: _location,
                onChanged: (v) => setState(() => _location = v),
                title: const Text('Registrar localização'),
                subtitle: const Text('Salvar GPS junto da leitura.')),
            const Divider(height: 1),
            SwitchListTile(
                value: _sync,
                onChanged: (v) => setState(() => _sync = v),
                title: const Text('Sincronização automática'),
                subtitle: const Text('Enviar dados quando houver internet.')),
          ]),
        ),
        const SizedBox(height: 16),
        const Card(
          child: Column(children: [
            ListTile(
                leading: Icon(Icons.storage_outlined),
                title: Text('Banco local'),
                subtitle: Text('Dados disponíveis offline')),
            Divider(height: 1),
            ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Versão'),
                trailing: Text('1.0.0')),
          ]),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});
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
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center),
      ]),
    );
  }
}

String? requiredValidator(String? value) =>
    value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;
String? numberValidator(String? value) =>
    double.tryParse((value ?? '').replaceAll(',', '.')) == null
        ? 'Número inválido'
        : null;
double parseNumber(String value) => double.parse(value.replaceAll(',', '.'));
