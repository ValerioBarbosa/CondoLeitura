# Sprint 04 — Captura de foto do medidor

## Entregue
- Campo de captura de foto (`PhotoCaptureField`), reutilizado nos dois diálogos de registro de leitura (histórico do medidor e diálogo global de "Nova leitura"). Usa `image_picker` com a câmera, funcionando em Web (navegador do celular/desktop), Android e iOS sem código nativo adicional.
- Foto anexada à leitura fica salva como bytes em base64 (`Reading.photoBase64`), não como caminho de arquivo — necessário porque o Web não tem um caminho de arquivo persistente entre sessões.
- Miniatura da foto aparece no histórico de leituras do medidor (toque para ver em tamanho grande) e nas listagens de leitura do restante do app.
- Removidos os stubs de captura/confirmação (`capture_screen.dart`, `camera_preview_screen.dart`, `qr_code_screen.dart`, `confirm_screen.dart`, `manual_correction_screen.dart`): a captura simples de foto não precisa de uma tela de câmera dedicada, o próprio `image_picker` cuida da interface nativa.

## Fora desta entrega (fica para uma etapa própria de OCR)
- Reconhecimento automático do valor do medidor a partir da foto (`google_mlkit_text_recognition`). Esse pacote **não tem suporte a Web** — só funciona em builds nativos de Android e iOS. Testar essa parte exige compilar para um dispositivo real, fora do alcance deste ambiente de desenvolvimento.
- Quando o OCR for implementado, a tela de câmera dedicada (com guia visual de enquadramento) provavelmente precisará ser reconstruída — a captura simples atual usa a interface nativa do sistema, que não permite overlay customizado.

## Testes necessários
- `flutter analyze`
- `flutter test` (inclui teste de widget que mocka a plataforma do `image_picker` para simular a captura de uma foto, confere o base64 gerado e a exibição/remoção da miniatura)
- Celular real (Android/iOS ou navegador móvel): tirar uma foto ao registrar uma leitura e confirmar que ela aparece no histórico do medidor.
