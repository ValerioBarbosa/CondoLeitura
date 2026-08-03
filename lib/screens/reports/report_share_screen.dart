import 'package:flutter/material.dart';

class ReportShareScreen extends StatelessWidget {
  const ReportShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compartilhar relatório')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
              leading: Icon(Icons.picture_as_pdf), title: Text('Gerar PDF')),
          ListTile(
              leading: Icon(Icons.table_chart), title: Text('Gerar Excel')),
          ListTile(leading: Icon(Icons.grid_on), title: Text('Gerar CSV')),
          Divider(),
          ListTile(
              leading: Icon(Icons.share),
              title: Text('Compartilhar'),
              subtitle: Text('WhatsApp, Telegram, Drive e outros')),
          ListTile(
              leading: Icon(Icons.email), title: Text('Enviar por e-mail')),
          ListTile(
              leading: Icon(Icons.save_alt), title: Text('Salvar no aparelho')),
          ListTile(leading: Icon(Icons.print), title: Text('Imprimir PDF')),
        ],
      ),
    );
  }
}
