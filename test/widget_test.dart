import 'package:condoleitura/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre o painel principal', (tester) async {
    await tester.pumpWidget(const CondoLeituraApp());
    await tester.pumpAndSettle();
    expect(find.text('CondoLeitura'), findsWidgets);
    expect(find.text('Nova leitura'), findsOneWidget);
  });
}
