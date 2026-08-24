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
    expect(find.textContaining('Série SN-001'), findsOneWidget);

    // Volta para a lista de unidades: o contador de hidrômetros reflete o cadastro.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 hidrômetro(s)'), findsOneWidget);
  });

  testWidgets('registra leituras a partir do histórico do medidor, calculando consumo', (tester) async {
    await tester.pumpWidget(const CondoLeituraApp());
    await tester.pumpAndSettle();

    // Cria torre, unidade e medidor de água (mesmo caminho do teste anterior).
    await tester.tap(find.widgetWithText(NavigationDestination, 'Condomínios'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Condomínio de Demonstração'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Torres e blocos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova torre'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome da torre ou bloco *'), 'Torre A');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Torre A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova unidade'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Número da unidade *'), '101');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Unidade 101'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo medidor'));
    await tester.pumpAndSettle();
    // Água já vem selecionado por padrão no diálogo.
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Abre o histórico do medidor e registra a primeira leitura.
    await tester.tap(find.text('Água').last);
    await tester.pumpAndSettle();
    expect(find.text('Histórico de leituras'), findsOneWidget);
    expect(find.text('Nenhuma leitura registrada'), findsOneWidget);

    await tester.tap(find.text('Nova leitura'));
    await tester.pumpAndSettle();
    expect(find.text('0.0'), findsOneWidget); // leitura anterior sugerida
    await tester.enterText(find.widgetWithText(TextFormField, 'Leitura atual *'), '50');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Anterior 0.0 • Atual 50.0'), findsOneWidget);
    expect(find.text('+50.0'), findsWidgets);

    // Registra uma segunda leitura: a anterior sugerida deve ser a última leitura salva.
    await tester.tap(find.text('Nova leitura'));
    await tester.pumpAndSettle();
    expect(find.text('50.0'), findsWidgets); // leitura anterior sugerida = última leitura
    await tester.enterText(find.widgetWithText(TextFormField, 'Leitura atual *'), '80');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Anterior 50.0 • Atual 80.0'), findsOneWidget);
    expect(find.text('+30.0'), findsWidgets);
    expect(find.text('2 leitura(s) registrada(s)'), findsOneWidget);
  });
}
