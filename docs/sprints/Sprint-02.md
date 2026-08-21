# Sprint 02 — Unidades e Hidrômetros

## Entregue
- Cadastro, edição, pesquisa e exclusão de unidades, acessadas a partir de cada torre.
- Cadastro, edição e exclusão de hidrômetros (água ou gás), acessados a partir de cada unidade.
- Navegação hierárquica real: Condomínio → Torres → Unidades → Medidores.
- Indicadores de unidades e hidrômetros no dashboard do condomínio calculados a partir dos registros reais (sem contagem duplicada), seguindo o mesmo princípio da ADR-002.
- Exclusão em cascata: excluir uma torre remove suas unidades e os medidores delas; excluir uma unidade remove seus medidores.
- Persistência via armazenamento atual do MVP (`SharedPreferences`), seguindo `docs/03_ARCHITECTURE.md`.
- Remoção da navegação por rotas nomeadas que nunca era usada (`config/routes.dart`, `SplashScreen` e as telas antigas de lista/formulário/detalhes de condomínio) — a tela real sempre foi `home_screen.dart`.

## Correção
- `FloatingActionButton` em várias telas não tinha `heroTag` explícito. Como o app mantém várias abas montadas ao mesmo tempo (`IndexedStack`) e empilha telas (Torres → Unidades → Medidores), isso causava o erro "multiple heroes share the same tag" sempre que uma transição de tela acontecia com mais de um FAB padrão montado. Corrigido dando um `heroTag` único por tela.

## Testes necessários
- `flutter analyze`
- `flutter test` (inclui teste de round-trip dos modelos, cascata de exclusão no `AppData` e um teste de widget cobrindo o fluxo completo Torre → Unidade → Medidor)
- Chrome: cadastrar torre, unidade e medidor; excluir uma torre e confirmar que as unidades somem; reiniciar com F5 e confirmar persistência.
