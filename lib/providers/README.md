# Providers

O projeto usa `provider`.

Responsabilidade dos providers:

- armazenar estado de tela;
- controlar loading, erro e seleção;
- orquestrar chamadas para services;
- notificar widgets com `notifyListeners()`.

Os providers não devem:

- acessar SQLite diretamente;
- chamar APIs diretamente;
- executar regras de negócio complexas;
- montar SQL;
- gerar arquivos PDF, Excel ou CSV.

Fluxo esperado:

Widget → Provider → Service → Repository → DatabaseService/ApiClient
