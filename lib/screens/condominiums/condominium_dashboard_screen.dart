import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_data.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/widgets/dashboard/app_metric_card.dart';
import '../../shared/widgets/dashboard/app_module_card.dart';
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
    final meterCount = data.meterCountFor(condominium.id);
    final readingCount = data.readingCountFor(condominium.id);
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
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'Resumo do condomínio',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppMetricCard(
                width: cardWidth,
                icon: Icons.domain_outlined,
                label: 'Torres e blocos',
                value: '$towerCount',
              ),
              AppMetricCard(
                width: cardWidth,
                icon: Icons.home_work_outlined,
                label: 'Unidades',
                value: '$unitCount',
              ),
              AppMetricCard(
                width: cardWidth,
                icon: Icons.water_drop_outlined,
                label: 'Hidrômetros',
                value: '$meterCount',
              ),
              AppMetricCard(
                width: cardWidth,
                icon: Icons.fact_check_outlined,
                label: 'Leituras',
                value: '$readingCount',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Ações',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          AppModuleCard(
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
          const SizedBox(height: AppSpacing.md),
          AppModuleCard(
            icon: Icons.home_work_outlined,
            title: 'Apartamentos e unidades',
            subtitle: towerCount == 0
                ? 'Cadastre uma torre antes de incluir unidades.'
                : '$unitCount cadastrada(s)',
            enabled: towerCount > 0,
            onTap: towerCount > 0
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TowersScreen(condominium: condominium),
                      ),
                    )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppModuleCard(
            icon: Icons.water_drop_outlined,
            title: 'Hidrômetros',
            subtitle: unitCount == 0
                ? 'Cadastre uma unidade antes de incluir medidores.'
                : '$meterCount cadastrado(s). Abra uma unidade para gerenciar.',
            enabled: unitCount > 0,
            onTap: unitCount > 0
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TowersScreen(condominium: condominium),
                      ),
                    )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppModuleCard(
            icon: Icons.speed_outlined,
            title: 'Leituras',
            subtitle: meterCount == 0
                ? 'Cadastre um medidor antes de registrar leituras.'
                : '$readingCount leitura(s). Abra um medidor para registrar ou consultar.',
            enabled: meterCount > 0,
            onTap: meterCount > 0
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TowersScreen(condominium: condominium),
                      ),
                    )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppModuleCard(
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

