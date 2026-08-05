# CRUD de medidores — implementação

## Entregue

- Cadastro de medidores de água e gás por unidade.
- Edição, consulta, pesquisa, filtros e exclusão.
- Número de série único, sem diferenciar maiúsculas e minúsculas.
- Leitura inicial, quantidade de dígitos inteiros e decimais.
- Identificação opcional, data de instalação, situação e observações.
- Persistência SQLite com chave estrangeira para `units` e exclusão em cascata.
- Migração do banco da versão 3 para a versão 4.
- Acesso pela tela de detalhes da unidade.

## Fluxo de teste

1. Abra um condomínio e uma torre.
2. Abra uma unidade já cadastrada.
3. Toque em **Medidores de água e gás**.
4. Cadastre um medidor de água e outro de gás.
5. Teste pesquisa, filtros, edição e exclusão.

## Comandos recomendados

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Para validar a persistência SQLite, prefira Android ou iOS. O Windows exige `sqflite_common_ffi`.
