# CRUD de unidades — implementação concluída

## Entregue

- Migração SQLite versão 3.
- Tabela `towers` compatível com os IDs em texto usados pelo MVP.
- Tabela `units` com chave estrangeira e exclusão em cascata.
- Modelo `Unit` completo, incluindo ordem de leitura.
- Repositório local com inserir, consultar, editar, excluir, contar e verificar duplicidade.
- Provider para carregamento, filtros, pesquisa e tratamento de erros.
- Tela de unidades vinculada à tela de torres.
- Cadastro e edição com validações.
- Ativação e inativação de unidades.
- Tela de detalhes.
- Exclusão com confirmação.
- Pesquisa por número, código e andar.
- Filtros de unidades ativas e inativas.

## Como testar

1. Execute `flutter clean`.
2. Execute `flutter pub get`.
3. Execute `flutter analyze`.
4. Abra um condomínio.
5. Abra `Torres e blocos`.
6. Toque em uma torre.
7. Cadastre, edite e exclua unidades.

## Observação

O ambiente usado para a alteração não possui o SDK Flutter instalado. Por isso, a validação final com `flutter analyze` deve ser executada no computador de desenvolvimento.
