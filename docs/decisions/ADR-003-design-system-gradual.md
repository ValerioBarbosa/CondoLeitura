# ADR-003 — Design System com migração gradual

## Contexto

O projeto já possui widgets e telas funcionais. Uma migração completa e imediata para uma nova estrutura aumentaria o risco de regressão.

## Decisão

Criar tokens e componentes compartilhados em `lib/shared`, migrando as telas gradualmente durante as próximas sprints.

## Consequências

- Menor risco de quebra.
- Padronização progressiva.
- Possibilidade temporária de coexistência entre widgets antigos e novos.
- Remoção dos componentes antigos somente após validação das telas migradas.
