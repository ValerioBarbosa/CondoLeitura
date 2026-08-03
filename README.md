# CondoLeitura 1.0.0

Aplicativo Flutter para leitura de medidores de água e gás em condomínios.

## Recursos previstos

- Funcionamento offline e online
- SQLite local
- Sincronização posterior
- OCR
- GPS
- Captura de fotos
- Histórico de leituras
- Alertas de consumo
- Relatórios PDF, Excel e CSV
- Assinatura
- QR Code
- Modo escuro
- Dashboard e estatísticas

## Observação

As pastas `android`, `ios` e `web` são marcadores estruturais.
Execute `flutter create .` na raiz do projeto para gerar os arquivos nativos completos.


## Gestão de condomínios adicionada

- Cadastro e edição
- Pesquisa por nome, código e cidade
- Arquivamento e restauração
- Exclusão permanente controlada
- Duplicação de cadastro
- Importação CSV/Excel preparada
- Exportação CSV/Excel/PDF preparada
- Sincronização individual
- Tela de detalhes e indicadores


## Exportação e compartilhamento
- PDF, Excel e CSV
- Compartilhamento nativo
- WhatsApp
- E-mail
- Salvar no aparelho
- Impressão de PDF
- Pré-visualização, filtros e histórico


## Arquitetura definida

Gerenciamento de estado: `provider`.

Fluxo:

Widget → Provider → Service → Repository → DatabaseService/ApiClient

A conectividade técnica fica exclusivamente em:

`lib/core/network/connectivity_service.dart`

A decisão e execução da sincronização ficam em:

`lib/services/sync_service.dart`


## Documentação de arquitetura

O arquivo `docs/architecture.md` descreve a arquitetura específica do CondoLeitura, incluindo Flutter, Supabase, OCR local, SQLite, Postgres, sincronização, compartilhamento e segurança.


## Pacote consolidado

Este pacote contém a estrutura atualizada do CondoLeitura 1.0.0 com:

- Flutter para Android, iOS e Web;
- Provider como gerenciamento de estado;
- SQLite local e Supabase remoto;
- OCR local;
- sincronização offline-first;
- gestão de condomínios;
- relatórios PDF, Excel e CSV;
- compartilhamento, WhatsApp, e-mail e impressão;
- documentação de arquitetura;
- migrations e políticas do Supabase;
- testes iniciais.
