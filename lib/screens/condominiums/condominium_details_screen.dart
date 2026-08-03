import 'package:flutter/material.dart';

class CondominiumDetailsScreen extends StatelessWidget {
  const CondominiumDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do condomínio'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/condominiums/form'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.apartment)),
            title: Text('Condomínio de demonstração'),
            subtitle: Text('Ativo • Sincronizado'),
          ),
          Card(
            child: Column(
              children: [
                ListTile(title: Text('Torres'), trailing: Text('12')),
                Divider(height: 1),
                ListTile(title: Text('Unidades'), trailing: Text('380')),
                Divider(height: 1),
                ListTile(title: Text('Medidores'), trailing: Text('382')),
                Divider(height: 1),
                ListTile(title: Text('Pendências'), trailing: Text('18')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
