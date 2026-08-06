# Changelog

Todas as alterações relevantes do CondoLeitura serão registradas neste arquivo.

## [0.1.0-alpha] - 2026-08-06

### Adicionado

- Dashboard do condomínio.
- Módulo de torres e blocos.
- Documentação de visão, arquitetura, banco, regras de negócio e roadmap.
- Tokens iniciais do Design System.
- Componentes reutilizáveis para métricas, módulos, pesquisa, botões e estados vazios.
- Arquivo `PROJECT_STATUS.md`.

### Alterado

- Dashboard refatorado para usar componentes compartilhados.
- Tema claro e escuro centralizados em tokens de cor e raio.
- Paleta oficial do produto consolidada.

### Removido do pacote

- Pastas `build` e `.dart_tool`.
- Arquivos temporários e caches de compilação.

## 0.2.0-alpha
- CRUD completo de apartamentos/unidades.
- Persistência multiplataforma no MVP.
- Contadores automáticos por torre e condomínio.
- Exclusão em cascata de unidades.

## 0.3.0 - Sprint 03

- Implementado CRUD completo de medidores de água e gás.
- Adicionados fabricante, modelo e data de instalação.
- Adicionados pesquisa, filtros e validação de número de série único.
- Integrado o acesso aos medidores pelos detalhes da unidade.
- Atualizado o contador de medidores no Dashboard.
- Adicionada persistência web via `AppData` e `SharedPreferences`.
- Atualizado o SQLite para a versão 6, mantendo leituras em tabela separada.

## 0.4.0-alpha — Sprint 4

- fluxo de nova leitura por medidor;
- captura por câmera/galeria;
- OCR móvel com revisão manual;
- histórico e consumo calculado;
- contador de leituras no Dashboard;
- exclusão em cascata de leituras vinculadas.
