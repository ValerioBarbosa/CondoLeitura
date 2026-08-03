import 'package:flutter/material.dart';

class ManualCorrectionScreen extends StatelessWidget {
  const ManualCorrectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Correction')),
      body: const Center(child: Text('Manual Correction')),
    );
  }
}
