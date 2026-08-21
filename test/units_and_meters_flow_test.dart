import 'package:condoleitura/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('cria torre, unidade e medidor navegando pela hierarquia real', (tester) async {
    await tester.pumpWidget(const CondoLeituraApp());
    await tester.pumpAndSettle();

    // Vai para a aba Condomínios e abre o dashboard do condomínio de demonstração.
    await tester.tap(find.widgetWithText(NavigationDestination, 'Condomínios'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Condomínio de Demonstração'));
    await tester.pumpAndSettle();

    // Abre o módulo de Torres e cadastra uma torre.
    await tester.tap(find.widgetWithText(ListTile, 'Torres e blocos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova torre'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome da torre ou bloco *'), 'Torre A');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Torre A'), findsOneWidget);

    // Abre a torre recém-criada e cadastra uma unidade.
    await tester.tap(find.text('Torre A'));
    await tester.pumpAndSettle();
    expect(find.text('Unidades'), findsWidgets);
    await tester.tap(find.text('Nova unidade'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Número da unidade *'), '101');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Unidade 101'), findsOneWidget);

    // Abre a unidade e cadastra um medidor de gás.
    await tester.tap(find.text('Unidade 101'));
    await tester.pumpAndSettle();
    expect(find.text('Hidrômetros'), findsWidgets);
    await tester.tap(find.text('Novo medidor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gás'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Número de série'), 'SN-001');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Gás'), findsWidgets);
    expect(find.text('Série SN-001'), findsOneWidget);

    // Volta para a lista de unidades: o contador de hidrômetros reflete o cadastro.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 hidrômetro(s)'), findsOneWidget);
  });
}
