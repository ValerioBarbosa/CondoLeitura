import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class AppModuleCard extends StatelessWidget {
  const AppModuleCard({
    super.key,
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
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
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
