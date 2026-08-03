# Contribuindo com o CondoLeitura

## Fluxo de branches

```text
feature/* -> develop -> main
```

- `main`: versão estável e publicável.
- `develop`: integração das funcionalidades concluídas.
- `feature/<nome>`: nova funcionalidade.
- `fix/<nome>`: correção comum.
- `hotfix/<nome>`: correção urgente criada a partir da `main`.

## Criando uma funcionalidade

```powershell
git checkout develop
git pull origin develop
git checkout -b feature/nome-da-funcionalidade
```

Antes do commit:

```powershell
dart format lib test
flutter analyze
flutter test
```

Envio:

```powershell
git add .
git commit -m "feat: descreva a funcionalidade"
git push -u origin feature/nome-da-funcionalidade
```

Abra um Pull Request para `develop`. O merge de `develop` para `main` representa uma versão estável.

## Padrão de commits

- `feat:` funcionalidade
- `fix:` correção
- `refactor:` reorganização sem mudança funcional
- `test:` testes
- `docs:` documentação
- `ci:` automação
- `chore:` manutenção

## Regras mínimas

1. Não enviar `.env`, tokens, chaves, bancos locais ou arquivos de assinatura.
2. Não fazer push direto em `main` ou `develop` depois que as proteções forem ativadas.
3. Manter análise, formatação e testes aprovados.
4. Explicar riscos, migrações e alterações de banco no Pull Request.
