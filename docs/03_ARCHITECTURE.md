# Arquitetura

O projeto mantém, por enquanto, a organização em camadas já existente. A migração para feature-first será gradual para evitar regressões.

Fluxo atual de estado do MVP:

`UI → AppData (ChangeNotifier) → SharedPreferences`

O banco definitivo e os repositórios serão integrados por módulo, sem reescrever toda a aplicação de uma vez.
