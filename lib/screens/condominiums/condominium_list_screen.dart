import 'package:flutter/material.dart';

class CondominiumListScreen extends StatelessWidget {
  const CondominiumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Condomínios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/condominiums/form'),
        icon: const Icon(Icons.add),
        label: const Text('Novo condomínio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Pesquisar por nome, código ou cidade',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.apartment)),
              title: const Text('Condomínio de demonstração'),
              subtitle: const Text('12 torres • 380 unidades • Sincronizado'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'duplicate', child: Text('Duplicar')),
                  PopupMenuItem(value: 'archive', child: Text('Arquivar')),
                  PopupMenuItem(value: 'export', child: Text('Exportar')),
                  PopupMenuItem(value: 'sync', child: Text('Sincronizar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
              onTap: () => Navigator.pushNamed(
                context,
                '/condominiums/details',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
