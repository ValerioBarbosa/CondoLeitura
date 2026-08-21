# Sprint 03 — Leituras manuais e histórico

## Entregue
- Registro de leitura passa a referenciar um medidor real (Condomínio → Torre → Unidade → Medidor), em vez de texto livre digitado à mão.
- Diálogo global de "Nova leitura" (aba Leituras e atalho do painel) com seleção em cascata: Condomínio → Torre → Unidade → Medidor.
- Histórico de leituras por medidor, acessado tocando no medidor (edição do cadastro do medidor passou para o menu de opções). Mostra todas as leituras, consumo por leitura e permite registrar uma nova leitura direto no contexto do medidor (sem precisar escolher condomínio/torre/unidade de novo).
- `previousValue` deixou de ser digitado: é sempre calculado a partir da última leitura do próprio medidor (zero, se for a primeira), eliminando erro de digitação e inconsistência.
- Exclusão em cascata estendida até leituras: excluir um medidor, uma unidade, uma torre ou um condomínio remove também as leituras vinculadas.
- Relatório de consumo por tipo (água/gás) passou a olhar o medidor real de cada leitura em vez de um texto solto.

## Correção
- Corrigido overflow de layout no card de leitura do histórico (o `trailing` com dois itens empilhados estourava a altura padrão do `ListTile`); a exclusão de leitura passou a usar `Dismissible` (deslizar), no mesmo padrão já usado na aba Leituras.

## Fora desta entrega
- OCR (reconhecimento automático do medidor pela câmera) fica para uma etapa própria — depende de câmera/hardware real, que não é possível validar neste ambiente de desenvolvimento.

## Testes necessários
- `flutter analyze`
- `flutter test` (inclui round-trip do modelo `Reading`, cálculo automático de leitura anterior, cascata de exclusão até leituras, e um teste de widget que registra duas leituras seguidas pelo histórico do medidor e confere o consumo calculado)
- Chrome: registrar leitura pelo atalho global e pelo histórico do medidor; excluir um medidor e confirmar que o histórico some.
