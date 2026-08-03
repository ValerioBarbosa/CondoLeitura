# Política de segurança

Não publique vulnerabilidades, tokens, chaves, senhas ou dados pessoais em Issues.

Para corrigir um segredo exposto:

1. Revogue ou rotacione imediatamente a credencial.
2. Remova o segredo do código e do histórico quando necessário.
3. Revise logs, artefatos e Actions que possam ter armazenado o valor.

Arquivos sensíveis devem permanecer fora do Git por meio do `.gitignore` e de variáveis protegidas no GitHub Actions.
