import 'package:flutter/material.dart';

class CameraPreviewScreen extends StatelessWidget {
  const CameraPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Preview')),
      body: const Center(child: Text('Camera Preview')),
    );
  }
}
