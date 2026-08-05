# Câmera e OCR

Fluxo implementado: Unidade → Medidor → Capturar leitura → Câmera/Galeria → OCR ML Kit → confirmação manual → foto persistida → leitura salva no SQLite.

Banco atualizado para versão 5, com tabela `readings`.

Teste preferencial: dispositivo Android físico, pois câmera e ML Kit não funcionam integralmente no Chrome/Windows.
