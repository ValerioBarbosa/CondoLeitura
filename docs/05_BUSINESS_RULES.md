# Regras de negócio

1. Toda torre deve pertencer a um condomínio.
2. Nome da torre é obrigatório.
3. Código é opcional.
4. Torre inativa permanece cadastrada.
5. Ao excluir um condomínio, suas torres são excluídas.
6. Quantidade de unidades e andares será calculada a partir do módulo de unidades.
7. Toda unidade deve pertencer a uma torre.
8. Número da unidade é obrigatório; andar e código são opcionais.
9. Unidade inativa permanece cadastrada.
10. Ao excluir uma torre, suas unidades (e os medidores vinculados a elas) são excluídos.
11. Todo medidor deve pertencer a uma unidade.
12. Medidor tem um tipo obrigatório: Água ou Gás.
13. Uma unidade pode ter mais de um medidor, inclusive mais de um do mesmo tipo.
14. Medidor inativo não entra na rota de leitura, mas permanece cadastrado.
15. Ao excluir uma unidade, seus medidores são excluídos.
16. Quantidade de hidrômetros do condomínio/torre/unidade será calculada a partir dos medidores cadastrados.
