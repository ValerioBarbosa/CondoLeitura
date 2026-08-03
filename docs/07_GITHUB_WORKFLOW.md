# GitHub e integração contínua

## Fluxo

```text
feature/* -> Pull Request -> develop -> Pull Request -> main
```

## Workflows

### Flutter CI

Executado em pushes e Pull Requests para `main` e `develop`:

- instalação das dependências;
- verificação de formatação;
- análise estática;
- testes com cobertura;
- armazenamento temporário do relatório `lcov.info`.

### Android APK

Executado manualmente na aba **Actions**. Gera um APK de release e o disponibiliza como artefato por 30 dias.

### GitHub Release

Executado quando uma tag no padrão `vX.Y.Z` é enviada. Valida o projeto, gera o APK e cria uma Release com notas automáticas.

Exemplo:

```powershell
git checkout main
git pull origin main
git tag -a v1.0.0 -m "CondoLeitura 1.0.0"
git push origin v1.0.0
```

## Proteção recomendada

Crie Rulesets para `main` e `develop` com:

- Pull Request obrigatório;
- checks obrigatórios;
- branch atualizada antes do merge;
- bloqueio de force push;
- bloqueio de exclusão.

Na `main`, exija o check **Analyze, format and test**. Na `develop`, aplique o mesmo check.

## Assinatura Android

O APK gerado pela automação serve para validação interna. Para publicação na Play Store, configure uma keystore própria e armazene os valores como GitHub Actions Secrets. Nunca envie a keystore ou suas senhas ao repositório.
