import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Campo de assinatura opcional: captura o traço em um canvas e exporta um
/// PNG em base64 quando o usuário termina de desenhar. `onChanged` recebe
/// `null` quando o campo está vazio.
class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final _repaintKey = GlobalKey();
  final List<List<Offset>> _strokes = [];

  bool get _isEmpty => _strokes.isEmpty;

  void _startStroke(Offset point) => setState(() => _strokes.add([point]));

  void _extendStroke(Offset point) => setState(() => _strokes.last.add(point));

  Future<void> _exportSignature() async {
    final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    widget.onChanged(base64Encode(bytes.buffer.asUint8List()));
  }

  void _clear() {
    setState(() => _strokes.clear());
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Assinatura do responsável (opcional)')),
            TextButton.icon(
              onPressed: _isEmpty ? null : _clear,
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Limpar'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: RepaintBoundary(
              key: _repaintKey,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: GestureDetector(
                  onPanStart: (details) => _startStroke(details.localPosition),
                  onPanUpdate: (details) => _extendStroke(details.localPosition),
                  onPanEnd: (_) => _exportSignature(),
                  child: CustomPaint(
                    painter: _SignaturePainter(_strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      for (var i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
