# Arquitetura do CondoLeitura (documento desatualizado)

> **Este documento descreve uma arquitetura aspiracional (SQLite + Supabase em
> camadas) que não corresponde ao estado atual do projeto.** A decisão
> documentada e vigente está em `docs/03_ARCHITECTURE.md`: o app roda hoje em
> `UI → AppData (ChangeNotifier) → SharedPreferences`, e o banco definitivo /
> os repositórios serão integrados **gradualmente, por módulo**, conforme o
> roadmap em `docs/02_ROADMAP.md` avança — não de uma vez, como este
> documento sugere. O código que existia aqui como tentativa isolada desse
> desenho (models, repositórios e provider de Condomínio em SQLite, stack de
> sync, etc.) foi removido por estar desconectado da UI e sem testes reais;
> ele continua disponível no histórico do git caso sirva de referência
> quando cada módulo for implementado de verdade.
>
> Mantenha este arquivo como referência de longo prazo para as decisões de
> segurança e sincronização (RLS, idempotency_key, etc.), mas trate
> `docs/00_VISION.md` a `docs/06_DESIGN_SYSTEM.md`, `docs/decisions/` e
> `docs/sprints/` como a fonte de verdade sobre o que existe hoje.

## Visão geral

O CondoLeitura é um aplicativo Flutter para leitura de medidores de água e gás em condomínios. O sistema foi projetado com abordagem offline-first: o leiturista consegue trabalhar sem conexão, armazenando localmente fotos, leituras, coordenadas, observações e pendências de sincronização.

Quando a conexão retorna, o aplicativo envia os dados pendentes ao backend Supabase e atualiza o banco local com os identificadores e estados remotos.

Fluxo principal:

Widget/Tela → Provider → Service → Repository → SQLite ou Supabase

## Core Components

### Flutter app

O aplicativo Flutter é a camada de apresentação e execução do CondoLeitura.

Plataformas previstas:

- Android;
- iOS;
- Web.

Responsabilidades principais:

- autenticação do leiturista;
- seleção de condomínio, torre, unidade e medidor;
- captura de foto;
- leitura OCR;
- confirmação manual;
- registro de GPS;
- funcionamento offline;
- sincronização;
- geração e compartilhamento de relatórios.

O gerenciamento de estado usa `provider`.

Os providers cuidam apenas de:

- estado da tela;
- carregamento;
- erro;
- filtros;
- seleção;
- orquestração das chamadas.

As regras de negócio permanecem nos services.

### Supabase

O Supabase é o backend remoto do CondoLeitura.

Componentes utilizados:

#### Supabase Auth

Responsável por:

- login;
- sessão do usuário;
- recuperação de senha;
- identificação do leiturista;
- vínculo do usuário com condomínios autorizados.

#### Supabase Postgres

Responsável por armazenar:

- usuários e perfis;
- condomínios;
- torres;
- unidades;
- medidores;
- leituras;
- auditoria;
- estados de sincronização;
- configurações administrativas.

#### Supabase Storage

Responsável por armazenar:

- fotos dos medidores;
- fotos de condomínios;
- assinaturas;
- arquivos exportados, quando necessário.

Os buckets devem ser privados e acessados por políticas vinculadas ao usuário autenticado e ao condomínio autorizado.

### OCR local

O OCR é executado preferencialmente no próprio dispositivo.

Estrutura:

`assets/models/ocr/`

Objetivos:

- funcionar sem internet;
- reduzir latência;
- evitar envio desnecessário de imagens;
- manter a operação de campo ativa em locais sem sinal;
- permitir validação antes da sincronização.

O OCR deve retornar:

- texto bruto;
- dígitos reconhecidos;
- confiança estimada;
- necessidade de revisão;
- divergência em relação à leitura anterior.

A imagem original deve continuar disponível para auditoria.

## Data Stores

### SQLite local

O SQLite é o banco operacional do aplicativo.

Ele existe para garantir:

- funcionamento offline;
- resposta rápida;
- persistência imediata;
- histórico local;
- fila de sincronização;
- recuperação após fechamento inesperado;
- continuidade da rota sem conexão.

Tabelas locais principais:

- condominiums;
- towers;
- units;
- meters;
- readings;
- photos;
- gps_locations;
- sync_queue;
- audit_logs;
- app_settings.

Toda leitura deve ser salva primeiro no SQLite.

### Postgres remoto

O Postgres do Supabase é a fonte central compartilhada.

Ele existe para:

- consolidar dados de vários aparelhos;
- permitir múltiplos leituristas;
- centralizar histórico;
- gerar relatórios administrativos;
- manter backup remoto;
- controlar acessos;
- permitir auditoria e rastreabilidade.

### Por que usar SQLite e Postgres

O SQLite atende o trabalho de campo.

O Postgres atende a operação centralizada.

O aplicativo não deve depender diretamente do Postgres para concluir uma leitura. A sincronização é uma etapa posterior.

Fluxo:

1. leitura realizada;
2. gravação no SQLite;
3. criação de item em `sync_queue`;
4. tentativa de sincronização;
5. confirmação do Supabase;
6. atualização do registro local;
7. remoção ou conclusão do item da fila.

