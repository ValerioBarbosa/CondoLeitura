# Sprint 03 — Medidores de água e gás

## Objetivo

Permitir o cadastro e a gestão de medidores vinculados às unidades, mantendo o histórico de leituras separado do cadastro do equipamento.

## Entregas

- Cadastro, edição, consulta, pesquisa, filtros e exclusão de medidores.
- Vínculo obrigatório com unidade.
- Tipos Água e Gás.
- Número de série único.
- Fabricante, modelo, identificação interna, data de instalação, leitura inicial, observações e status.
- Persistência compatível com a execução atual no Chrome e no Windows.
- Exclusão em cascata lógica quando unidade, torre ou condomínio é removido.
- Indicador real de medidores no Dashboard.
- Banco SQLite atualizado para a versão 6.
- Tabela `readings` mantida separada e preparada para a Sprint 4.

## Regras

1. Um medidor pertence a uma única unidade.
2. O número de série não pode se repetir.
3. A leitura atual não é gravada no cadastro do medidor.
4. Medidores inativos permanecem no histórico, mas não entram na futura rota de leitura.
5. Ao excluir uma unidade, seus medidores são removidos.

## Testes manuais

- Cadastrar medidor de água.
- Cadastrar medidor de gás.
- Bloquear série duplicada.
- Editar fabricante, modelo e status.
- Pesquisar e filtrar.
- Atualizar com F5 e conferir persistência.
- Excluir medidor.
- Conferir contador no Dashboard.
