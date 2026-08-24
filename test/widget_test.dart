import 'package:condoleitura/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('abre o painel principal', (tester) async {
    await tester.pumpWidget(const CondoLeituraApp());
    await tester.pumpAndSettle();
    expect(find.text('CondoLeitura'), findsWidgets);
    expect(find.text('Nova leitura'), findsOneWidget);
  });

  testWidgets('mostra o nome do leiturista salvo mesmo carregado após o primeiro build', (tester) async {
    // AppData.load() é assíncrono e roda depois do primeiro build da árvore
    // (inclusive da tela de Ajustes, que fica sempre montada dentro do
    // IndexedStack). Isso já causou um bug real: o campo ficava vazio para
    // sempre porque só era preenchido uma vez, em initState.
    SharedPreferences.setMockInitialValues({
      'mvp_settings': '{"confirmReading":true,"registerLocation":false,"autoSync":true,"readerName":"Valério"}',
    });

    await tester.pumpWidget(const CondoLeituraApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajustes').last);
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller?.text, 'Valério');
  });
}