### sync_queue

A tabela `sync_queue` concilia os bancos local e remoto.

Campos mínimos recomendados:

- id;
- entity_type;
- entity_local_id;
- operation;
- payload;
- status;
- attempts;
- last_error;
- idempotency_key;
- created_at;
- updated_at.

Estados:

- pending;
- syncing;
- synced;
- failed.

A fila deve ser processada em ordem cronológica, com limite por lote e novas tentativas controladas.

O envio deve usar `upsert` ou operação equivalente baseada em `idempotency_key`.

## External Integrations

### WhatsApp

O compartilhamento com WhatsApp usa o compartilhamento nativo do sistema.

Fluxo:

1. gerar PDF, Excel ou CSV;
2. salvar arquivo temporário;
3. abrir o menu nativo de compartilhamento;
4. usuário escolhe o WhatsApp;
5. arquivo e mensagem são enviados.

O app não deve depender de automação interna do WhatsApp para anexar arquivos.

### E-mail

O envio por e-mail também usa o compartilhamento nativo.

Aplicativos possíveis:

- Gmail;
- Outlook;
- Apple Mail;
- outros clientes instalados.

O CondoLeitura prepara:

- assunto;
- corpo da mensagem;
- arquivos anexos.

### Impressão

O serviço de impressão recebe um arquivo PDF e utiliza o diálogo nativo de impressão.

Usos:

- relatório mensal;
- relatório por condomínio;
- relatório de pendências;
- relatório de auditoria;
- resumo da rota.

### Compartilhamento universal

O `share_service.dart` permite compartilhar com:

- WhatsApp;
- Telegram;
- Google Drive;
- OneDrive;
- e-mail;
- AirDrop;
- Bluetooth;
- outros aplicativos compatíveis.

## Security Considerations

### Supabase RLS

Todas as tabelas sensíveis devem usar Row Level Security.

Regras gerais:

- usuário autenticado só acessa condomínios autorizados;
- leiturista só grava leituras vinculadas ao próprio usuário;
- administradores podem consultar dados dos condomínios permitidos;
- exclusões definitivas devem ser restritas;
- auditoria não deve ser editável pelo cliente comum.

Tabelas prioritárias:

- condominiums;
- towers;
- units;
- meters;
- readings;
- audit_logs.

### Storage Policies

Os buckets devem ser privados.

Políticas devem validar:

- autenticação;
- condomínio autorizado;
- pasta pertencente ao usuário ou condomínio;
- tipo de arquivo permitido;
- limite de tamanho.

Estrutura sugerida:

`condominiums/{condominiumId}/readings/{readingId}/photo.jpg`

`condominiums/{condominiumId}/signatures/{readingId}/signature.png`

Nunca usar URL pública permanente para fotos ou assinaturas sensíveis.

### idempotency_key

Cada operação enviada pela fila deve possuir uma chave única.

Exemplo:

`reading:{localId}:upsert`

Essa chave evita:

- duplicidade por reconexão;
- duplicidade por timeout;
- reenvio após fechamento do app;
- múltiplos registros da mesma leitura.

No Postgres, a coluna deve ter índice único.

### Proteção de credenciais

No aplicativo podem existir apenas:

- URL pública do Supabase;
- chave pública anon.

Nunca incluir:

- service_role;
- senha do banco;
- chave administrativa;
- segredo de assinatura.

### Dados locais

O SQLite pode conter dados operacionais e deve ser protegido pelo sistema do aparelho.

Para uma versão posterior, considerar:

- banco criptografado;
- bloqueio por biometria;
- expiração de sessão;
- remoção remota do acesso;
- limpeza segura de cache e arquivos temporários.

## Sincronização

O `core/network/connectivity_service.dart` apenas informa o estado técnico da conexão.

O `services/sync_service.dart` decide quando e como sincronizar.

Responsabilidades do SyncService:

- verificar conexão;
- buscar itens pendentes;
- marcar como syncing;
- enviar ao backend;
- aplicar idempotência;
- registrar erro;
- incrementar tentativas;
- marcar como synced;
- atualizar identificadores remotos.

O provider apenas expõe:

- carregando;
- erro;
- quantidade pendente;
- última sincronização.

## Regras de domínio importantes

- Proprietário e Morador não fazem parte do modelo de unidade;
- toda leitura deve ter identificação local única;
- leitura nunca depende de internet para ser concluída;
- foto pode ser obrigatória em divergências;
- OCR de baixa confiança exige revisão;
- consumo anormal exige confirmação;
- exclusão de condomínio deve preferir arquivamento;
- histórico de leitura deve ser preservado;
- toda operação importante deve gerar auditoria.

## Testes prioritários

- salvar leitura offline;
- criar item na fila;
- impedir duplicidade;
- sincronizar após reconexão;
- tratar timeout;
- validar RLS;
- enviar foto;
- gerar PDF;
- gerar Excel;
- gerar CSV;
- compartilhar arquivo;
- arquivar condomínio sem perder histórico.
