import 'package:flutter/material.dart';

class RouteSummaryScreen extends StatelessWidget {
  const RouteSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Summary')),
      body: const Center(child: Text('Route Summary')),
    );
  }
}
