# Sprint 02 — Apartamentos e Unidades

## Objetivo
Permitir o cadastro completo de unidades vinculadas obrigatoriamente a uma torre.

## Entregas
- CRUD de unidades;
- identificador livre;
- status ativo/inativo;
- observações;
- pesquisa e filtros;
- persistência multiplataforma no MVP;
- exclusão em cascata ao remover torre ou condomínio;
- contadores automáticos no Dashboard.

## Regras
1. Toda unidade pertence a uma torre.
2. O identificador é livre: 101, A-203, Cobertura 01, Loja 02 etc.
3. Não pode haver identificadores duplicados dentro da mesma torre.
4. Proprietário e morador não fazem parte do cadastro.
5. Quantidade de unidades é sempre calculada.

## Critérios de aceite
- cadastrar, editar, excluir e pesquisar;
- manter dados após F5;
- atualizar os totais automaticamente;
- `flutter analyze` sem erros.
