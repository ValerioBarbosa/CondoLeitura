import 'dart:convert';
import 'dart:typed_data';

import 'package:condoleitura/widgets/photo_capture_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakeImagePicker extends ImagePickerPlatform with MockPlatformInterfaceMixin {
  // PNG válido de 1x1 pixel transparente, para que Image.memory consiga decodificar.
  static final bytes = Uint8List.fromList(<int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x04, 0x00, 0x00, 0x00, 0xB5, 0x1C, 0x0C, 0x02, 0x00, 0x00, 0x00,
    0x0B, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xFA, 0xCF, 0x00, 0x00,
    0x02, 0x07, 0x01, 0x02, 0x9A, 0x1C, 0x31, 0x71, 0x00, 0x00, 0x00, 0x00,
    0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile.fromData(bytes, name: 'medidor.jpg', mimeType: 'image/jpeg');
  }
}

void main() {
  final originalPlatform = ImagePickerPlatform.instance;

  setUp(() => ImagePickerPlatform.instance = _FakeImagePicker());
  tearDown(() => ImagePickerPlatform.instance = originalPlatform);

  testWidgets('capturing a photo reports its bytes as base64 and shows a preview', (tester) async {
    String? captured;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PhotoCaptureField(onChanged: (value) => captured = value),
      ),
    ));

    expect(find.text('Fotografar medidor'), findsOneWidget);

    await tester.tap(find.text('Fotografar medidor'));
    await tester.pumpAndSettle();

    expect(captured, base64Encode(_FakeImagePicker.bytes));
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Fotografar medidor'), findsNothing);

    await tester.tap(find.byTooltip('Remover foto'));
    await tester.pumpAndSettle();

    expect(captured, isNull);
    expect(find.text('Fotografar medidor'), findsOneWidget);
  });
}
