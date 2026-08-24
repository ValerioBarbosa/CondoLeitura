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
17. Toda leitura deve pertencer a um medidor existente.
18. A leitura anterior nunca é digitada: é sempre a última leitura registrada do mesmo medidor (zero, se for a primeira).
19. A leitura atual não pode ser menor que a leitura anterior.
20. Consumo é sempre calculado (atual − anterior), nunca armazenado.
21. Ao excluir um medidor, seu histórico de leituras é excluído junto.
22. Histórico de leituras de um medidor deve ficar acessível a partir do próprio medidor.
23. Foto do medidor é opcional na leitura.
24. Valor sugerido por OCR é sempre uma sugestão editável no campo de leitura atual — nunca preenche e confirma uma leitura sozinho; a confirmação manual do leiturista é sempre exigida.
25. OCR é uma tentativa best-effort: qualquer falha de reconhecimento apenas deixa de sugerir um valor, sem impedir a digitação manual.
