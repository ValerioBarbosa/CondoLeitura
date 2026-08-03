import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../towers/towers_screen.dart';

class CondominiumDashboardScreen extends StatelessWidget {
  const CondominiumDashboardScreen({
    super.key,
    required this.condominium,
  });

  final CondoItem condominium;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final towerCount = data.towerCountFor(condominium.id);
    final unitCount = data.unitCountFor(condominium.id);
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width >= 900 ? 260.0 : (width - 52) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(condominium.name),
            Text(
              condominium.city,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Resumo do condomínio',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                width: cardWidth,
                icon: Icons.domain_outlined,
                label: 'Torres e blocos',
                value: '$towerCount',
              ),
              _MetricCard(
                width: cardWidth,
                icon: Icons.home_work_outlined,
                label: 'Unidades',
                value: '$unitCount',
              ),
              _MetricCard(
                width: cardWidth,
                icon: Icons.water_drop_outlined,
                label: 'Hidrômetros',
                value: '0',
              ),
              _MetricCard(
                width: cardWidth,
                icon: Icons.fact_check_outlined,
                label: 'Leituras',
                value: '0',
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Ações',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ModuleCard(
            icon: Icons.domain_outlined,
            title: 'Torres e blocos',
            subtitle: towerCount == 0
                ? 'Cadastre a primeira torre deste condomínio.'
                : '$towerCount cadastrada(s)',
            enabled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TowersScreen(condominium: condominium),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _ModuleCard(
            icon: Icons.home_work_outlined,
            title: 'Apartamentos e unidades',
            subtitle: 'Disponível na próxima etapa.',
            enabled: false,
          ),
          const SizedBox(height: 12),
          const _ModuleCard(
            icon: Icons.water_drop_outlined,
            title: 'Hidrômetros',
            subtitle: 'Disponível após o módulo de unidades.',
            enabled: false,
          ),
          const SizedBox(height: 12),
          const _ModuleCard(
            icon: Icons.speed_outlined,
            title: 'Leituras',
            subtitle: 'Disponível em uma etapa futura.',
            enabled: false,
          ),
          const SizedBox(height: 12),
          const _ModuleCard(
            icon: Icons.analytics_outlined,
            title: 'Relatórios',
            subtitle: 'Disponível em uma etapa futura.',
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        enabled: enabled,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(enabled ? Icons.chevron_right : Icons.lock_outline),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
