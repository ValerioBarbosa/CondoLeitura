import 'package:flutter/material.dart';

class CondominiumFormScreen extends StatefulWidget {
  const CondominiumFormScreen({super.key});

  @override
  State<CondominiumFormScreen> createState() => _CondominiumFormScreenState();
}

class _CondominiumFormScreenState extends State<CondominiumFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Condomínio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nome *'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o nome.'
                  : null,
            ),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Código')),
            TextFormField(decoration: const InputDecoration(labelText: 'CNPJ')),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Endereço')),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Cidade')),
            TextFormField(decoration: const InputDecoration(labelText: 'UF')),
            TextFormField(decoration: const InputDecoration(labelText: 'CEP')),
            TextFormField(
                decoration: const InputDecoration(labelText: 'Telefone')),
            TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail')),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Administradora'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Responsável'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Salvar condomínio'),
            ),
          ],
        ),
      ),
    );
  }
}
